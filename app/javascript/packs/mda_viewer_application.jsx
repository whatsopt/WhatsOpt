import React from 'react';
import ReactDOM from 'react-dom';
import WhatsOptApi from '../utils/WhatsOptApi';
import MdaViewer from 'mda_viewer';

document.addEventListener('DOMContentLoaded', () => {
    let csrfToken = document.getElementsByName('csrf-token')[0].getAttribute('content');
    let relativeUrlRoot = document.getElementsByName('relative-url-root')[0].getAttribute('content');
    
    let mdaViewerElt = $('#mda-viewer');
    let mda = mdaViewerElt.data('mda');
    let isEditing = mdaViewerElt.data('is-editing');
    let apiKey = mdaViewerElt.data('api-key');
    
    let api = new WhatsOptApi(csrfToken, apiKey, relativeUrlRoot); 
    
    ReactDOM.render(<MdaViewer mda={mda} isEditing={isEditing} api={api}/>, mdaViewerElt[0]);
  }
);
