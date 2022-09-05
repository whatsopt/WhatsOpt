/* eslint-disable max-classes-per-file */
import React from 'react';
import Plot from 'react-plotly.js';
import PropTypes from 'prop-types';

class MonoObjOptimPlotter extends React.PureComponent {
  makeTrace(y, name) { 
    const trace = {
      x: Array.from({ length: y.length }, (_, i) => i + 1),
      y: y,
      type: 'scatter',
      mode: 'markers+lines',
    };
    trace.name = name;
    return trace
  }

  render() {
    const {
      data,
      type,
    } = this.props;

    let plot_data = [];
    if (data.length === 1) {
      for (let i = 0; i < data[0].inputs.x[0].length; i += 1) {
        const trace = this.makeTrace(data[0].inputs.x.map((z) => z[i]), `input ${i + 1}`);
        plot_data.push(trace);
      }
      for (let i = 0; i < data[0].inputs.y[0].length; i += 1) {
        const trace = this.makeTrace(data[0].inputs.y.map((z) => z[i]), `output ${i + 1}`);
        plot_data.push(trace);
      }
    } else {
      for (let d = 0; d < data.length; d += 1) {
        for (let i = 0; i < data[d].inputs.y[0].length; i += 1) {
          const trace = this.makeTrace(data[d].inputs.y.map((z) => z[i]), `output ${i + 1}`);
          plot_data.push(trace);
        }
      }
    }

    let layout = {
      width: 800,
      height: 500,
      title: 'Data Points',
      xaxis: { title: '# Evaluations' },
      yaxis: { title: 'Values' },
    };

    return (<Plot data={plot_data} layout={layout} />);
  }
}

MonoObjOptimPlotter.propTypes = {
  data: PropTypes.array.isRequired,
  type: PropTypes.string.isRequired,
};
export default MonoObjOptimPlotter;
