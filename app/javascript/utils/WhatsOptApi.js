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
  constructor(csrfToken, apiKey, relativeUrlRoot, requested_at) {
    this.csrfToken = csrfToken;
    this.apiKey = apiKey;
    this.requested_at = requested_at || Date.now();
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

  analyseSensitivity(opeId, thresholding, quantile, gThreshold, callback) {
    let path = `/operations/${opeId}/sensitivity_analysis?`;
    path += `thresholding=${thresholding}`;
    path += `&quantile=${quantile}`;
    path += `&g_threshold=${gThreshold}`;
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  getProjects(callback) {
    const path = '/design_projects';
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  getUsers(mdaId, role, callback) {
    const path = `/user_roles?query[analysis_id]=${mdaId}&query[select]=${role}`;
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  getUserCandidates(mdaId, role, callback) {
    const path = `/user_roles?query[analysis_id]=${mdaId}&query[select]=${role}_candidates`;
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  addUser(userId, mdaId, role, callback) {
    const path = `/user_roles/${userId}`;
    axios.put(this.apiUrl(path), { user_role: { analysis_id: mdaId, role } })
      .then(callback)
      .catch((error) => console.log(error));
  }

  removeUser(userId, mdaId, role, callback) {
    const path = `/user_roles/${userId}`;
    axios.delete(this.apiUrl(path), { data: { user_role: { analysis_id: mdaId, role } } })
      .then(callback)
      .catch((error) => console.log(error));
  }

  updateUserSettings(userId, settings, callback) {
    const path = `/users/${userId}`;
    axios.put(this.apiUrl(path), { user: { settings } })
      .then(callback)
      .catch((error) => console.log(error));
  }

  // format: whatsopt_ui, xdsm, wopjson or false
  getAnalysis(mdaId, format, callback) {
    let path = `/analyses/${mdaId}`;
    if (format) {
      path += `.${format}`;
    }
    axios.get(this.apiUrl(path))
      .then((response) => {
        // Here we set the update time of the MDA as we requested it
        // This field is used to implement optimistic lock on the mda
        // when co_owners do concurrent editing
        if (format === 'whatsopt_ui') {
          this.requested_at = response.data.updated_at;
        }
        callback(response);
      })
      .catch((error) => console.log(error));
  }

  getAnalysisHistory(mdaId, callback) {
    const path = `/analyses/${mdaId}/journal`;
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  updateAnalysis(mdaId, mdaAttrs, callback, onError) {
    const path = `/analyses/${mdaId}`;
    axios.put(this.apiUrl(path), { analysis: mdaAttrs, requested_at: this.requested_at })
      .then((response) => {
        // Here we set the update time of the MDA as we requested it
        // This field is used to implement optimistic lock on the mda
        // when co_owners do concurrent editing
        this.requested_at = response.data.updated_at;
        callback(response);
      })
      .catch(onError);
  }

  compareAnalyses(mdaId, otherMdaId, callback) {
    const path = `/analyses/${mdaId}/comparisons/new?with=${otherMdaId}`;
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  getDisciplines(mdaId, callback) {
    const path = `/analyses/${mdaId}/disciplines`;
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  getVariables(mdaId, callback) {
    const path = `/analyses/${mdaId}/variables`;
    axios.get(this.apiUrl(path))
      .then(callback)
      .catch((error) => console.log(error));
  }

  importDiscipline(fromMdaId, discId, toMdaId, callback, onError) {
    const path = `/analyses/${toMdaId}`;
    this.getAnalysis(toMdaId, false, (response) => {
      const { updated_at } = response.data;
      axios.put(this.apiUrl(path), {
        analysis: {
          import: {
            analysis: fromMdaId, disciplines: [discId],
          },
        },
        requested_at: updated_at,
      })
        .then(callback)
        .catch(onError);
    });
  }

  createDiscipline(mdaId, disciplineAttributes, callback, onError) {
    const path = `/analyses/${mdaId}/disciplines`;
    axios.post(this.apiUrl(path), {
      discipline: disciplineAttributes,
      requested_at: this.requested_at,
    })
      .then(callback)
      .catch(onError);
  }

  updateDiscipline(mdaId, discId, disciplineAttributes, callback, onError) {
    const path = `/analyses/${mdaId}/disciplines/${discId}`;
    axios.put(this.apiUrl(path), {
      discipline: disciplineAttributes,
      requested_at: this.requested_at,
    })
      .then(callback)
      .catch(onError);
  }

  deleteDiscipline(mdaId, discId, callback, onError) {
    const path = `/analyses/${mdaId}/disciplines/${discId}`;
    axios.delete(this.apiUrl(path), {
      data: {
        requested_at: this.requested_at,
      },
    })
      .then(callback)
      .catch(onError);
  }

  getAnalysisCandidates(callback, query) {
    let option = '';
    if (query === 'all') {
      option = '?all=true';
    } else if (query === 'owned') {
      option = '?owned=true';
    }
    const path = `/analyses${option}`;
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

  createConnection(mdaId, connectionAttributes, callback, onError) {
    const path = `/analyses/${mdaId}/connections`;
    axios.post(this.apiUrl(path), {
      connection: connectionAttributes,
      requested_at: this.requested_at,
    })
      .then(callback)
      .catch(onError);
  }

  updateConnection(mdaId, connectionId, connectionAttributes, callback, onError) {
    const path = `/analyses/${mdaId}/connections/${connectionId}`;
    axios.put(this.apiUrl(path), {
      connection: connectionAttributes,
      requested_at: this.requested_at,
    })
      .then(callback)
      .catch(onError);
  }

  deleteConnection(mdaId, connectionId, callback, onError) {
    const path = `/analyses/${mdaId}/connections/${connectionId}`;
    axios.delete(this.apiUrl(path), {
      data: {
        requested_at: this.requested_at,
      },
    })
      .then(callback)
      .catch(onError);
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

  updateOpenmdaoImpl(mdaId, implAttrs, callback, onError) {
    const path = `/analyses/${mdaId}/openmdao_impl`;
    axios.patch(this.apiUrl(path), {
      openmdao_impl: implAttrs,
      requested_at: this.requested_at,
    })
      .then(() => this.getAnalysis(mdaId, false, (response) => {
        // Here we set the update time of the MDA as we requested it
        // This field is used to implement optimistic lock on the mda
        // when co_owners do concurrent editing
        this.requested_at = response.data.updated_at;
        callback();
      }))
      .catch(onError);
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
}

export default WhatsOptApi;
