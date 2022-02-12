import React from 'react';
import ReactDOM from 'react-dom';
import MdaViewer from 'mda_viewer';
import { AttachmentUpload } from '@rails/actiontext/app/javascript/actiontext/attachment_upload';
import WhatsOptApi from '../utils/WhatsOptApi';

// Workaround from https://github.com/rails/rails/issues/43973
// import '@rails/actiontext';

// eslint-disable-next-line no-restricted-globals
addEventListener('trix-attachment-add', (event) => {
  const { attachment, target } = event;

  if (attachment.file) {
    const upload = new AttachmentUpload(attachment, target);
    upload.start();
  }
});
// end of Workaround test

document.addEventListener('DOMContentLoaded', () => {
  const csrfToken = document.getElementsByName('csrf-token')[0].getAttribute('content');
  const relativeUrlRoot = document.getElementsByName('relative-url-root')[0].getAttribute('content');

  // eslint-disable-next-line no-undef
  const mdaViewerElt = $('#mda-viewer');
  const mda = mdaViewerElt.data('mda');
  const isEditing = mdaViewerElt.data('is-editing');
  const apiKey = mdaViewerElt.data('api-key');
  const members = mdaViewerElt.data('members');
  const coOwners = mdaViewerElt.data('co-owners');
  const currentUser = mdaViewerElt.data('current-user');

  const api = new WhatsOptApi(csrfToken, apiKey, relativeUrlRoot, mda.updated_at);

  ReactDOM.render(<MdaViewer
    mda={mda}
    isEditing={isEditing}
    api={api}
    members={members}
    coOwners={coOwners}
    currentUser={currentUser}
  />, mdaViewerElt[0]);
});
