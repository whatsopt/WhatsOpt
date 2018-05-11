import React from 'react';
import Plot from 'react-plotly.js';
import * as caseUtils from '../../utils/cases.js';

class IterationLinePlot extends React.Component {
  render() {
    let variables = this.props.cases.i.concat(this.props.cases.c);
    variables = variables.concat(this.props.cases.o);

    let data = [];

    for (let i=0; i<variables.length; i++) {
      let ylabel = caseUtils.label(variables[i]);

      let trace = {
        x: Array.from({length: variables[i].values.length}, (v, k) => k+1),
        y: variables[i].values,
        type: 'scatter',
        name: ylabel,
      };

      data.push(trace);
    }

    let title = this.props.title;
    let layout = {width: 600, height: 500, title: title};

    return (<Plot data={data} layout={layout} />);
  }
}

export default IterationLinePlot;
