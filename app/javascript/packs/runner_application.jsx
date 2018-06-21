import React from 'react';
import ReactDOM from 'react-dom';
import WhatsOptApi from '../utils/WhatsOptApi';
import Runner from 'runner';

document.addEventListener('DOMContentLoaded', () => {
    let csrfToken = document.getElementsByName('csrf-token')[0].getAttribute('content');
    let relativeUrlRoot = document.getElementsByName('relative-url-root')[0].getAttribute('content');
    
    let runnerElt = $('#runner');
    let mda = runnerElt.data('mda');
    let ope = runnerElt.data('ope');
    let apiKey = runnerElt.data('api-key');
    let wsServer = runnerElt.data('ws-server');

    let api = new WhatsOptApi(csrfToken, apiKey, relativeUrlRoot); 
    
    ReactDOM.render(<Runner mda={mda} ope={ope} api={api} wsServer={wsServer}/>, runnerElt[0]);
  }
);
