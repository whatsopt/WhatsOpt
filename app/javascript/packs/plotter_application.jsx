import React from 'react';
import ReactDOM from 'react-dom';
import { Plotter } from 'plotter';

document.addEventListener('DOMContentLoaded', () => {
    let plotterElt = $('#plotter');
    let plotting = plotterElt.data('plotting');
    let apiKey = plotterElt.data('api-key');
    ReactDOM.render(
	    <Plotter plotting={plotting} apiKey={apiKey}/>,
	    mdaViewerElt[0]
	  );
	});
