import React from 'react';
import PropTypes from 'prop-types';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

const Plot = createPlotlyComponent(Plotly);

class SobolScatterPlot extends React.PureComponent {
  render() {
    const { saData, outVarName } = this.props;
    const {
      S1, S1_conf: s1Conf, ST, ST_conf: stConf, parameter_names: parameterNames,
    } = saData;
    const traceS1 = {
      name: 'S1',
      x: parameterNames.map((_, i) => i + 0.9),
      y: S1,
      error_y: {
        type: 'data', array: s1Conf, symmetric: true,
      },
      type: 'scatter',
      mode: 'markers+text',
      text: parameterNames,
      textposition: 'left center',
      marker: { size: 10 },
      cliponaxis: false,
    };

    const traceST = {
      name: 'ST',
      x: parameterNames.map((_, i) => i + 1.1),
      y: ST,
      error_y: {
        type: 'data', array: stConf, symmetric: true,
      },
      type: 'scatter',
      mode: 'markers+text',
      text: parameterNames,
      textposition: 'right center',
      marker: { size: 10 },
      cliponaxis: false,
    };

    const data = [traceS1, traceST];
    const layout = {
      title: { text: `${outVarName} sensitivity` },
      width: 200 + 75 * (parameterNames.length + 1),
      height: 500,
      xaxis: {
        rangemode: 'tozero',
        title: { text: 'inputs' },
        layer: 'below traces',
      },
      yaxis: {
        rangemode: 'tozero',
        title: { text: 'sobol indices values' },
        layer: 'below traces',
      },
    };

    return (<Plot data={data} layout={layout} />);
  }
}

SobolScatterPlot.propTypes = {
  outVarName: PropTypes.string.isRequired,
  saData: PropTypes.shape({
    S1: PropTypes.array.isRequired,
    S1_conf: PropTypes.array,
    ST: PropTypes.array.isRequired,
    ST_conf: PropTypes.array,
    parameter_names: PropTypes.array.isRequired,
  }).isRequired,
};

export default SobolScatterPlot;
