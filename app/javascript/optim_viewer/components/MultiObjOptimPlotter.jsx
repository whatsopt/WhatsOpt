/* eslint-disable max-classes-per-file */
import React from 'react';
import Plot from 'react-plotly.js';
import PropTypes from 'prop-types';

const COLORMAP = ['#ff7f0e', '#1f77b4', '#2ca02c', '#d62728'];
const SYMBOLS = ['circle', 'triangle-up', 'diamond', 'x'];

class MultiObjOptimViewer extends React.PureComponent {
  render() {
    const { data } = this.props;
    const plot_data = [];
    const layout = {};

    const { n_obj } = data[0].config;

    const pdh = 1.0 / n_obj;
    const pdv = 1.0 / n_obj;

    for (let d = 0; d < data.length; d += 1) {
      for (let i = 0; i < n_obj; i += 1) {
        for (let j = 0; j < n_obj; j += 1) {
          const xlabel = `obj${j + 1}`;
          const ylabel = `obj${i + 1}`;

          let x = [];
          let y = [];
          const n_val = data[d].inputs.y.length;

          if (i === j) {
            x = Array.from({ length: n_val }, (_, n) => n + 1);
            y = data[d].inputs.y.map((yrow) => yrow[i]);
          } else {
            for (let k = 0; k < n_val; k += 1) {
              x.push(data[d].inputs.y[k][j]);
              y.push(data[d].inputs.y[k][i]);
            }
          }
          const trace = {
            x,
            y,
            type: 'scatter',
            mode: i === j ? 'marker+lines' : 'markers',
          };
          const n = n_obj * i + j + 1;
          const xname = `x${n}`;
          const yname = `y${n}`;
          trace.xaxis = xname;
          trace.yaxis = yname;
          if (i === j) {
            trace.name = `${ylabel} values`;
          } else {
            trace.name = `${ylabel} vs ${xlabel}`;
          }
          if (data.length > 1) { 
            trace.name = `serie#${d + 1} ${trace.name}`;
          }
          trace.marker = {
            color: data.length > 1 ? COLORMAP[d] : COLORMAP[1],
            symbol: SYMBOLS[0],
          };

          layout[`xaxis${n}`] = { domain: [(j + 0.1) * pdh, (j + 0.9) * pdh], anchor: yname };
          layout[`yaxis${n}`] = { domain: [(i + 0.1) * pdv, (i + 0.9) * pdv], anchor: xname };
          if (j === 0) {
            layout[`yaxis${n}`].title = ylabel;
          }
          if (i === 0) {
            layout[`xaxis${n}`].title = xlabel;
          }
          plot_data.push(trace);

          if (i !== j && data[d].outputs.y_best) {
            const n_val_pareto = data[d].outputs.y_best.length;
            const xp = [];
            const yp = [];
            for (let k = 0; k < n_val_pareto; k += 1) {
              xp.push(data[d].outputs.y_best[k][j]);
              yp.push(data[d].outputs.y_best[k][i]);
            }
            const trace2 = {
              x: xp,
              y: yp,
              type: 'scatter',
              mode: 'markers',
            };
            trace2.xaxis = xname;
            trace2.yaxis = yname;
            trace2.name = `Pareto ${ylabel} vs ${xlabel}`;
            if (data.length > 1) { 
              trace2.name = `serie#${d + 1} ${trace2.name}`
            }
            trace2.marker = {
              color: COLORMAP[d],
              symbol: SYMBOLS[1],
            };
            plot_data.push(trace2);
          } 
        }
      }
    }
    layout.width = n_obj * 250 + 500;
    layout.height = n_obj * 250 + 100;
    layout.title = 'Optim history and Pareto fronts';

    return (<Plot data={plot_data} layout={layout} />);
  }
}

MultiObjOptimViewer.propTypes = {
  data: PropTypes.array.isRequired,
};
export default MultiObjOptimViewer;
