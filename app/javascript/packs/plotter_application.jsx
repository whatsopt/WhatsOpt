import React from 'react';
import { createRoot } from 'react-dom/client';

import Plotter from 'plotter';
import WhatsOptApi from '../utils/WhatsOptApi';

document.addEventListener('DOMContentLoaded', () => {
  const csrfToken = document.getElementsByName('csrf-token')[0].getAttribute('content');
  const relativeUrlRoot = document.getElementsByName('relative-url-root')[0].getAttribute('content');

  // eslint-disable-next-line no-undef
  const plotterElt = $('#plotter');
  const mda = plotterElt.data('mda');
  const ope = plotterElt.data('ope');
  const apiKey = plotterElt.data('api-key');
  const uqMode = plotterElt.data('uq-mode');

  const api = new WhatsOptApi(csrfToken, apiKey, relativeUrlRoot);

  const root = createRoot(plotterElt[0]);
  root.render(<Plotter mda={mda} ope={ope} api={api} uqMode={uqMode} />);
});
