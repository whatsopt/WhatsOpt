import React from 'react';
import ReactDOM from 'react-dom';
import { Mda } from 'mda_viewer';

document.addEventListener('DOMContentLoaded', () => {
	  ReactDOM.render(
	    < Mda mda={MDA} />,
	    document.getElementById('mda-viewer')
	  );
	});
