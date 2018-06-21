import axios from 'axios';

class WhatsOptApi {
  
  constructor(csrfToken, apiKey, relativeUrlRoot) {
//    console.log(csrfToken);
//    console.log(apiKey);
//    console.log(relativeUrlRoot);
    axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;
    axios.defaults.headers.common['Accept'] = 'application/json';
    axios.defaults.headers.common['Authorization'] = 'Token '+apiKey;
    this.relativeUrlRoot = relativeUrlRoot;
  }
  
  url(path) {
    return this.relativeUrlRoot + path;
  };
  
  openmdaoChecking(mdaId, callback) {
    let path = `/api/v1/analyses/${mdaId}/openmdao_checking`;
    axios.post(this.url(path))
      .then(callback)
      .catch((error) => console.log(error));
  };

  getAnalysisXdsm(mdaId, callback) {
    let path = `/api/v1/analyses/${mdaId}.xdsm`;
    axios.get(this.url(path))
      .then(callback)
      .catch((error) => console.log(error));
  };

  createDiscipline(mdaId, disciplineAttributes, callback) {
    let path = `/api/v1/analyses/${mdaId}/disciplines`;
    axios.post(this.url(path), {discipline: disciplineAttributes})
      .then(callback)
      .catch((error) => console.log(error));
  }

  updateDiscipline(discId, disciplineAttributes, callback) {
    let path = `/api/v1/disciplines/${discId}`;
    axios.put(this.url(path), {discipline: disciplineAttributes})
      .then(callback)
      .catch((error) => console.log(error));
  }

  deleteDiscipline(discId, callback) {
    let path = `/api/v1/disciplines/${discId}`;
    axios.delete(this.url(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  updateAnalysis(mdaId, mdaAttrs, callback) {
    let path = `/api/v1/analyses/${mdaId}`;
    axios.put(this.url(path), {analysis: mdaAttrs})
      .then(callback)
      .catch((error) => console.log(error));
  }

  createConnection(mdaId, connectionAttributes, callback, onError) {
    let path = `/api/v1/analyses/${mdaId}/connections`;
    axios.post(this.url(path), {connection: connectionAttributes})
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
    axios.delete(this.url(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  getOperation(operationId) {
    let path = `/api/v1/operations/${operationId}`;
    axios.get(this.url(path))
      .then(callback)
      .catch((error) => console.log(error));
  }
  
  updateOperation(operationId, host, callback, onError) {
    let path = `/api/v1/operations/${operationId}`;
    axios.patch(this.url(path), {operation: host})
      .then(callback)
      .catch((error) => console.log(error));
  }
};

export default WhatsOptApi;
