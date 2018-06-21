import React from 'react';
import ReactDOM from 'react-dom';
import WhatsOptApi from '../utils/WhatsOptApi';
import Plotter from 'plotter';

document.addEventListener('DOMContentLoaded', () => {
    let csrfToken = document.getElementsByName('csrf-token')[0].getAttribute('content');
    let relativeUrlRoot = document.getElementsByName('relative-url-root')[0].getAttribute('content');

    let plotterElt = $('#plotter');
    let mda = plotterElt.data('mda');
    let ope = plotterElt.data('ope');
    let apiKey = plotterElt.data('api-key');

    let api = new WhatsOptApi(csrfToken, apiKey, relativeUrlRoot); 
    
    ReactDOM.render(<Plotter mda={mda} ope={ope} api={api}/>, plotterElt[0]);
  }
);
