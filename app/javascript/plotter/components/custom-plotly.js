// in custom-plotly.js
import Plotly from 'plotly.js/lib/core';

// Load in the trace types
Plotly.register([
  require('plotly.js/lib/scatter'),
  require('plotly.js/lib/scatterpolar'),
  require('plotly.js/lib/scatter3d'),
  require('plotly.js/lib/parcoords'),
  require('plotly.js/lib/histogram'),
]);

export default Plotly;
