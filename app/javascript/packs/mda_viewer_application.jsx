import React from 'react';
import ReactDOM from 'react-dom';
import { MdaViewer } from 'mda_viewer';

document.addEventListener('DOMContentLoaded', () => {
    let mdaViewerElt = $('#plotter');
    let mda = mdaViewerElt.data('cases');
    let apiKey = mdaViewerElt.data('api-key');
    ReactDOM.render(
	    <Plotter mda={mda} apiKey={apiKey}/>, mdaViewerElt[0]
	  );
	});
