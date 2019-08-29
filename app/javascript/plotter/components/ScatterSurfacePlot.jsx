import React from 'react';
import PropTypes from 'prop-types';
import Plot from 'react-plotly.js';
import * as caseUtils from '../../utils/cases.js';
import {COLORSCALE} from './colorscale.js';

class ScatterSurfacePlot extends React.Component {
  render() {
    const trace = {
      x: this.props.casesx.values,
      y: this.props.casesy.values,
      z: this.props.casesz.values,
      mode: 'markers',
      type: 'scatter3d',
      marker: {
        color: this.props.success,
        cmin: 0,
        cmax: 1,
        colorscale: COLORSCALE,
      },
    };

    const data = [trace];
    const layout = {};
    layout.width = 600;
    layout.height = 500;
    layout.title = this.props.title;
    layout.margin = {l: 0, r: 0, b: 0, t: 0};
    layout.scene = {};
    layout.scene.xaxis={title: caseUtils.label(this.props.casesx)};
    layout.scene.yaxis={title: caseUtils.label(this.props.casesy)};
    layout.scene.zaxis={title: caseUtils.label(this.props.casesz)};

    return (<Plot data={data} layout={layout} />);
  }
}

ScatterSurfacePlot.propTypes = {
  casesx: PropTypes.shape({
    varname: PropTypes.string.isRequired,
    values: PropTypes.array.isRequired,
  }),
  casesy: PropTypes.shape({
    varname: PropTypes.string.isRequired,
    values: PropTypes.array.isRequired,
  }),
  casesz: PropTypes.shape({
    varname: PropTypes.string.isRequired,
    values: PropTypes.array.isRequired,
  }),
  title: PropTypes.string,
  success: PropTypes.array.isRequired,
};

export default ScatterSurfacePlot;
