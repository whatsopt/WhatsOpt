import React from 'react';
import ReactDOM from 'react-dom';
import WhatsOptApi from '../utils/WhatsOptApi';
import MdaViewer from 'mda_viewer';
import '@rails/actiontext'

document.addEventListener('DOMContentLoaded', () => {
  const csrfToken = document.getElementsByName('csrf-token')[0].getAttribute('content');
  const relativeUrlRoot = document.getElementsByName('relative-url-root')[0].getAttribute('content');

  const mdaViewerElt = $('#mda-viewer');
  const mda = mdaViewerElt.data('mda');
  const isEditing = mdaViewerElt.data('is-editing');
  const apiKey = mdaViewerElt.data('api-key');
  const members = mdaViewerElt.data('members');

  const api = new WhatsOptApi(csrfToken, apiKey, relativeUrlRoot);

  ReactDOM.render(<MdaViewer mda={mda} isEditing={isEditing} api={api} members={members}/>, mdaViewerElt[0]);
}
);
