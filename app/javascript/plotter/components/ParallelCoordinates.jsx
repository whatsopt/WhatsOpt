import React from 'react';
import Plot from 'react-plotly.js';
import update from 'immutability-helper'

class ParallelCoordinates extends React.Component {
    
  render() {    
    let cases = this.props.ope.cases;
    let dimensions = cases.map((c) => {   
      return { label: c.varname,
        values: c.values,
        range: [Math.floor(Math.min(...c.values)), Math.ceil(Math.max(...c.values))]
      };  
    });
    let trace = {
      type: 'parcoords',
      dimensions: dimensions,
    };    
    let data = [trace];
    let title = this.props.ope.name + " " + dimensions[0].values.length + " points"
    console.log(JSON.stringify(trace));
    return (
      <div>
          <Plot
            data={data}
            layout={{ width: 1000, height: 400, title: title }}
          />
      </div>
    );
  }    
}

export default ParallelCoordinates;