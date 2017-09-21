import React from 'react';
import ReactDOM from 'react-dom';
import { MdaViewer } from 'mda_viewer';

document.addEventListener('DOMContentLoaded', () => {
	  ReactDOM.render(
	    < MdaViewer mda={MDA} />,
	    document.getElementById('mda-viewer')
	  );
	});
