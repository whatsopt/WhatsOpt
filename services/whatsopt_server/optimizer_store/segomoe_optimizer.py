import os
import numpy as np
import re
import csv

from segomoe.sego import Sego
from segomoe.constraint import Constraint


class SegomoeOptimizer(object):
    def __init__(self, opt_cfg, doe):
        iter = 1
        #################
        ##  Parametres de l executable
        #################
        dimVar = 2  # Number of design variables
        dimCons = 0  # Number of constraints

        ##################"

        constraint_handling = "MC"  # or 'UTB' .or MC...
        ##################"

        ################################
        # get setting from optimization configuration file
        # opt_cfg = OptCfg(cfg_input)
        print(opt_cfg)

        # IniDV = [float(x) for x in opt_cfg['IniDV']]
        Bound_DV = [[float(x) for x in bounds] for bounds in opt_cfg["Bound_DV"]]
        ObjFun = opt_cfg["ObjFun"]
        Constraints = opt_cfg["Constraints"]

        print("Objective function is : %s" % ObjFun[0])
        print("Constraints are:")
        print(Constraints)
        print("Constraint handling criterion: %s" % constraint_handling)

        # -------------------------------------------------
        # get the data from file to train surrogate model
        dvs = doe[0]
        objs = doe[1]
        print("DVS", dvs, objs)
        # exit()
        # -------------------------------------------------
        # consistence check
        ndvs = len(dvs)
        if not len(Bound_DV):
            print(
                "DVS boundary are not defined, the sample points boundary will be used"
            )
            for dv in dvs:
                Bound_lower = min(dv)
                Bound_upper = max(dv)
                Bound_DV.append([Bound_lower, Bound_upper])
        print("Bounds of design variables:")
        print(Bound_DV)
        # if not len(IniDV):
        #    print('Initial value of DVS is not provided, the middle value of the boundary will be used')
        #    for dv in dvs:
        #        IniDV.append((max(dv) + min(dv)) / 2)
        # print('Initial value of design variables: ')
        # print(IniDV)

        nobjs = len(objs)
        # -------------------------------------------------

        """
        script that takes a doe and returns the next enrichment point using SEGO
        """

        path = ".\\"  # The files must be in the form "resX.npy" and "resY.npy"

        #############
        UB = np.array(Bound_DV)[:, 1].tolist()
        LB = np.array(Bound_DV)[:, 0].tolist()

        Param = {}
        typeContraintes = {}
        ####################################
        objsm = []
        # print("Objectif Function description :", ObjFun[0])
        fi = re.split(r"(\+|\-|\*|/)", ObjFun[0])
        # print(fi)
        if len(fi) == 1:
            a = re.split("obj", fi[0])
            objsm = objs[int(a[1]) - 1]
        elif len(fi) == 3:
            a = re.split("obj", fi[0])
            b = re.split("obj", fi[2])
            if fi[1] == "+":
                objsm = np.sum([objs[int(a[1]) - 1], objs[int(b[1]) - 1]], axis=0)
                # print(objsm)
            elif fi[1] == "-":
                # objsm=np.sum([objs[int(a[1])-1],(-1)*objs[int(b[1])-1]], axis=0)
                print(objsm)
            elif fi[1] == "*":
                # objsm=np.prod([objs[int(a[1])-1],objs[int(b[1])-1]], axis=0)
                print(objsm)
            elif fi[1] == "/":
                #      objsm=np.prod([objs[int(a[1])-1],objs[int(b[1])-1]], axis=0)
                print(objsm)
        else:
            print("dont know how to handle more than 2 objectives")
        objsm = np.array([objsm])
        # print("Verification of objectif function",objsm)

        ####################################
        # autres contraintes
        if len(Constraints):
            for i, con in enumerate(Constraints):
                fields1 = re.split("(<|>|=)", con[0])
                tol = float(re.split("=", con[1])[1])
                delimiters1 = fields1[1]
                ## sorry cheating  here
                typeContraintes[i + 1] = [
                    fields1[1],
                    fields1[2],
                    tol,
                ]  # constraint on f[1]
                c = re.split("obj", fields1[0])
                # Begin MODIF NB to check and validate
                # Modifcation to transform constraint g(x)<c into c-g(x)>0 constraint (residual form)
                # c is read as a string so you put float(c)=float(fields1[2])
                if fields1[1] == "<":
                    res = [float(fields1[2]) - x for x in objs[int(c[1]) - 1]]
                # TODO : do the same when c/=0 for > 0 constraint
                elif fields1[1] == ">":  # g(x)-c>0
                    res = [x - float(fields1[2]) for x in objs[int(c[1]) - 1]]
                elif fields1[1] == "=":  # g(x)-c=0
                    res = [x - float(fields1[2]) for x in objs[int(c[1]) - 1]]
                objsm = np.append(objsm, [res], axis=0)
                # end MODIF NB to check and validate
        else:
            print(
                "No constraint is defined, a unconstrained optimization problem is going to set up"
            )
        # print("Verification of constraint function",objsm)

        ########## Restrictions suivant la destination de l executable
        if (len(Constraints)) != dimCons or (len(dvs) != dimVar):
            raise ValueError(
                "Executable made for 2 variables  and 0 inequality constraints"
            )
        ########
        #### X
        np.save("./doe", np.transpose(np.array(dvs)))
        #### Y
        # TODO modifier pour que le residu des contraintes soit donne dans le bon sens en fonction du sens de la contrainte
        np.save("./doe_response", np.transpose(np.array(objsm)))

        # X = np.load('./doe.npy')
        # Y = np.load('./doe_response.npy')
        # print(X, Y)

        def f_grouped(x):
            return np.zeros(len(objsm)), False

        if (len(objsm) - 1) > 0:

            constraints = [
                Constraint(
                    typeContraintes[i + 1][0],
                    float(typeContraintes[i + 1][1]),
                    name=("Tsagi_c" + str(i)),
                    f=g,
                    tol=typeContraintes[i + 1][2],
                )
                for i, g in enumerate(typeContraintes)
            ]

        else:
            constraints = []

        n_var = ndvs

        var = [{"name": "x_" + str(i), "lb": LB[i], "ub": UB[i]} for i in range(n_var)]

        mod_obj = {
            "type": "Krig",
            "corr": "squared_exponential",
            "theta0": [1.0] * n_var,
            "thetaL": [0.1] * n_var,
            "thetaU": [10.0] * n_var,
        }
        mod_con = mod_obj

        default_models = {"obj": mod_obj, "con": mod_con}

        # analytical solution
        # sol = {'value': 0.800, 'tol': 1e-4}

        nvar = len(UB)

        # with constraints
        self.sego = Sego(
            f_grouped,
            var,
            const=constraints,
            optim_settings={
                "model_type": default_models,
                "n_clusters": 1,
                "grouped_eval": True,
                "analytical_diff": True,
                "profiling": False,
                "debug": False,
                "verbose": False,
                "cst_hand": constraint_handling,
            },
            path_hs="./",
            comm=None,
        )

    def ask(self):
        res = self.sego.run_optim(n_iter=1)
        return res

    def tell(self, x, y):
        pass


def file_in(input_name):
    nDvs = 0
    nObjs = 0
    dvs = []
    objs = []
    nSample = 0
    for i, line in enumerate(open(input_name)):
        line = line.strip("\n")
        if not (len(line.strip()) == 0 or line.startswith("#")):
            elements = line.split(";")
            # elements = line.split(',')
            if i == 0:
                for ele in elements:
                    if ele.startswith("DV"):
                        nDvs += 1
                    elif ele.startswith("OBJ"):
                        nObjs += 1
                if not nDvs > 0:
                    raise Exception(
                        "No design variables were defined,please check your input"
                    )
                else:
                    print("%d Design variables were defined" % nDvs)
                if not nObjs > 0:
                    raise Exception(
                        "No objective function were defined, please check your input"
                    )
                else:
                    print(
                        "%d Objective function and/or Constraints were defined" % nObjs
                    )

            else:
                if i == 1:
                    pass
                else:
                    nSample += 1
                    dv = []
                    obj = []
                    for dv_index in range(nDvs):

                        dv.append(float(elements[dv_index]))
                    dvs.append(dv)
                    for obj_index in range(nObjs):
                        obj.append(float(elements[nDvs + obj_index]))
                    objs.append(obj)
    dvs = [[r[col] for r in dvs] for col in range(len(dvs[0]))]

    objs = [[r[col] for r in objs] for col in range(len(objs[0]))]
    print("%s Sample points are found in the input file" % nSample)
    return [dvs, objs]


#
def OptCfg(cfg_file):
    opt_cfg = dict()
    keywords = ["Bound_DV", "ObjFun", "Constraints"]
    f = open(cfg_file)
    while True:
        line = f.readline()

        line = line.strip("\n")
        if not (len(line.strip()) == 0 or line.startswith("#")):
            for i, keyword in enumerate(keywords):
                next_keyword = ""
                try:
                    next_keyword = keywords[i + 1]
                except IndexError:
                    pass
                if keyword in line:
                    setting = []
                    while True:
                        content = f.readline().strip("\n")
                        if (
                            not content
                            or content.startswith("#")
                            or (next_keyword in line and next_keyword)
                        ):
                            break
                        if "," in content:
                            setting.append([x for x in content.split(",")])
                        else:
                            setting.append(content)
                    opt_cfg[keyword] = setting
        if not line:
            break
    return opt_cfg

