import React from 'react';
import PropTypes from 'prop-types';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

const Plot = createPlotlyComponent(Plotly);

class HsicScatterPlot extends React.PureComponent {
  render() {
    const { hsicData } = this.props;
    const {
      parameters_names: parameterNames, obj_name: objName, hsic: { r2, pvperm },
    } = hsicData;
    const traceR2 = {
      name: 'R2',
      x: parameterNames.map((_, i) => i + 0.9),
      y: r2,
      type: 'scatter',
      mode: 'markers+text',
      text: parameterNames,
      textposition: 'left center',
      marker: { size: 10 },
      cliponaxis: false,
    };

    const tracePvperm = {
      name: 'p-value by permutation',
      x: parameterNames.map((_, i) => i + 1.1),
      y: pvperm,
      type: 'scatter',
      mode: 'markers+text',
      text: parameterNames,
      textposition: 'right center',
      marker: { size: 10 },
      cliponaxis: false,
      yaxis: 'y2',
    };

    const data = [traceR2, tracePvperm];
    const layout = {
      title: `${objName} optimization HSIC sensitivity`,
      xaxis: {
        rangemode: 'tozero',
        title: { text: 'Design Variables' },
      },
      yaxis: {
        rangemode: 'tozero',
        title: { text: 'HSIC r2' },
        titlefont: { color: '#1f77b4' },
        tickfont: { color: '#1f77b4' },
      },
      yaxis2: {
        rangemode: 'tozero',
        title: 'HSIC p-value',
        titlefont: { color: '#ff7f0e' },
        tickfont: { color: '#ff7f0e' },
        overlaying: 'y',
        side: 'right',
      },
    };

    return (<Plot data={data} layout={layout} />);
  }
}

HsicScatterPlot.propTypes = {
  hsicData: PropTypes.shape({
    obj_name: PropTypes.string.isRequired,
    hsic: PropTypes.shape({
      indices: PropTypes.array.isRequired,
      r2: PropTypes.array,
      pvas: PropTypes.array.isRequired,
      pvperm: PropTypes.array,
    }),
    parameters_names: PropTypes.array.isRequired,
  }).isRequired,
};

export default HsicScatterPlot;
