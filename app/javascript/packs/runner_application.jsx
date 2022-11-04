import React from 'react';
import { createRoot } from 'react-dom/client';

import Runner from 'runner';
import WhatsOptApi from '../utils/WhatsOptApi';

document.addEventListener('DOMContentLoaded', () => {
  const csrfToken = document.getElementsByName('csrf-token')[0].getAttribute('content');
  const relativeUrlRoot = document.getElementsByName('relative-url-root')[0].getAttribute('content');

  // eslint-disable-next-line no-undef
  const runnerElt = $('#runner');
  const mda = runnerElt.data('mda');
  const ope = runnerElt.data('ope');
  const apiKey = runnerElt.data('api-key');
  const wsServer = runnerElt.data('ws-server');

  const api = new WhatsOptApi(csrfToken, apiKey, relativeUrlRoot);

  const root = createRoot(runnerElt[0]);
  root.render(<Runner mda={mda} ope={ope} api={api} wsServer={wsServer} />);
});
