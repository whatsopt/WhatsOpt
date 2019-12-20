import React from 'react';
import ReactDOM from 'react-dom';
import Plotter from 'plotter';
import WhatsOptApi from '../utils/WhatsOptApi';

document.addEventListener('DOMContentLoaded', () => {
  const csrfToken = document.getElementsByName('csrf-token')[0].getAttribute('content');
  const relativeUrlRoot = document.getElementsByName('relative-url-root')[0].getAttribute('content');

  // eslint-disable-next-line no-undef
  const plotterElt = $('#sensitivity_plotter');
  const ope = plotterElt.data('ope');
  const apiKey = plotterElt.data('api-key');

  const api = new WhatsOptApi(csrfToken, apiKey, relativeUrlRoot);
  ReactDOM.render(<SensitivityPlotter ope={ope} api={api} />, plotterElt[0]);
});
