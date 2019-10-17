import React from 'react';
import ReactDOM from 'react-dom';
import WhatsOptApi from '../utils/WhatsOptApi';
import SwaggerApiDoc from 'api_doc_viewer';

document.addEventListener('DOMContentLoaded', () => {
  const csrfToken = document.getElementsByName('csrf-token')[0].getAttribute('content');
  const relativeUrlRoot = document.getElementsByName('relative-url-root')[0].getAttribute('content');

  const runnerElt = $('#apidoc');
  const mda = runnerElt.data('mda');
  const ope = runnerElt.data('ope');
  const apiKey = runnerElt.data('api-key');
  const wsServer = runnerElt.data('ws-server');

  const api = new WhatsOptApi(csrfToken, apiKey, relativeUrlRoot);

  ReactDOM.render(<SwaggerApiDoc api={api} />, runnerElt[0]);
}
);
