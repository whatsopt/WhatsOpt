import axios from 'axios';

class WhatsOptApi {
  constructor(csrfToken, apiKey, relativeUrlRoot) {
    axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;
    axios.defaults.headers.common['Accept'] = 'application/json';
    axios.defaults.headers.common['Authorization'] = 'Token '+apiKey;
    this.relativeUrlRoot = relativeUrlRoot;
  }

  url(path) {
    return this.relativeUrlRoot + path;
  };

  openmdaoChecking(mdaId, callback) {
    const path = `/api/v1/analyses/${mdaId}/openmdao_checking`;
    axios.post(this.url(path))
        .then(callback)
        .catch((error) => console.log(error));
  };

  getMemberCandidates(mdaId, callback) {
    const path = `/api/v1/user_roles?query[analysis_id]=${mdaId}&query[select]=member_candidates`;
    axios.get(this.url(path))
        .then(callback)
        .catch((error) => console.log(error));
  }

  addMember(userId, mdaId, callback) {
    const path = `/api/v1/user_roles/${userId}`;
    axios.put(this.url(path), {user: {analysis_id: mdaId, role: 'member'}})
        .then(callback)
        .catch((error) => console.log(error));
  }

  removeMember(userId, mdaId, callback) {
    const path = `/api/v1/user_roles/${userId}`;
    axios.put(this.url(path), {user: {analysis_id: mdaId, role: 'none'}})
        .then(callback)
        .catch((error) => console.log(error));
  }

  updateUserSettings(userId, settings, callback) {
    const path = `/api/v1/users/${userId}`;
    axios.put(this.url(path), {user: {settings: settings}})
        .then(callback)
        .catch((error) => console.log(error));
  }

  getAnalysis(mdaId, xdsmFormat, callback) {
    let path = `/api/v1/analyses/${mdaId}`;
    if (xdsmFormat) {
      path += '.xdsm';
    }
    axios.get(this.url(path))
        .then(callback)
        .catch((error) => console.log(error));
  };

  updateAnalysis(mdaId, mdaAttrs, callback, onError) {
    const path = `/api/v1/analyses/${mdaId}`;
    axios.put(this.url(path), {analysis: mdaAttrs})
        .then(callback)
        .catch(onError);
  }

  createDiscipline(mdaId, disciplineAttributes, callback) {
    const path = `/api/v1/analyses/${mdaId}/disciplines`;
    axios.post(this.url(path), {discipline: disciplineAttributes})
        .then(callback)
        .catch((error) => console.log(error));
  }

  updateDiscipline(discId, disciplineAttributes, callback) {
    const path = `/api/v1/disciplines/${discId}`;
    axios.put(this.url(path), {discipline: disciplineAttributes})
        .then(callback)
        .catch((error) => console.log(error));
  }

  deleteDiscipline(discId, callback) {
    const path = `/api/v1/disciplines/${discId}`;
    axios.delete(this.url(path))
        .then(callback)
        .catch((error) => console.log(error));
  }

  getSubAnalysisCandidates(callback) {
    const path = `/api/v1/analyses`;
    axios.get(this.url(path))
        .then(callback)
        .catch((error) => console.log(error));
  }
  
  createSubAnalysisDiscipline(discId, subMdaId, callback) {
    const path = `/api/v1/disciplines/${discId}/analysis_discipline`;
    axios.post(this.url(path), {analysis_discipline: {analysis_id: subMdaId}})
        .then(callback)
        .catch((error) => console.log(error));    
  }
  
  createConnection(mdaId, connectionAttributes, callback, onError) {
    const path = `/api/v1/analyses/${mdaId}/connections`;
    axios.post(this.url(path), {connection: connectionAttributes})
        .then(callback)
        .catch(onError);
  }

  updateConnection(connectionId, connectionAttributes, callback, onError) {
    const path = `/api/v1/connections/${connectionId}`;
    axios.put(this.url(path), {connection: connectionAttributes})
        .then(callback)
        .catch(onError);
  }

  deleteConnection(connectionId, callback) {
    const path = `/api/v1/connections/${connectionId}`;
    axios.delete(this.url(path))
        .then(callback)
        .catch((error) => console.log(error));
  }

  getOperation(operationId, callback) {
    const path = `/api/v1/operations/${operationId}`;
    axios.get(this.url(path))
        .then(callback)
        .catch((error) => console.log(error));
  }

  updateOperation(operationId, opeAttrs, callback, onError) {
    const path = `/api/v1/operations/${operationId}`;
    const jobpath = `${path}/job`;
    axios.patch(this.url(path), {operation: opeAttrs})
        .then(() => axios.post(this.url(jobpath)).then(callback).catch((error) => console.log(error)))
        .catch((error) => console.log(error));
  }

  killOperationJob(operationId) {
    const path = `/api/v1/operations/${operationId}/job`;
    axios.patch(this.url(path))
        .then((resp) => console.log(resp))
        .catch((error) => console.log(error));
  }

  pollOperationJob(operationId, check, callback, onError) {
    const path = `/api/v1/operations/${operationId}/job`;
    this._pollStatus(() => axios.get(this.url(path)), check, callback, 300000, 2000)
        .then(callback)
        .catch(onError);
  }

  _pollStatus(fn, check, callback, timeout, interval) {
    const endTime = Number(new Date()) + (timeout || 2000);
    interval = interval || 100;
    const checkCondition = function(resolve, reject) {
      var ajax = fn();
      ajax.then( function(response) {
        // If the condition is met, we're done!
        if (check(response.data)) {
          resolve(response.data);
        }
        // If the condition isn't met but the timeout hasn't elapsed, go again
        else if (Number(new Date()) < endTime) {
          callback(response.data);
          setTimeout(checkCondition, interval, resolve, reject);
        }
        // Didn't match and too much time, reject!
        else {
          reject(new Error('timed out for ' + fn));
        }
      });
    };

    return new Promise(checkCondition);
  }
};

export default WhatsOptApi;
