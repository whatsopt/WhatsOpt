import React from 'react';
import PropTypes from 'prop-types';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

const Plot = createPlotlyComponent(Plotly);

class MorrisScatterPlot extends React.PureComponent {
  render() {
    const { saData, outVarName } = this.props;
    const {
      mu_star: muStar, sigma, mu_star_conf: muStarConf, parameter_names: paramNames,
    } = saData;
    const trace = {
      x: muStar,
      error_x: { type: 'data', array: muStarConf, symmetric: true },
      y: sigma,
      type: 'scatter',
      mode: 'markers+text',
      text: paramNames,
      textposition: 'top center',
      marker: { size: 10 },
      cliponaxis: false,
    };

    const data = [trace];
    const layout = {
      title: { text: `${outVarName} sensitivity` },
      width: 500,
      height: 500,
      xaxis: {
        rangemode: 'tozero',
        title: { text: '\u03BC*' },
        layer: 'below traces',
      },
      yaxis: {
        rangemode: 'tozero',
        title: { text: '\u03c3' },
        layer: 'below traces',
      },
    };

    return (<Plot data={data} layout={layout} />);
  }
}

MorrisScatterPlot.propTypes = {
  outVarName: PropTypes.string.isRequired,
  saData: PropTypes.shape({
    mu_star: PropTypes.array.isRequired,
    mu_star_conf: PropTypes.array.isRequired,
    sigma: PropTypes.array.isRequired,
    parameter_names: PropTypes.array.isRequired,
  }).isRequired,
};

export default MorrisScatterPlot;
