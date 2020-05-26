import axios from 'axios';
import { trackPromise } from 'react-promise-tracker';

const API_URL = '/api/v1';


function _pollStatus(fn, check, callback, timeout, interval) {
  const endTime = Number(new Date()) + (timeout || 2000);
  const interv = interval || 100;
  const checkCondition = (resolve, reject) => {
    const ajax = fn();
    ajax.then((response) => {
      if (check(response.data)) {
        // If the condition is met, we're done!
        resolve(response.data);
      } else if (Number(new Date()) < endTime) {
        // If the condition isn't met but the timeout hasn't elapsed, go again
        callback(response.data);
        setTimeout(checkCondition, interv, resolve, reject);
      } else {
        // Didn't match and too much time, reject!
        reject(new Error(`timed out for ${fn}`));
      }
    });
  };

  return new Promise(checkCondition);
}

class WhatsOptApi {
  constructor(csrfToken, apiKey, relativeUrlRoot) {
    this.csrfToken = csrfToken;
    this.apiKey = apiKey;
    axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;
    axios.defaults.headers.common.Accept = 'application/json';
    axios.defaults.headers.common.Authorization = `Token ${apiKey}`;
    this.relativeUrlRoot = relativeUrlRoot;
  }

  url(path) {
    return `${this.relativeUrlRoot}${path}`;
  }

  apiUrl(path) {
    return `${this.relativeUrlRoot}${API_URL}${path}`;
  }

  // eslint-disable-next-line class-methods-use-this
  docUrl() {
    return this.url('/api_doc/v1/swagger.yaml');
  }

  openmdaoChecking(mdaId, callback) {
    const path = `/analyses/${mdaId}/openmdao_checking`;
    axios.post(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  analyseSensitivity(opeId, callback) {
    const path = `/operations/${opeId}/sensitivity_analysis`;
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  getMemberCandidates(mdaId, callback) {
    const path = `/user_roles?query[analysis_id]=${mdaId}&query[select]=member_candidates`;
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  addMember(userId, mdaId, callback) {
    const path = `/user_roles/${userId}`;
    axios.put(this.apiUrl(path), { user: { analysis_id: mdaId, role: 'member' } })
      .then(callback)
      .catch((error) => console.log(error));
  }

  removeMember(userId, mdaId, callback) {
    const path = `/user_roles/${userId}`;
    axios.put(this.apiUrl(path), { user: { analysis_id: mdaId, role: 'none' } })
      .then(callback)
      .catch((error) => console.log(error));
  }

  updateUserSettings(userId, settings, callback) {
    const path = `/users/${userId}`;
    axios.put(this.apiUrl(path), { user: { settings } })
      .then(callback)
      .catch((error) => console.log(error));
  }

  getAnalysis(mdaId, xdsmFormat, callback) {
    let path = `/analyses/${mdaId}`;
    if (xdsmFormat) {
      path += '.whatsopt_ui';
    }
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  updateAnalysis(mdaId, mdaAttrs, callback, onError) {
    const path = `/analyses/${mdaId}`;
    axios.put(this.apiUrl(path), { analysis: mdaAttrs })
      .then(callback)
      .catch(onError);
  }

  importDiscipline(fromMdaId, discId, toMdaId, callback, onError) {
    const path = `/analyses/${toMdaId}`;
    axios.put(this.apiUrl(path), {
      analysis: {
        import: {
          analysis: fromMdaId, disciplines: [discId],
        },
      },
    })
      .then(callback)
      .catch(onError);
  }

  createDiscipline(mdaId, disciplineAttributes, callback, onError) {
    const path = `/analyses/${mdaId}/disciplines`;
    axios.post(this.apiUrl(path), { discipline: disciplineAttributes })
      .then(callback)
      .catch(onError);
  }

  updateDiscipline(discId, disciplineAttributes, callback, onError) {
    const path = `/disciplines/${discId}`;
    axios.put(this.apiUrl(path), { discipline: disciplineAttributes })
      .then(callback)
      .catch(onError);
  }

  deleteDiscipline(discId, callback) {
    const path = `/disciplines/${discId}`;
    axios.delete(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  getAnalysisToExportTo(callback) {
    const path = '/analyses?with_sub_analyses=true';
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  getSubAnalysisCandidates(callback) {
    const path = '/analyses';
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  createSubAnalysisDiscipline(discId, subMdaId, callback) {
    const path = `/disciplines/${discId}/analysis_discipline`;
    axios.post(this.apiUrl(path), { analysis_discipline: { analysis_id: subMdaId } })
      .then(callback)
      .catch((error) => console.log(error));
  }

  createConnection(mdaId, connectionAttributes, callback, onError) {
    const path = `/analyses/${mdaId}/connections`;
    axios.post(this.apiUrl(path), { connection: connectionAttributes })
      .then(callback)
      .catch(onError);
  }

  updateConnection(connectionId, connectionAttributes, callback, onError) {
    const path = `/connections/${connectionId}`;
    axios.put(this.apiUrl(path), { connection: connectionAttributes })
      .then(callback)
      .catch(onError);
  }

  deleteConnection(connectionId, callback) {
    const path = `/connections/${connectionId}`;
    axios.delete(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  getOperation(operationId, callback) {
    const path = `/operations/${operationId}`;
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  updateOperation(operationId, opeAttrs, callback) {
    const path = `/operations/${operationId}`;
    const jobpath = `${path}/job`;
    axios.patch(this.apiUrl(path), { operation: opeAttrs })
      .then(() => axios.post(this.apiUrl(jobpath))
        .then(callback).catch((error) => console.log(error)))
      .catch((error) => console.log(error));
  }

  killOperationJob(operationId) {
    const path = `/operations/${operationId}/job`;
    axios.patch(this.apiUrl(path))
      .then((resp) => console.log(resp))
      .catch((error) => console.log(error));
  }

  pollOperationJob(operationId, check, callback, onError) {
    const path = `/operations/${operationId}/job`;
    _pollStatus(() => axios.get(this.apiUrl(path)), check, callback, 300000, 2000)
      .then(callback)
      .catch(onError);
  }

  getOpenmdaoImpl(mdaId, callback) {
    const path = `/analyses/${mdaId}/openmdao_impl`;
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  updateOpenmdaoImpl(mdaId, implAttrs, callback) {
    const path = `/analyses/${mdaId}/openmdao_impl`;
    axios.patch(this.apiUrl(path), { openmdao_impl: implAttrs })
      .then(callback)
      .catch((error) => console.log(error));
  }

  createMetaModel(opeId, mmAttrs, callback, onError) {
    const path = `/operations/${opeId}/meta_models`;
    trackPromise(
      axios.post(this.apiUrl(path), { meta_model: mmAttrs })
        .then(callback)
        .catch(onError),
    );
  }

  getMetaModelPredictionQuality(metaModelId, callback, onError) {
    const path = `/meta_models/${metaModelId}/prediction_quality`;
    trackPromise(
      axios.get(this.apiUrl(path))
        .then(callback)
        .catch(onError),
    );
  }

  getApiDocs() {
    const path = '/api/v1/docs';
    axios.post(this.apiUrl(path))
      .catch((error) => console.log(error));
  }
}


export default WhatsOptApi;
