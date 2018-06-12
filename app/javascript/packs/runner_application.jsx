import React from 'react';
import ReactDOM from 'react-dom';
import {Runner} from 'runner';

document.addEventListener('DOMContentLoaded', () => {
    let runnerElt = $('#runner');
    let mda = runnerElt.data('mda');
    let ope = runnerElt.data('ope');
    let apiKey = runnerElt.data('api-key');
    ReactDOM.render(<Runner mda={mda} ope={ope} apiKey={apiKey}/>,
                    runnerElt[0] );
  }
);
