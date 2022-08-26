import React from 'react';
import ReactDOM from 'react-dom';
import OptimViewer from 'optim_viewer';

document.addEventListener('DOMContentLoaded', () => {
  const optim_plot = document.getElementById('optimization_plot');

  ReactDOM.render(
    <OptimViewer data={JSON.parse(optim_plot.getAttribute('optimization_data'))} type={optim_plot.getAttribute('type')} />,
    optim_plot,
  );
});
