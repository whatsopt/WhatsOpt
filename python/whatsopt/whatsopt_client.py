from __future__ import print_function
from six import iteritems
import os
import sys
import json
import getpass
import requests
from openmdao.devtools.problem_viewer.problem_viewer import _get_viewer_data, view_model
from openmdao.core.indepvarcomp import IndepVarComp
from openmdao.core.problem import Problem
from openmdao.core.group import Group
from __builtin__ import staticmethod

WHATSOPT_DIRNAME = os.path.join(os.path.expanduser('~'), '.whatsopt')
API_KEY_FILENAME = os.path.join(WHATSOPT_DIRNAME, 'api_key')
NULL_DRIVER_NAME = '__DRIVER__'  # check WhatsOpt Discipline model

PROD_URL = "http://rdri206h.onecert.fr/whatsopt"
TEST_URL = "http://endymion:3000"
DEV_URL = "http://192.168.99.100:3000"

class WhatsOptImportMdaError(Exception):
    pass

class WhatsOpt(object):
    
    def __init__(self, url=None, api_key=None):
        if url:
            self.url = url
        else:
            self.url = self.default_url
        
        if api_key:
            self.api_key = api_key
        elif os.path.exists(API_KEY_FILENAME):
            self.api_key = self._read_api_key()
        else:
            self.api_key = self._ask_and_write_api_key()
          
        self.headers = {'Authorization': 'Token token=' + self.api_key}
        
        # config session object
        self.session = requests.Session()  
        self.session.trust_env = False 
        
        # MDA informations
        self.mda_attrs = {'name': '', 'discipline_attributes':''}
        self.discnames = []
        self.discattrs = []
        self.vars = {}
        self.varattrs = {}
        

    def _url(self, path):
        return self.url + path

    @property
    def default_url(self):
        env = os.getenv("WHATSOPT_ENV")
        if env=="development":
            self._default_url = DEV_URL
        elif env=="test":
            self._default_url = TEST_URL
        else: # env=="production":
            self._default_url = PROD_URL
        return self._default_url    
            
    def _ask_and_write_api_key(self):
        print("You have to set your API_KEY. You can get it in your profile on WhatsOpt.")
        print("Please, copy/paste your api key below then hit return (characters are hidden).")
        api_key = getpass.getpass(prompt='Your API key: ')
        if not os.path.exists(WHATSOPT_DIRNAME):
            os.makedirs(WHATSOPT_DIRNAME)
        with open(API_KEY_FILENAME, 'w') as f:
            f.write(api_key)
        return api_key 

    def _read_api_key(self):
        with open(API_KEY_FILENAME, 'r') as f:
            api_key = f.read()
            return api_key

    def execute(self, progname, func):
        dir = os.path.dirname(progname)
        sys.path.insert(0, dir)
        with open(progname, 'rb') as fp:
            code = compile(fp.read(), progname, 'exec')
        globals_dict = {
            '__file__': progname,
            '__name__': '__main__',
            '__package__': None,
            '__cached__': None,
        }
        Problem._post_setup_func = self.push_mda_cmd()
        exec(code, globals_dict)

    def push_mda_cmd(self):
        def push_mda(prob):
            self.push_mda(prob)
            exit()
        return push_mda

    def push_mda(self, problem):
        print("Try to push MDA to %s" % self.url)
        data = _get_viewer_data(problem)
        tree = data['tree']
        #print(tree)
        connections = data['connections_list']
        #print(connections)
        self.discnames = [NULL_DRIVER_NAME]
        self.discnames.extend(self._collect_discnames_and_vars(problem.model, tree))
        print(self.discnames)
        self._initialize_disciplines_attrs(problem, connections)
        
        name = problem.model.__class__.__name__
        print("MDA= ", name)
        if name == 'Group':
            name = 'MDA'
        self.mda_attrs = {'name': name,
                          'disciplines_attributes': self.discattrs}    
        print([d for d in self.discattrs if d['name']=='sap.Struc'])    
        #print(self.vars)
        mda_params = {'analysis': self.mda_attrs}
        url =  self._url('/api/v1/analyses')
        resp = self.session.post(url, headers=self.headers, json=mda_params)
        if resp.ok:
            print(resp.json())
        else:
            print(resp.json())

    # see _get_tree_dict at
    # https://github.com/OpenMDAO/OpenMDAO/blob/master/openmdao/devtools/problem_viewer/problem_viewer.py
    def _collect_discnames_and_vars(self, system, tree, group_prefix=''):
        disciplines = []
        if 'children' in tree:
            for i, child in enumerate(tree['children']):
                # do not represent IndepVarComp
                if not isinstance(system._subsystems_myproc[i], IndepVarComp):
                    # retain only components, not intermediates (subsystem or group)
                    if child['type'] == 'subsystem' and child['subsystem_type'] == 'group':
                        prefix = group_prefix+child['name']+'.'
                        disciplines.extend(self._collect_discnames_and_vars(system._subsystems_myproc[i], child, prefix))
                    else:
                        disciplines.append(group_prefix+child['name'])
                        for typ in ['input', 'output']:
                            for ind, abs_name in enumerate(system._var_abs_names[typ]):
                                io_mode = 'out'
                                if typ == 'input': 
                                    io_mode = 'in' 
                                elif typ == 'output': 
                                    io_mode = 'out'
                                else:
                                    raise Exception('Unhandled variable type ' + typ)
                                meta = system._var_abs2meta[typ][abs_name]
                                self.vars[abs_name] = {'fullname': abs_name,
                                                       'name': system._var_abs2prom[typ][abs_name],
                                                       'io_mode': io_mode
                                                       #'dtype': type(meta['value']).__name__
                                                       }
        return disciplines

    def _initialize_disciplines_attrs(self, problem, connections):
        self._initialize_variables_attrs()
        #print(self.varattrs)
        self.discattrs = []
        for dname in self.discnames:
            discattr = {'name': dname, 'variables_attributes': self.varattrs[dname]}
            self.discattrs.append(discattr)

    def _initialize_variables_attrs(self):
        self.varattrs = {dname: [] for dname in self.discnames}
#         for conn in connections:
#             self._create_varattr_from_connection(conn['src'], 'out')
#             self._create_varattr_from_connection(conn['tgt'], 'in')
        #print(self.vars)
        for fullname, varattr in iteritems(self.vars): 
            name_elts = fullname.split('.')
            if len(name_elts) > 1 and name_elts[-1] == varattr['name']:
                disc, var = '.'.join(name_elts[:-1]), name_elts[-1] 
            else:
                raise Exception('Can not parse '+ fullname + ": "+ str(varattr))
            if disc in self.discnames and varattr not in self.varattrs[disc]: 
                self.varattrs[disc].append(varattr)
            elif varattr not in self.varattrs[NULL_DRIVER_NAME]:
                self.varattrs[NULL_DRIVER_NAME].append(varattr)
            
    def _create_varattr_from_connection(self, conn, io_mode):
        name_elts = conn.split('.')
        if len(name_elts) > 1:
            disc, var = '.'.join(name_elts[:-1]), name_elts[-1] 
        else:
            raise Exception('Connection qualified name should contain' + 
                            'at least one dot, but got %s' % conn)
        varattr = {'name':var, 'fullname':conn, 'io_mode': io_mode}
        if disc in self.discnames and varattr not in self.varattrs[disc]: 
            self.varattrs[disc].append(varattr)
        elif varattr not in self.varattrs[NULL_DRIVER_NAME]:
            self.varattrs[NULL_DRIVER_NAME].append(varattr)
            
        
        
        