import React from 'react';
import ReactDOM from 'react-dom';
import { Plotter } from 'plotter';

document.addEventListener('DOMContentLoaded', () => {
    let plotterElt = $('#plotter');
    let mda = plotterElt.data('mda');
    let ope = plotterElt.data('ope');
    let apiKey = plotterElt.data('api-key');
    ReactDOM.render(
	    <Plotter mda={mda} ope={ope} apiKey={apiKey}/>,
	    plotterElt[0]
	  );
	});
