import React from 'react';
import { createRoot } from 'react-dom/client';

import SwaggerApiDoc from 'api_doc_viewer';
import WhatsOptApi from '../utils/WhatsOptApi';

document.addEventListener('DOMContentLoaded', () => {
  const csrfToken = document.getElementsByName('csrf-token')[0].getAttribute('content');
  const relativeUrlRoot = document.getElementsByName('relative-url-root')[0].getAttribute('content');

  // eslint-disable-next-line no-undef
  const runnerElt = $('#apidoc');
  const apiKey = runnerElt.data('api-key');
  // const wsServer = runnerElt.data('ws-server');

  const api = new WhatsOptApi(csrfToken, apiKey, relativeUrlRoot);

  const root = createRoot(runnerElt[0]);
  root.render(<SwaggerApiDoc api={api} />);
});
