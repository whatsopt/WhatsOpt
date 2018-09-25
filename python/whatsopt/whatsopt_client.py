from __future__ import print_function
from six import iteritems
from shutil import move
import os
import sys
import json
import getpass
import requests
import copy
import re
import zipfile
import tempfile

from openmdao.devtools.problem_viewer.problem_viewer import _get_viewer_data, view_model
from openmdao.api import IndepVarComp, Problem, Group, CaseReader
from tabulate import tabulate
from whatsopt import __version__

WHATSOPT_DIRNAME = os.path.join(os.path.expanduser('~'), '.whatsopt')
API_KEY_FILENAME = os.path.join(WHATSOPT_DIRNAME, 'api_key')
NULL_DRIVER_NAME = '__DRIVER__'  # check WhatsOpt Discipline model

PROD_URL = "http://selene.onecert.fr/whatsopt"
STAG_URL = "http://rdri206h.onecert.fr/whatsopt"
TEST_URL = "http://endymion:3000"
DEV_URL  = "http://192.168.99.100:3000"

class WhatsOptImportMdaError(Exception):
    pass

class WhatsOpt(object):
    
    def __init__(self, url=None, api_key=None, login=True):
        if url:
            self._url = url
        else:
            self._url = self.default_url
        
        # config session object
        self.session = requests.Session()  
        self.session.trust_env = False 
        
        # MDA informations
        self.mda_attrs = {'name': '', 'discipline_attributes':''}
        self.discnames = []
        self.discattrs = []
        self.vars = {}
        self.varattrs = {}
        
        # login by default
        if login:
            self.login(api_key)

    @property
    def url(self):
        return self._url

    def _endpoint(self, path):
        return self._url + path

    @property
    def default_url(self):
        env = os.getenv("WOP_ENV")
        if env=="development":
            self._default_url = DEV_URL
        elif env=="test":
            self._default_url = TEST_URL
        elif env=="staging":
            self._default_url = STAG_URL
        else: # env=="production":
            self._default_url = PROD_URL
        return self._default_url    
            
    def _ask_and_write_api_key(self):
        print("You have to set your API key.")
        print("You can get it in your profile page on WhatsOpt (%s)." % self.url)
        print("Please, copy/paste your API key below then hit return (characters are hidden).")
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

    def login(self, api_key=None, echo=None):
        already_logged=False
        if api_key:
            self.api_key = api_key
        elif os.path.exists(API_KEY_FILENAME):
            already_logged=True
            self.api_key = self._read_api_key()
        else:
            self.api_key = self._ask_and_write_api_key()
        self.headers = {'Authorization': 'Token token=' + self.api_key, 'User-Agent': 'wop/{}'.format(__version__)}
        
        url =  self._endpoint('/api/v1/analyses')
        resp = self.session.get(url, headers=self.headers)
        if not api_key and already_logged and not resp.ok:
            self.logout(echo=False)  # log out silently, suppose one was logged on another server
            resp = self.login(api_key, echo)
        resp.raise_for_status() 
        if echo:
            print("Successfully logged into WhatsOpt (%s)" % self.url)
        return resp

    def logout(self, echo=True):
        if os.path.exists(API_KEY_FILENAME):
            os.remove(API_KEY_FILENAME)
        if echo:
            print("Sucessfully logged out from WhatsOpt (%s)" % self.url)

    def list_analyses(self):
        url =  self._endpoint('/api/v1/analyses')
        resp = self.session.get(url, headers=self.headers)
        if resp.ok:
            mdas = resp.json()
            headers = ["id", "name", "created at"]
            data = []
            for mda in mdas:
                # TODO: remove 'updated_at' once 0.10.0 deployed
                date = mda.get('created_at', None) or mda['updated_at']
                data.append([mda['id'], mda['name'], date])
            print(tabulate(data, headers))
        else:
            resp.raise_for_status()

    def execute(self, progname, func, options):
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
        Problem._post_setup_func = func(options)
        exec(code, globals_dict)

    def push_mda_cmd(self, options):
        def push_mda(prob):
            name = options['--name']
            pbname = prob.model.__class__.__name__
            if name and pbname != name:
                print("Analysis %s skipped" % pbname)
                pass # do not exit
            else:
                self.push_mda(prob, options)
                exit()
                
        return push_mda

    def push_mda(self, problem, options):
        name = problem.model.__class__.__name__
        data = _get_viewer_data(problem)
        tree = data['tree']
        # print(tree)
        connections = data['connections_list']
        # print(connections)
        self.discnames = [NULL_DRIVER_NAME]
        self.discnames.extend(self._collect_discnames_and_vars(problem.model, tree))
        # print(self.discnames)
        self._initialize_disciplines_attrs(problem, connections)
    
        #print("MDA= ", name)
        if name == 'Group':
            name = 'MDA'
        self.mda_attrs = {'name': name,
                          'disciplines_attributes': self.discattrs}    
        #print([d for d in self.discattrs if d['name'] == 'sap.Struc'])    
        #print(self.vars)
        mda_params = {'analysis': self.mda_attrs}
        if options['--dry-run']:
            print(mda_params)
        else:
            url =  self._endpoint('/api/v1/analyses')
            resp = self.session.post(url, headers=self.headers, json=mda_params)
            resp.raise_for_status()
            print("Analysis %s pushed" % name)

    def pull_mda(self, mda_id, options):
        base = '_base' if options.get('--base') else '' 
        url =  self._endpoint(('/api/v1/analyses/%s/exports/new.openmdao'+base) % mda_id)
        resp = self.session.get(url, headers=self.headers, stream=True)
        resp.raise_for_status()
        name = None
        with tempfile.NamedTemporaryFile(suffix='.zip', mode='wb', delete=False) as fd:
            for chunk in resp.iter_content(chunk_size=128):
                fd.write(chunk)
            name = fd.name
        zip = zipfile.ZipFile(name, 'r')
        tempdir = tempfile.mkdtemp(suffix='wop', dir=tempfile.tempdir)
        zip.extractall(tempdir)
        filenames = zip.namelist()
        zip.close()
        for f in filenames:
            file_from = os.path.join(tempdir, f)
            file_to = f
            if os.path.exists(file_to):
                if options.get('--force'):
                    print("Update %s" % file_to)
                    if not options.get('--dry-run'):
                        os.remove(file_to)
                else:
                    print("File %s in the way, move it or pull in another directory or use --force to overwrite" % file_to)
                    exit(-1)
            else:
                print("Pull %s" % file_to) 
        if not options.get('--dry-run'):
            for f in filenames:
                file_from = os.path.join(tempdir, f)
                dir_to = os.path.dirname(f)
                if dir_to == "":
                    dir_to = '.'
                elif not os.path.exists(dir_to):
                    os.makedirs(dir_to)
                #print("Move {} to {}".format(file_from, dir_to))
                move(file_from, dir_to)
            print('Analysis %s pulled' % mda_id)
    
    def update_mda(self, analysis_id=None):
        id = analysis_id or self.get_analysis_id()
        self.pull_mda(id, {'--base': True, '--force': True})
        
    def upload(self, sqlite_filename, analysis_id=None, operation_id=None, cleanup=False):
        from socket import gethostname
        mda_id = self.get_analysis_id() if not analysis_id else analysis_id
        reader = CaseReader(sqlite_filename)
        driver_first_coord = reader.driver_cases.get_iteration_coordinate(0)
        name = os.path.splitext(sqlite_filename)[0]
        m = re.match(r"\w+:(\w+)|.*", driver_first_coord)
        if m:
            name = m.group(1)
        cases = self._format_upload_cases(reader)
        
        resp = None
        if operation_id:
            url =  self._endpoint(('/api/v1/operations/%s') % operation_id)
            operation_params = {'cases': cases}
            resp = self.session.patch(url, headers=self.headers, 
                                      json={'operation': operation_params})
        else:
            url =  self._endpoint(('/api/v1/analyses/%s/operations') % mda_id)
            operation_params = {'name': name,
                                'driver': name.lower(),
                                'host': gethostname(),
                                'cases': cases}
            resp = self.session.post(url, headers=self.headers, 
                                     json={'operation': operation_params})
        resp.raise_for_status()
        print("Results data from %s uploaded" % sqlite_filename)
        if cleanup:
            os.remove(sqlite_filename)
            print("%s removed" % sqlite_filename)

    def check_versions(self):
        url =  self._endpoint('/api/v1/versioning')
        resp = self.session.get(url, headers=self.headers)
        resp.raise_for_status()
        version = resp.json()
        print("WhatsOpt:{} recommended wop:{}".format(version['whatsopt'], version['wop']))
        print("current wop:{}".format(__version__))
        
    def serve(self):
        from subprocess import call
        retcode = call(['python', 'run_server.py'])
        
    def get_analysis_id(self):
        files = self._find_analysis_base_files()
        id = None
        for f in files:
            ident = self._extract_mda_id(f) 
            if id and id != ident:
                raise Exception ('Warning: several analysis identifier detected. \
                                  Find %s got %s. Check header comments of %s files .' % (id, ident, str(files)))  
            id = ident    
        return id 
        
    @staticmethod
    def _find_analysis_base_files():
        files = []
        for f in os.listdir("."):
            if f.endswith("_base.py"):
                files.append(f)
        return files    
    
    @staticmethod
    def _extract_mda_id(file):
        ident = None
        with open(file, 'r') as f:
            for line in f:
                match = re.match(r"^# analysis_id: (\d+)", line) 
                if match:
                    ident = match.group(1)
                    break
        return ident
    
    @staticmethod
    def _extract_mda_name(name):
        match = re.match(r"(\w+)_\w+.sqlite", name)
        if match:
            return match.group(1)
        else:
            return 'mda'
        
    # see _get_tree_dict at
    # https://github.com/OpenMDAO/OpenMDAO/blob/master/openmdao/devtools/problem_viewer/problem_viewer.py
    def _collect_discnames_and_vars(self, system, tree, group_prefix=''):
        disciplines = []
        if 'children' in tree:
            for i, child in enumerate(tree['children']):
                # retain only components, not intermediates (subsystem or group)
                if child['type'] == 'subsystem' and child['subsystem_type'] == 'group':
                    prefix = group_prefix+child['name']+'.'
                    disciplines.extend(self._collect_discnames_and_vars(system._subsystems_myproc[i], child, prefix))
                else:
                    # do not represent IndepVarComp
                    if not isinstance(system._subsystems_myproc[i], IndepVarComp):
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
                            meta = system._var_abs2meta[abs_name]
                            vtype = 'Float'
                            if re.match('int', type(meta['value']).__name__):
                                vtype = 'Integer' 
                            disc, var, fname = WhatsOpt._extract_disc_var(abs_name)
                            self.vars[abs_name] = {'fullname': fname,
                                                   'name': system._var_abs2prom[typ][abs_name],
                                                   'io_mode': io_mode,
                                                   'type': vtype,
                                                   'shape': str(meta['shape']),
                                                   'units': meta['units'],
                                                   'desc': meta['desc']}
        disciplines = [WhatsOpt._format_name(name) for name in disciplines]
        return disciplines

    def _initialize_disciplines_attrs(self, problem, connections):
        self._initialize_variables_attrs(connections)
        self.discattrs = []
        for dname in self.discnames:
            discattr = {'name': dname, 'variables_attributes': self.varattrs[dname]}
            self.discattrs.append(discattr)

    def _initialize_variables_attrs(self, connections):
        self.varattrs = {dname: [] for dname in self.discnames}
        for conn in connections:
            self._create_varattr_from_connection(conn['src'], 'out')
            self._create_varattr_from_connection(conn['tgt'], 'in')

        self._create_varattr_for_global_outputs(connections)
            
    def _create_varattr_from_connection(self, fullname, io_mode):
        disc, var, fname = WhatsOpt._extract_disc_var(fullname)
        
        varattr = {'name':var, 'fullname': fname, 'io_mode': io_mode,
                   'type':self.vars[fullname]['type'], 'shape':self.vars[fullname]['shape'], 
                   'units':self.vars[fullname]['units'], 'desc':self.vars[fullname]['desc']}
        if disc in self.discnames: 
            if varattr not in self.varattrs[disc]: 
                self.varattrs[disc].append(varattr)
        elif varattr not in self.varattrs[NULL_DRIVER_NAME]:
            self.varattrs[NULL_DRIVER_NAME].append(varattr)
            
    def _create_varattr_for_global_outputs(self, connections):
        for fullname, varattr in iteritems(self.vars): 
            if varattr['io_mode'] == 'out':
                found = False
                for conn in connections:
                    disctgt, vartgt, fname_tgt = WhatsOpt._extract_disc_var(conn['tgt'])
                    discsrc, varsrc, fname_src = WhatsOpt._extract_disc_var(conn['src'])
                    if fname_tgt == varattr['fullname'] or \
                       fname_src == varattr['fullname']:
                        found = True
                        break
                if not found:
                    #print("Create global output connection ", varattr)
                    self._create_connection_for(fullname, varattr)
                    
    def _create_connection_for(self, fullname, varattr):
        disc, var, _ = WhatsOpt._extract_disc_var(fullname)
        if disc in self.discnames:
            fullnames = [v['fullname'] for v in self.varattrs[disc]]
            if fullname not in fullnames:
                self.varattrs[disc].append(varattr)
                varattr_in=copy.deepcopy(varattr)
                varattr_in['io_mode']='in'
                self.varattrs[NULL_DRIVER_NAME].append(varattr_in)

    
    @staticmethod
    def _format_name(name):
        return name.replace('.', '_')
    
    @staticmethod
    def _extract_disc_var(fullname):
        name_elts = fullname.split('.')
        if len(name_elts) > 1:
            disc, var = '.'.join(name_elts[:-1]), name_elts[-1] 
        else:
            raise Exception('Connection qualified name should contain' + 
                            'at least one dot, but got %s' % fullname)
        disc = WhatsOpt._format_name(disc)
        return disc, var, disc+"."+var

    def _format_upload_cases(self, reader):
        cases = reader.system_cases.list_cases()
        inputs = {}
        outputs = {}
        for i, case_id in enumerate(cases):
            case = reader.system_cases.get_case(case_id)
            if case.inputs is not None:
                self._insert_data(case.inputs, inputs)
            if case.outputs is not None:
                self._insert_data(case.outputs, outputs)
        cases = inputs.copy()
        cases.update(outputs)
        inputs_count = self._check_count(inputs)
        outputs_count = self._check_count(outputs)
        assert inputs_count==outputs_count
        data = []
        for key, values in iteritems(cases):
            idx = key[1]
            if key[2] == 1:
                idx = -1 # consider it is a scalar not an array of 1 elt
            data.append({'varname': key[0], 'coord_index': idx, 'values': values})
        return data
        
    def _check_count(self, ios):
        count = None
        for name in ios:
            if count and count != len(ios[name]):
                raise Exception('Bad value count between (%s, %d) and (%s, %d)' % \
                                (refname, count, name, len(ios[name])))
            else:
                refname, count = name, len(ios[name])
        return count
                            
    def _insert_data(self, data_io, result):
        done = {}
        for n in data_io._values.dtype.names:
            values = data_io._values[n]
            name = n.split('.')[-1]
            if name in done:
                continue
            values = values.reshape(-1)
            for i in range(values.size):
                if (name, i, values.size) in result:
                    result[(name, i, values.size)].append(float(values[i]))
                else:
                    result[(name, i, values.size)] = [float(values[i])]
            done[name]=True




