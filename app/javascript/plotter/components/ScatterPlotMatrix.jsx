import React from 'react';
import Plot from 'react-plotly.js';
import * as caseUtils from '../../utils/cases.js'; 

class ScatterPlotMatrix extends React.Component {
  
  render() {
    let inputs = this.props.cases.i.concat(this.props.cases.c);
    let outputs = this.props.cases.c.concat(this.props.cases.o);
    
    let data = [];
    let layout = {};
    let nOut = outputs.length;
    let nDes = inputs.length;
    let pdh = 1./nDes;
    let pdv = 1./nOut;

    for (let i=0; i<nOut; i++) {
      for (let j=0; j<nDes; j++) {
        let xlabel = caseUtils.label(inputs[j]);
        let ylabel = caseUtils.label(outputs[i]);
    
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
    layout.height = nOut*250+100;
    layout.title  = this.props.title;

    return (<Plot data={data} layout={layout} />);
  }
}

export default ScatterPlotMatrix;