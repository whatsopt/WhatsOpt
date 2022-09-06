import React from 'react';
import ReactDOM from 'react-dom';
import OptimViewer from 'optim_viewer';

document.addEventListener('DOMContentLoaded', () => {
  const optim_plot = document.getElementById('optim_viewer');

  ReactDOM.render(
    <OptimViewer data={JSON.parse(optim_plot.getAttribute('data-optimization'))} />,
    optim_plot,
  );
});
