import React from 'react';
import PropTypes from 'prop-types';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

const Plot = createPlotlyComponent(Plotly);

class SobolHeatMap extends React.PureComponent {
  render() {
    const { firstOrder, saResult, outVarNames } = this.props;
    // use first sa info to get in var names
    const {
      parameter_names: parameterNames,
    } = saResult[outVarNames[0]];

    const sobols = [];
    for (const outVarName of outVarNames) {
      const { S1, ST } = saResult[outVarName];
      const sobol = firstOrder ? S1 : ST;
      sobols.push(sobol);
    }
    const label = firstOrder ? 'S1' : 'ST';
    const sobolOrder = firstOrder ? 'First order' : 'Total order';

    const data = [
      {
        z: sobols,
        x: parameterNames,
        y: outVarNames,
        type: 'heatmap',
        hoverongaps: false,
        colorscale: 'Oranges',
        hovertemplate: `input: %{x}<br>output: %{y}<br>${label}: %{z}<extra></extra>`,
      },
    ];
    const layout = {
      title: `${sobolOrder} Sobol indices heatmap`,
      xaxis: {
        title: { text: 'Input variables' },
        layer: 'below traces',
      },
      yaxis: {
        title: { text: 'Output variables' },
        layer: 'below traces',
      },
    };

    return (<Plot data={data} layout={layout} />);
  }
}

SobolHeatMap.propTypes = {
  outVarNames: PropTypes.arrayOf(PropTypes.string).isRequired,
  firstOrder: PropTypes.bool.isRequired,
  saResult: PropTypes.arrayOf(PropTypes.shape({
    S1: PropTypes.array.isRequired,
    S1_conf: PropTypes.array,
    ST: PropTypes.array.isRequired,
    ST_conf: PropTypes.array,
    parameter_names: PropTypes.array.isRequired,
  })).isRequired,
};

export default SobolHeatMap;
