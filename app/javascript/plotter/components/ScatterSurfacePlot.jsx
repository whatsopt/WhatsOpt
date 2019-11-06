import React from 'react';
import PropTypes from 'prop-types';
// import Plot from 'react-plotly.js';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

import * as caseUtils from '../../utils/cases';
import { COLORSCALE } from './colorscale';

const Plot = createPlotlyComponent(Plotly);

class ScatterSurfacePlot extends React.PureComponent {
  render() {
    const {
      casesx, casesy, casesz, success, title,
    } = this.props;
    const trace = {
      x: casesx.values,
      y: casesy.values,
      z: casesz.values,
      mode: 'markers',
      type: 'scatter3d',
      marker: {
        color: success,
        cmin: 0,
        cmax: 1,
        colorscale: COLORSCALE,
      },
    };

    const data = [trace];
    const layout = {};
    layout.width = 600;
    layout.height = 500;
    layout.title = title;
    layout.margin = {
      l: 0, r: 0, b: 0, t: 0,
    };
    layout.scene = {};
    layout.scene.xaxis = { title: caseUtils.label(casesx) };
    layout.scene.yaxis = { title: caseUtils.label(casesy) };
    layout.scene.zaxis = { title: caseUtils.label(casesz) };

    return (<Plot data={data} layout={layout} />);
  }
}

ScatterSurfacePlot.propTypes = {
  casesx: PropTypes.shape({
    varname: PropTypes.string.isRequired,
    values: PropTypes.array.isRequired,
  }).isRequired,
  casesy: PropTypes.shape({
    varname: PropTypes.string.isRequired,
    values: PropTypes.array.isRequired,
  }).isRequired,
  casesz: PropTypes.shape({
    varname: PropTypes.string.isRequired,
    values: PropTypes.array.isRequired,
  }).isRequired,
  title: PropTypes.string.isRequired,
  success: PropTypes.array.isRequired,
};

export default ScatterSurfacePlot;
