import React from 'react';
import ReactDOM from 'react-dom';
import { MdaViewer } from 'mda_viewer';

document.addEventListener('DOMContentLoaded', () => {
    let mdaViewerElt = $('#mda-viewer');
    let mda = mdaViewerElt.data('mda');
    let isEditing = mdaViewerElt.data('is-editing');
    let apiKey = mdaViewerElt.data('api-key');
    ReactDOM.render(
	    <MdaViewer mda={mda} isEditing={isEditing} apiKey={apiKey}/>,
	    mdaViewerElt[0]
	  );
	});
