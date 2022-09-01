/* eslint-disable max-classes-per-file */
import React from 'react';
import Plot from 'react-plotly.js';
import PropTypes from 'prop-types';

// const COLORS = [
//   '#1f77b4',  // muted blue
//   '#ff7f0e',  // safety orange
//   '#2ca02c',  // cooked asparagus green
//   '#d62728',  // brick red
//   '#9467bd',  // muted purple
//   '#8c564b',  // chestnut brown
//   '#e377c2',  // raspberry yogurt pink
//   '#7f7f7f',  // middle gray
//   '#bcbd22',  // curry yellow - green
//   '#17becf'   // blue - teal
// ];

class OptimViewer extends React.PureComponent {
  constructor(props) {
    super(props);
    const {
      data,
      type,
    } = this.props;
    this.input_list = [];

    if (data[0].inputs.y) {
      if (data[0].config.n_obj === 1) {
        if (type === 'single') {
          if (data[0].inputs.x) {
            for (let i = 0; i < data[0].inputs.x[0].length; i += 1) {
              this.addInputPlot(data[0].inputs.x, i, `input ${i + 1}`);
            }
            for (let i = 0; i < data[0].inputs.y[0].length; i += 1) {
              this.addInputPlot(data[0].inputs.y, i, `output ${i + 1}`);
            }
          }
        } else {
          for (let i = 0; i < data.length; i += 1) {
            if (data[i].inputs.x) {
              this.addInputPlot(data[i].inputs.y, 0, `output of #${data[i].id}`);
            }
          }
        }
      } else if (type === 'single') {
        if (data[0].inputs.y) {
          this.addParetoPlot(data[0].inputs.y, 'History');
        }
        if (data[0].outputs.y_best) {
          this.addParetoPlot(data[0].outputs.y_best, 'Approx Pareto front');
        }
      } else {
        for (let i = 0; i < data.length; i += 1) {
          if (data[i].inputs.y) {
            this.addParetoPlot(data[i].inputs.y, `#${data[i].id}`);
          }
        }
      }
    }
  }

  addInputPlot(x, n, name) {
    this.input_list.push({
      x: Array.from({ length: x.length }, (_, i) => i + 1),
      y: x.map((z) => z[n]),
      type: 'scatter',
      mode: 'markers lines',
      name,
    });
  }

  addParetoPlot(y, name) {
    this.input_list.push({
      x: y.map((z) => z[0]),
      y: y.map((z) => z[1]),
      type: 'scatter',
      mode: 'markers',
      name,
    });
  }

  render() {
    const {
      data,
    } = this.props;
    if (this.input_list.length === 0) {
      return (
        <div className="alert alert-primary mt-5 mb-5" role="alert">
          No data! Optimization not run yet?
        </div>
      );
    }

    if (data[0].config.n_obj === 1) {
      return (
        <div className="container">
          <div className="row">
            <div className="col-sm">
              <Plot
                data={this.input_list}
                layout={{
                  width: 800,
                  height: 500,
                  title: 'Data Points',
                  xaxis: { title: '# Evaluations' },
                  yaxis: { title: 'Values' },
                }}
              />
            </div>
          </div>
        </div>
      );
    }
    return (
      <div className="container">
        <div className="row">
          <div className="col-sm">
            <Plot
              data={this.input_list}
              layout={{
                width: 800,
                height: 500,
                title: 'Pareto front',
                xaxis: { title: 'y1' },
                yaxis: { title: 'y2' },
              }}
            />
          </div>
        </div>
      </div>
    );
  }
}

OptimViewer.propTypes = {
  data: PropTypes.array.isRequired,
  type: PropTypes.string.isRequired,
};
export default OptimViewer;
