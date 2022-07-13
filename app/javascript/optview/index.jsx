/* eslint-disable max-classes-per-file */
import React from 'react';
import Plot from 'react-plotly.js';
import PropTypes from 'prop-types';

class OptView extends React.PureComponent {
  constructor(props) {
    super(props);
    const {
      optim,
    } = this.props;
    console.log("Kenoobii");
  }
  render() {
    return (
      <Plot
        data={[
          {
            x: Array.from(Array(this.props.optim.inputs['x'].length).keys()),
            y: this.props.optim.inputs['x'].map( x => x[0] ),
            type: 'scatter',
            mode: 'markers lines',
            name: 'x[0]',
            marker: {color: 'orange'}
          },
          {
            x: Array.from(Array(this.props.optim.inputs['x'].length).keys()),
            y: this.props.optim.inputs['x'].map( x => x[1] ),
            type: 'scatter',
            mode: 'markers lines',
            name: 'x[1]',
            marker: {color: 'red'},
          },
          {
            x: Array.from(Array(this.props.optim.inputs['y'].length).keys()),
            y: this.props.optim.inputs['y'].map( y => y[0] ),
            type: 'scatter',
            mode: 'markers lines',
            name: 'y',
            marker: {color: 'green'},
          }
        ]}
        layout={{
          width: 800, 
          height: 500, 
          title: 'Visual representation of the input points',
          xaxis: {title: "point's number"},     
          yaxis: {title: "variable's values"}
        }}
      />
    );
  }
}

OptView.propTypes = {
  optim: PropTypes.object.isRequired,
};
export default OptView;
