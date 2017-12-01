import os
import json
import getpass
import requests
from openmdao.devtools.problem_viewer.problem_viewer import _get_viewer_data, view_model
from openmdao.core.indepvarcomp import IndepVarComp

class WhatsOpt():
    
    WHATSOPT_DIRNAME = os.path.join(os.path.expanduser('~'), '.whatsopt')
    API_KEY_FILENAME = os.path.join(WHATSOPT_DIRNAME, 'api_key')

    def __init__(self, url, api_key=None):
        self.url = url
        if api_key:
            self.api_key = api_key
        elif os.path.exists(self.API_KEY_FILENAME):
            with open(self.API_KEY_FILENAME, 'r') as f:
                self.api_key = f.read()
        else:
            print "You have to set your API_KEY. You can get it in your profile on WhatsOpt."
            print "Please, copy/paste your api key below then hit return (characters are hidden)."
            self.api_key = getpass.getpass(prompt='Your API key: ')
            if not os.path.exists(self.WHATSOPT_DIRNAME):
                os.makedirs(self.WHATSOPT_DIRNAME)
            with open(self.API_KEY_FILENAME, 'w') as f:
                f.write(self.api_key)           
        self.headers = {'Authorization': 'Token token=' + self.api_key}

    def _url(self, path):
        return self.url + path

    def import_mda(self, problem):
        data = _get_viewer_data(problem)
        tree = data['tree']
        print tree
        self.disciplines = self._create_disciplines(problem.model, tree)
        name = problem.model.__class__.__name__
        if name == 'Group':
            name = 'MDA'
        mda_params = {'multi_disciplinary_analysis': 
                      {'name': name,
                       'disciplines_attributes': self.disciplines }}
        resp = requests.post(self._url('/api/v1/multi_disciplinary_analyses'), 
                             headers=self.headers, json=mda_params)
        print resp.status_code, resp.json()

    @staticmethod    
    def _create_disciplines(problem, tree):
        disciplines = []
        if 'children' in tree:
            for i, child in enumerate(tree['children']):
                if not isinstance(problem._subsystems_myproc[i], IndepVarComp):
                    disc = {'name': child['name']}
                    disciplines.append(disc)
        return disciplines
