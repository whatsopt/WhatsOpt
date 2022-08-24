/* eslint-disable max-classes-per-file */
import React from 'react';
import Plot from 'react-plotly.js';
import PropTypes from 'prop-types';

class OptView extends React.PureComponent {
  constructor(props) {
    super(props);
    const {
      data,
      type,
    } = this.props;
    this.input_list = [];

    if (data[0].inputs.y) {
      if (data[0].inputs.y[0].length <= 1) {
        if (type === 'single') {
          if (data[0].inputs.x) {
            for (let i = 0; i < data[0].inputs.x[0].length; i += 1) {
              this.inputPlot(data[0].inputs.x, i, 'gray', `input ${i + 1}`);
            }
            this.inputPlot(data[0].inputs.y, 0, 'red', 'output');
          }
        } else {
          for (let i = 0; i < data.length; i += 1) {
            if (data[i].inputs.x) {
              this.inputPlot(data[i].inputs.y, 0, 'red', `output of #${data[i].id}`);
            }
          }
        }
      } else if (type === 'single') {
        if (data[0].inputs.y) {
          this.paretoPlot(data[0].inputs.y, 'red', 'Pareto front');
        }
      } else {
        for (let i = 0; i < data.length; i += 1) {
          if (data[i].inputs.y) {
            this.paretoPlot(data[i].inputs.y, 'red', `#${data[i].id}`);
          }
        }
      }
    }
  }

  inputPlot(_x, _n, _color, _name) {
    this.input_list.push({
      x: Array.from({ length: _x.length }, (_, n) => n + 1),
      y: _x.map((z) => z[_n]),
      type: 'scatter',
      mode: 'markers lines',
      name: _name,
      marker: { color: _color },
    });
  }

  paretoPlot(_y, _color, _name) {
    this.input_list.push({
      x: _y.map((z) => z[0]),
      y: _y.map((z) => z[1]),
      type: 'scatter',
      mode: 'markers',
      name: _name,
      marker: { color: _color },
    });
  }

  render() {
    const {
      data,
    } = this.props;
    if (this.input_list.length === 0) {
      return (
        <div className="container">
          <div className="row">
            {' '}
            No data to see for entry :
            {' '}
            {data[0].id}
          </div>
        </div>
      );
    }

    if (data[0].inputs.y[0].length <= 1) {
      return (
        <div className="container">
          <div className="row">
            <div className="col-sm">
              <Plot
                data={this.input_list}
                layout={{
                  width: 800,
                  height: 500,
                  title: 'Visual representation of the input points',
                  xaxis: { title: "point's number" },
                  yaxis: { title: "variable's values" },
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
                title: 'Visual representation of the best outputs, as a Pareto front',
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

OptView.propTypes = {
  data: PropTypes.array.isRequired,
  type: PropTypes.string.isRequired,
};
export default OptView;
