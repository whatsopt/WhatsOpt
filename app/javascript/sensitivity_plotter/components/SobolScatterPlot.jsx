import React from 'react';
import PropTypes from 'prop-types';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

const Plot = createPlotlyComponent(Plotly);

class SobolScatterPlot extends React.PureComponent {
  render() {
    const { saData, outVarName } = this.props;
    const trace = {
      x: [1, 2, 3],
      y: saData.S1,
      type: 'scatter',
      mode: 'markers+text',
      text: ['S1', 'S1', 'S1'],
      textposition: 'top center',
      marker: { size: 10 },
      cliponaxis: false,
    };

    const data = [trace];
    const layout = {
      title: `${outVarName} sensitivity`,
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

SobolScatterPlot.propTypes = {
  outVarName: PropTypes.string.isRequired,
  saData: PropTypes.shape({
    S1: PropTypes.array.isRequired,
    ST: PropTypes.array.isRequired,
    parameter_names: PropTypes.array.isRequired,
  }).isRequired,
};

export default SobolScatterPlot;
