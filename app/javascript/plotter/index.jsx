import React from 'react';
import Plot from 'react-plotly.js';
import update from 'immutability-helper'
import {api, url} from '../utils/WhatsOptApi';

class Plotter extends React.Component {
    
  constructor(props) {
    super(props)
    
    this.state = this.props.ope;
    console.log(this.state);
  }

//  componentDidMount() {
//    api.getOperation(this.props.operationId, (response) => {
//      let newState = update(this.state, { data: {$set: response.data }});
//      this.setState(newState);  
//    });
//  } 
   
  render() {
    let cases = this.state.cases;
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
    console.log(JSON.stringify(trace));
    return (
      <div>
          <Plot
            data={data}
            layout={{ width: 800, height: 400, title: this.state.name }}
          />
      </div>
    );
  }    
}

export { Plotter };