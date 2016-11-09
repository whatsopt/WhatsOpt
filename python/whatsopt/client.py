import json
import requests
from openmdao.devtools.partition_tree_n2 import get_model_viewer_data


class WhatsOpt():

    def __init__(self, url, api_key):
        self.url = url
        self.api_key = api_key
        self.headers = {'Authorization': 'Token token=' + self.api_key}

    def _url(self, path):
        return self.url + path

    def list_studies(self):
        resp = requests.get(self._url('/studies'), headers=self.headers)
        return resp.json()

    def store(self, problem):
        data = get_model_viewer_data(problem)
        study_params = {'study': {
            'tree_json': data['tree'],
            'conns_json': data['connections_list']
        }}
        resp = requests.post(
            self._url('/studies'), headers=self.headers, json=study_params)
