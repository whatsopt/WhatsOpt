import React from 'react';
import { createRoot } from 'react-dom/client';

import OptimViewer from 'optim_viewer';

document.addEventListener('DOMContentLoaded', () => {
  const optimViewer = document.getElementById('optim_viewer');
  const data = JSON.parse(optimViewer.getAttribute('data-optimization'));

  const root = createRoot(optimViewer);
  root.render(
    <OptimViewer data={data} />,
  );
});
