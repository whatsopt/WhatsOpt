import axios from 'axios';

let token = document.getElementsByName('csrf-token')[0].getAttribute('content')
axios.defaults.headers.common['X-CSRF-Token'] = token
axios.defaults.headers.common['Accept'] = 'application/json'
axios.defaults.headers.common['Authorization'] = 'Token '+API_KEY

let relative_url_root = document.getElementsByName('relative-url-root')[0].getAttribute('content')
// axios.defaults.baseURL = 'http://endymion:3000'

// prepend relative_url_root
function url(path) {
  return relative_url_root + path;
};

class WhatsOptApi {
  
  openmdaoChecking(mdaId, callback) {
    let path = `/api/v1/analyses/${mdaId}/openmdao_checking`;
    axios.post(url(path))
      .then(response => callback(response))
      .catch(error => console.log(error));
  };
  
  createDiscipline(mdaId, discipline_attributes, callback) {
    let path = `/api/v1/analyses/${mdaId}/disciplines`;
    axios.post(url(path), {discipline: discipline_attributes})
      .then(response => callback(response))
      .catch(error => console.log(error));
  }
  
  deleteDiscipline(discId, callback) {
    let path = `/api/v1/disciplines/${discId}`;
    axios.delete(url(path))
      .then(response => callback(response))
      .catch(error => console.log(error));
  }
  
  updateAnalysis(mdaId, mdaAttrs, callback) {
    let path = `/api/v1/analyses/${mdaId}`;
    axios.put(url(path), {analysis: mdaAttrs})
      .then(response => callback(response))
      .catch(error => console.log(error));
  }

};

let api = new WhatsOptApi();

export {api, url};