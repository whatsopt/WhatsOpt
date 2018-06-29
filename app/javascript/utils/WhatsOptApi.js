import axios from 'axios';

class WhatsOptApi {
  
  constructor(csrfToken, apiKey, relativeUrlRoot) {
// console.log(csrfToken);
// console.log(apiKey);
// console.log(relativeUrlRoot);
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
  
  updateOperation(operationId, ope_attrs, callback, onError) {
    let path = `/api/v1/operations/${operationId}`;
    axios.patch(this.url(path), {operation: ope_attrs})
      .then(callback)
      .catch((error) => console.log(error));
  }
  
  pollOperation(operationId, check, callback, onError) {
    let path = `/api/v1/operations/${operationId}`;
    this._pollStatus(() => axios.get(this.url(path)), check, callback, 300000, 2000)
      .then(callback)
      .catch(onError);    
  }
  
  _pollStatus(fn, check, callback, timeout, interval) {
    let endTime = Number(new Date()) + (timeout || 2000);
    interval = interval || 100;

    console.log("_pollStatus");
    let checkCondition = function(resolve, reject) { 
      var ajax = fn();
      // dive into the ajax promise
      ajax.then( function(response){
        // If the condition is met, we're done!
        if (check(response.data)) {
          resolve(response);
        }
        // If the condition isn't met but the timeout hasn't elapsed, go again
        else if (Number(new Date()) < endTime) {
          callback(response);
          setTimeout(checkCondition, interval, resolve, reject);
        }
        // Didn't match and too much time, reject!
        else {
          reject(new Error('timed out for ' + fn + ': ' + arguments));
        }
      });
    };

    return new Promise(checkCondition);
  }
};

export default WhatsOptApi;
