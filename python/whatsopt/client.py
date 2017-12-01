import os
import json
import getpass
import requests
from openmdao.devtools.problem_viewer.problem_viewer import _get_viewer_data, view_model
from openmdao.core.indepvarcomp import IndepVarComp

WHATSOPT_DIRNAME = os.path.join(os.path.expanduser('~'), '.whatsopt')
API_KEY_FILENAME = os.path.join(WHATSOPT_DIRNAME, 'api_key')
DISCIPLINE_CONTROL_NAME = '__CONTROL__'  # check WhatsOpt Discipline model

class WhatsOptImportMdaError(Exception):
    pass

class WhatsOpt():
    

    def __init__(self, url, api_key=None):
        self.url = url
        if api_key:
            self.api_key = api_key
        elif os.path.exists(API_KEY_FILENAME):
            with open(API_KEY_FILENAME, 'r') as f:
                self.api_key = f.read()
        else:
            print "You have to set your API_KEY. You can get it in your profile on WhatsOpt."
            print "Please, copy/paste your api key below then hit return (characters are hidden)."
            self.api_key = getpass.getpass(prompt='Your API key: ')
            if not os.path.exists(WHATSOPT_DIRNAME):
                os.makedirs(WHATSOPT_DIRNAME)
            with open(API_KEY_FILENAME, 'w') as f:
                f.write(self.api_key)           
        self.headers = {'Authorization': 'Token token=' + self.api_key}
        
        # config session object
        self.session = requests.Session()  
        self.session.trust_env = False 

    def _url(self, path):
        return self.url + path

    def import_mda(self, problem):
        data = _get_viewer_data(problem)
        tree = data['tree']
        connections = data['connections_list']
        print data
        discnames = self._get_discipline_names(problem.model, tree)
        variables = self._create_variables(problem, discnames, connections)
        disciplines = self._create_disciplines(problem, discnames, variables)
        print variables
        name = problem.model.__class__.__name__
        if name == 'Group':
            name = 'MDA'
        mda_params = {'multi_disciplinary_analysis': 
                      {'name': name,
                       'disciplines_attributes': disciplines }}
        url =  self._url('/api/v1/multi_disciplinary_analyses')
#         resp = self.session.post(url, headers=self.headers, json=mda_params)
#         if resp.ok:
#             print resp.json()

    @staticmethod    
    def _get_discipline_names(problem, tree):
        disciplines = [DISCIPLINE_CONTROL_NAME]
        if 'children' in tree:
            for i, child in enumerate(tree['children']):
                if not isinstance(problem._subsystems_myproc[i], IndepVarComp):
                    disciplines.append(child['name'])
        return disciplines

    @staticmethod
    def _create_variables(problem, discnames, connections):
        variables = {dname: {'inputs': [], 'outputs': []} for dname in discnames}
        variables.update({DISCIPLINE_CONTROL_NAME: {'inputs': [], 'outputs': []}})
        for conn in connections:
            discsrc, varsrc = conn['src'].split('.')
            if discsrc in discnames: 
                variables[discsrc]['outputs'].append(varsrc)
            else:
                variables[DISCIPLINE_CONTROL_NAME]['outputs'].append(varsrc)
            disctgt, vartgt = conn['tgt'].split('.')
            if disctgt in discnames: 
                variables[disctgt]['inputs'].append(vartgt)
            else:
                variables[DISCIPLINE_CONTROL_NAME]['inputs'].append(vartgt)
        return variables
        