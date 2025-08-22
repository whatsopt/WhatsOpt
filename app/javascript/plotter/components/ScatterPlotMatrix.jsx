import React from 'react';
import PropTypes from 'prop-types';
// import Plot from 'react-plotly.js';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

import * as caseUtils from '../../utils/cases';
import { COLORSCALE } from './colorscale';

const Plot = createPlotlyComponent(Plotly);

class ScatterPlotMatrix extends React.PureComponent {
  render() {
    const { cases, success, title } = this.props;
    const inputs = cases.i.concat(cases.c);
    const outputs = cases.c.concat(cases.o);
    let succ = success;
    if (succ.length === 0) {
      succ = new Array(cases.o[0].values.length);
      succ.fill(1);
    }

    const data = [];
    const layout = {};
    const nOut = outputs.length;
    const nDes = inputs.length;
    const pdh = 1.0 / nDes;
    const pdv = 1.0 / nOut;

    for (let i = 0; i < nOut; i += 1) {
      for (let j = 0; j < nDes; j += 1) {
        const xlabel = caseUtils.label(inputs[j]);
        const ylabel = caseUtils.label(outputs[i]);

        const trace = {
          x: inputs[j].values,
          y: outputs[i].values,
          type: 'scatter',
          mode: 'markers',
        };
        const n = nDes * i + j + 1;
        const xname = `x${n}`;
        const yname = `y${n}`;
        trace.xaxis = xname;
        trace.yaxis = yname;
        trace.name = `${ylabel} vs ${xlabel}`;
        trace.marker = {
          color: succ,
          cmin: 0,
          cmax: 1,
          colorscale: COLORSCALE,
        };
        data.push(trace);

        layout[`xaxis${n}`] = { domain: [(j + 0.1) * pdh, (j + 0.9) * pdh], anchor: yname };
        layout[`yaxis${n}`] = { domain: [(i + 0.1) * pdv, (i + 0.9) * pdv], anchor: xname };
        if (j === 0) {
          layout[`yaxis${n}`].title = { text: ylabel };
        }
        if (i === 0) {
          layout[`xaxis${n}`].title = { text: xlabel };
        }
      }
    }
    layout.width = nDes * 250 + 500;
    layout.height = nOut * 250 + 100;
    layout.title = { text: title };

    return (<Plot data={data} layout={layout} />);
  }
}

ScatterPlotMatrix.propTypes = {
  cases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }).isRequired,
  title: PropTypes.string.isRequired,
  success: PropTypes.array.isRequired,
};

export default ScatterPlotMatrix;
