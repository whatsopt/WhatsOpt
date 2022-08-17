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

    if (type === 'single') {
      if (data[0].inputs.x) {
        for (let i = 0; i < data[0].inputs.x[0].length; i += 1) {
          this.definePlot(data[0].inputs.x, i, 'gray', `input ${i + 1}`);
        }
        this.definePlot(data[0].inputs.y, 0, 'red', 'output');
      }
    } else {
      for (let i = 0; i < data.length; i += 1) {
        if (data[i].inputs.x) {
          this.definePlot(data[i].inputs.y, 0, 'red', `output of #${data[i].id}`);
        }
      }
    }
  }

  definePlot(points, n, _color, _name) {
    this.input_list.push({
      x: Array.from(Array(points.length).keys()),
      y: points.map((z) => z[n]),
      type: 'scatter',
      mode: 'markers lines',
      name: _name,
      marker: { color: _color },
    });
  }

  render() {
    const {
      data,
      type,
    } = this.props;
    if (!data[0].inputs.x && type === 'single') {
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
}

OptView.propTypes = {
  data: PropTypes.array.isRequired,
  type: PropTypes.string.isRequired,
};
export default OptView;
