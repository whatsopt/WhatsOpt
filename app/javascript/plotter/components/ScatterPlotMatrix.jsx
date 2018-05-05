import React from 'react';
import Plot from 'react-plotly.js';

class ScatterPlotMatrix extends React.Component {
  
  render() {
    let db = this.props.db;
    let cases = this.props.cases;
    
    let inputVarCases = cases.filter(c => { return db.isInputVarCases(c); })
    let outputVarCases = cases.filter(c => { return db.isOutputVarCases(c) })
    let couplingVarCases = cases.filter(c => { return db.isCouplingVarCases(c) })
    
    let inputs = inputVarCases.concat(couplingVarCases);
    let outputs = couplingVarCases.concat(outputVarCases);
    
    let data = [];
    let layout = {};
    let nOut = outputs.length;
    let nDes = inputs.length;
    let pdh = 1./nDes;
    let pdv = 1./nOut;

    for (let i=0; i<nOut; i++) {
      for (let j=0; j<nDes; j++) {
        let xlabel = inputs[j].varname;
        xlabel += inputs[j].coord_index===-1?"":" "+inputs[j].coord_index;
        let ylabel = outputs[i].varname;
        ylabel += outputs[i].coord_index===-1?"":" "+outputs[i].coord_index;
    
        let trace = { x: inputs[j].values, y: outputs[i].values, 
                      type: 'scatter', mode: 'markers'};
        let n = nDes*i+j+1;
        let xname = 'x'+n;
        let yname = 'y'+n;
        trace.xaxis = xname;
        trace.yaxis = yname;
        trace.name = ylabel + " vs " + xlabel;
        data.push(trace);

        layout['xaxis'+n] = {domain: [(j+0.1)*pdh, (j+0.9)*pdh], anchor: yname};
        layout['yaxis'+n] = {domain: [(i+0.1)*pdv, (i+0.9)*pdv], anchor: xname};
        if (j===0) {
          layout['yaxis'+n].title = ylabel;
        }  
        if (i===0) {
          layout['xaxis'+n].title = xlabel;
        }
      } 
    }
    layout.width = nDes*250;
    layout.height = nOut*250;
    
    let title = "Scatterplot Matrix";
    layout.title  = title;

    return (<Plot data={data} layout={layout} />);
  }
}

export default ScatterPlotMatrix;