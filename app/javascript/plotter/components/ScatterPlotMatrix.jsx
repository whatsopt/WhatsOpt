import React from 'react';
import Plot from 'react-plotly.js';
import update from 'immutability-helper'
import { analysisDatabase } from '../../utils/AnalysisDatabase';

class ScatterPlotMatrix extends React.Component {
    
  constructor(props) {
    super(props);
    this.db = analysisDatabase(this.props.mda)
  }
  
  render() {
    let cases = this.props.ope.cases;
    
    let designVarCases = cases.filter(c => { return this.db.isDesignVarCases(c); })
    let outputVarCases = cases.filter(c => { return this.db.isOutputVarCases(c) })
    let couplingVarCases = cases.filter(c => { return this.db.isCouplingVarCases(c) })
    
    let data = [];
    let layout = {};
    let nOut = outputVarCases.length;
    let nDes = designVarCases.length;
    //nOut = 1;
    //nDes = 2;
    console.log(JSON.stringify(designVarCases));
    console.log(JSON.stringify(outputVarCases));
    for (let i=0; i<nOut; i++) {
      for (let j=0; j<nDes; j++) {
        let trace = { y: outputVarCases[i].values, type: 'scatter', mode: 'markers'};
        trace['x'] = designVarCases[j].values;
        let xname = 'x'+(nDes*i+j+1);
        let yname = 'y'+(nDes*i+j+1);
        if ((i+j)!==0) {
          trace.xaxis = xname;
          trace.yaxis = yname;
        }
        data.push(trace);
        let pdh = 1./nDes;
        let pdv = 1./nOut;
        let pdh10 = pdh/10.;
        let pdv10 = pdv/10.;
        if ((i+j)===0) {
          layout['xaxis'] = {domain: [0+pdh10, pdh-pdh10]};
          layout['yaxis'] = {domain: [0+pdv10, pdh-pdv10]};
        } else {
          layout['xaxis'+(nDes*i+j+1)] = {domain: [(j+0.1)*pdh, (j+0.9)*pdh], anchor: yname};
          layout['yaxis'+(nDes*i+j+1)] = {domain: [(i+0.1)*pdv, (i+0.9)*pdv], anchor: xname};
        }
      } 
    }
    layout.width = nDes*250;
    layout.height = nOut*250;
    
    let title = this.props.ope.name + " " + cases[0].values.length + " points in scatterplot matrix"
    layout.title = title;
    console.log(JSON.stringify(data));
    console.log(JSON.stringify(layout));

    return (<Plot data={data} layout={layout} />);
  }
  
}

export default ScatterPlotMatrix;