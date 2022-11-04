import React from 'react';
import { createRoot } from 'react-dom/client';

import SensitivityPlotter from 'sensitivity_plotter';
import WhatsOptApi from '../utils/WhatsOptApi';

document.addEventListener('DOMContentLoaded', () => {
  const csrfToken = document.getElementsByName('csrf-token')[0].getAttribute('content');
  const relativeUrlRoot = document.getElementsByName('relative-url-root')[0].getAttribute('content');

  // eslint-disable-next-line no-undef
  const plotterElt = $('#sensitivity_plotter');
  const mda = plotterElt.data('mda');
  const ope = plotterElt.data('ope');
  const apiKey = plotterElt.data('api-key');

  const api = new WhatsOptApi(csrfToken, apiKey, relativeUrlRoot);

  const root = createRoot(plotterElt[0]);
  root.render(<SensitivityPlotter mda={mda} ope={ope} api={api} />);
});
