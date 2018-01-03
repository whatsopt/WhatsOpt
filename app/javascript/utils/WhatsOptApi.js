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
  
  openmdao_checking(mda_id, callback) {
    let path = '/api/v1/openmdao_checking';
    axios.post(url(path), {mda_id: mda_id})
      .then(callback)
      .catch(error => console.log(error));
  };
  
  create_discipline(mda_id, discipline_attributes, callback) {
    let path = `/api/v1/${mda_id}/disciplines`;
    axios.post(url(path), {discipline_attributes: discipline_attributes})
      .then(callback)
      .catch(error => console.log(error));
  }
  
};

let api = new WhatsOptApi();

export {api, url};