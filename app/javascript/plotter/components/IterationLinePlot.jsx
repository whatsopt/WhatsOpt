import React from 'react';
import Plot from 'react-plotly.js';

class IterationLinePlot extends React.Component {

  render() {
    let db = this.props.db;
    let cases = this.props.cases;
    
    let inputVarCases = cases.filter(c => { return db.isInputVarCases(c); })
    let outputVarCases = cases.filter(c => { return db.isOutputVarCases(c) })
    let couplingVarCases = cases.filter(c => { return db.isCouplingVarCases(c) })
    
    let variables = inputVarCases.concat(couplingVarCases);
    variables = variables.concat(outputVarCases);
    
    let data = [];
    
    
    for (let i=0; i<variables.length; i++) {
      let ylabel = variables[i].varname;
      ylabel += variables[i].coord_index===-1?"":" "+variables[i].coord_index;
    
      let trace = {
        x: Array.from({length: variables[i].values.length}, (v, k) => k+1),
        y: variables[i].values,
        type: 'scatter',
        name: ylabel,
      }
  
      data.push(trace);
    }
    
    let title = "Line plots";
    let layout = { width: 1000, height: 500, title: title };

    return (<Plot data={data} layout={layout} />);

  }
  
}

export default IterationLinePlot;