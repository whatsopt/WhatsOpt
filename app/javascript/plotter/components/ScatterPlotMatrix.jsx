import React from 'react';
import PropTypes from 'prop-types';
import Plot from 'react-plotly.js';
import * as caseUtils from '../../utils/cases.js';

class ScatterPlotMatrix extends React.Component {
  render() {
    const inputs = this.props.cases.i.concat(this.props.cases.c);
    const outputs = this.props.cases.c.concat(this.props.cases.o);

    const data = [];
    const layout = {};
    const nOut = outputs.length;
    const nDes = inputs.length;
    const pdh = 1./nDes;
    const pdv = 1./nOut;

    for (let i=0; i<nOut; i++) {
      for (let j=0; j<nDes; j++) {
        const xlabel = caseUtils.label(inputs[j]);
        const ylabel = caseUtils.label(outputs[i]);

        const trace = {x: inputs[j].values, y: outputs[i].values,
          type: 'scatter', mode: 'markers'};
        const n = nDes*i+j+1;
        const xname = 'x'+n;
        const yname = 'y'+n;
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
    layout.width = nDes*250 + 100;
    layout.height = nOut*250 + 100;
    layout.title = this.props.title;

    return (<Plot data={data} layout={layout} />);
  }
}

ScatterPlotMatrix.propTypes = {
  cases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }),
  title: PropTypes.string,
};

export default ScatterPlotMatrix;
