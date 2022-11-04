import React from 'react';
import { createRoot } from 'react-dom/client';

import MdaViewer from 'mda_viewer';
import '@rails/actiontext';

import WhatsOptApi from '../utils/WhatsOptApi';

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

  const root = createRoot(mdaViewerElt[0]);
  root.render(<MdaViewer
    mda={mda}
    isEditing={isEditing}
    api={api}
    members={members}
    coOwners={coOwners}
    currentUser={currentUser}
  />);
});
