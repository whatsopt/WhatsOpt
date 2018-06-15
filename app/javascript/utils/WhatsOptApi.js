import axios from 'axios';

let token = document.getElementsByName('csrf-token')[0].getAttribute('content');
axios.defaults.headers.common['X-CSRF-Token'] = token;
axios.defaults.headers.common['Accept'] = 'application/json';
axios.defaults.headers.common['Authorization'] = 'Token '+API_KEY;

let relativeUrlRoot = document.getElementsByName('relative-url-root')[0].getAttribute('content');
// axios.defaults.baseURL = 'http://endymion:3000'

// prepend relative_url_root
function url(path) {
  return relativeUrlRoot + path;
};

class WhatsOptApi {
  openmdaoChecking(mdaId, callback) {
    let path = `/api/v1/analyses/${mdaId}/openmdao_checking`;
    axios.post(url(path))
      .then(callback)
      .catch((error) => console.log(error));
  };

  getAnalysisXdsm(mdaId, callback) {
    let path = `/api/v1/analyses/${mdaId}.xdsm`;
    axios.get(url(path))
      .then(callback)
      .catch((error) => console.log(error));
  };

  createDiscipline(mdaId, disciplineAttributes, callback) {
    let path = `/api/v1/analyses/${mdaId}/disciplines`;
    axios.post(url(path), {discipline: disciplineAttributes})
      .then(callback)
      .catch((error) => console.log(error));
  }

  updateDiscipline(discId, disciplineAttributes, callback) {
    let path = `/api/v1/disciplines/${discId}`;
    axios.put(url(path), {discipline: disciplineAttributes})
      .then(callback)
      .catch((error) => console.log(error));
  }

  deleteDiscipline(discId, callback) {
    let path = `/api/v1/disciplines/${discId}`;
    axios.delete(url(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  updateAnalysis(mdaId, mdaAttrs, callback) {
    let path = `/api/v1/analyses/${mdaId}`;
    axios.put(url(path), {analysis: mdaAttrs})
      .then(callback)
      .catch((error) => console.log(error));
  }

  createConnection(mdaId, connectionAttributes, callback, onError) {
    let path = `/api/v1/analyses/${mdaId}/connections`;
    axios.post(url(path), {connection: connectionAttributes})
      .then(callback)
      .catch(onError);
  }

  updateConnection(connectionId, connectionAttributes, callback, onError) {
    let path = `/api/v1/connections/${connectionId}`;
    axios.put(url(path), {connection: connectionAttributes})
      .then(callback)
      .catch(onError);
  }

  deleteConnection(connectionId, callback) {
    let path = `/api/v1/connections/${connectionId}`;
    axios.delete(url(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  getOperation(operationId) {
    let path = `/api/v1/operations/${operationId}`;
    axios.get(url(path))
      .then(callback)
      .catch((error) => console.log(error));
  }
  
  updateOperation(operationId, host, callback, onError) {
    let path = `/api/v1/operations/${operationId}`;
    axios.patch(url(path), {hostname_or_ip: host})
      .then(callback)
      .catch((error) => console.log(error));
  }
};

let api = new WhatsOptApi();

export {api, url};
