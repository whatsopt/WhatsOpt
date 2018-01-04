import os
import sys
import json
import getpass
import requests
from openmdao.devtools.problem_viewer.problem_viewer import _get_viewer_data, view_model
from openmdao.core.indepvarcomp import IndepVarComp
from openmdao.core.problem import Problem
from openmdao.core.group import Group

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
        print "You have to set your API_KEY. You can get it in your profile on WhatsOpt."
        print "Please, copy/paste your api key below then hit return (characters are hidden)."
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
        print "Try to push MDA to "+self.url
        data = _get_viewer_data(problem)
        tree = data['tree']
        print tree
        connections = data['connections_list']
        print connections
        discnames = [NULL_DRIVER_NAME]
        discnames.extend(self._get_discipline_names(problem.model, tree))
        print discnames
        disciplines_attrs = self._create_disciplines_attrs(problem, discnames, connections)
        name = problem.model.__class__.__name__
        if name == 'Group':
            name = 'MDA'
        mda_params = {'multi_disciplinary_analysis': 
                      {'name': name,
                       'disciplines_attributes': disciplines_attrs}}
        url =  self._url('/api/v1/multi_disciplinary_analyses')
        resp = self.session.post(url, headers=self.headers, json=mda_params)
        if resp.ok:
            print resp.json()
        else:
            print resp

    @staticmethod    
    def _get_discipline_names(system, tree):
        disciplines = []
        if 'children' in tree:
            for i, child in enumerate(tree['children']):
                if not isinstance(system._subsystems_myproc[i], IndepVarComp):
                    if child['type'] == 'subsystem' and child['subsystem_type'] == 'group':
                        disciplines.extend(WhatsOpt._get_discipline_names(system._subsystems_myproc[i], child))
                    else:
                        disciplines.append(child['name'])
        return disciplines

    @staticmethod
    def _create_disciplines_attrs(problem, discnames, connections):
        variables_attrs = WhatsOpt._create_variables_attrs(problem, discnames, connections)
        print variables_attrs
        disciplines_attrs = []
        for dname in discnames:
            disc = {'name': dname, 'variables_attributes': variables_attrs[dname]}
            disciplines_attrs.append(disc)
        return disciplines_attrs

    @staticmethod
    def _create_variables_attrs(problem, discnames, connections):
        varattrs = {dname: [] for dname in discnames}
        varattrs.update({NULL_DRIVER_NAME: []})
        for conn in connections:
            name_elts = conn['src'].split('.')
            nelt = len(name_elts)
            if nelt > 1:
                discsrc, varsrc = '.'.join(name_elts[:-1]), name_elts[-1] 
            else:
                raise Exception('Connection qualified name should contain at least one dot, but got %s' % conn['src'])
            if discsrc in discnames: 
                varattrs[discsrc].append({'name':varsrc, 'io_mode':'out'})
            else:
                varattrs[NULL_DRIVER_NAME].append({'name':varsrc, 'io_mode':'out'})
                
            if nelt > 1:
                disctgt, vartgt = '.'.join(name_elts[:-1]), name_elts[-1] 
            else:
                raise Exception('Connection qualified name should contain at least one dot, but got %s' % conn['tgt'])
            if disctgt in discnames: 
                varattrs[disctgt].append({'name':vartgt, 'io_mode':'in'})
            else:
                varattrs[NULL_DRIVER_NAME].append({'name':vartgt, 'io_mode':'in'})
        return varattrs
    
            
            