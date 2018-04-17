import React from 'react';
import Plot from 'react-plotly.js';
import update from 'immutability-helper'
import { AnalysisDatabase } from '../../utils/AnalysisDatabase';

class ScatterPlotMatrix extends React.Component {
    
  constructor(props) {
    super(props);
    this.driver_node = this.props.mda.nodes[0]
    this.db = new AnalysisDatabase(this.props.mda)
  }
  
  render() {
    let cases = this.props.ope.cases;
    cases.forEach((c) => {
      let vinfo = this.db.find(c.varname);
      console.log(JSON.stringify(vinfo));
    });
    console.log(this.db.designVariables());
    console.log(this.db.outputVariables());
    
    return (<Plot data={[
        {
        x: [1, 2, 3],
        y: [2, 6, 3],
        type: 'scatter',
        mode: 'lines+points',
        marker: {color: 'red'},
      },
      {type: 'bar', x: [1, 2, 3], y: [2, 5, 3]},
    ]}
    layout={ {width: 320, height: 240, title: 'A Fancy Plot'} } />);
  }
  
}

export default ScatterPlotMatrix;