import React from 'react';
import PropTypes from 'prop-types';
// import Plot from 'react-plotly.js';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

import * as caseUtils from '../../utils/cases.js';
import { COLORSCALE } from './colorscale.js';

const Plot = createPlotlyComponent(Plotly);

class ScatterPlotMatrix extends React.PureComponent {
  render() {
    const { cases, success, title } = this.props;
    const inputs = cases.i.concat(cases.c);
    const outputs = cases.c.concat(cases.o);

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
          color: success,
          cmin: 0,
          cmax: 1,
          colorscale: COLORSCALE,
        };
        data.push(trace);

        layout[`xaxis${n}`] = { domain: [(j + 0.1) * pdh, (j + 0.9) * pdh], anchor: yname };
        layout[`yaxis${n}`] = { domain: [(i + 0.1) * pdv, (i + 0.9) * pdv], anchor: xname };
        if (j === 0) {
          layout[`yaxis${n}`].title = ylabel;
        }
        if (i === 0) {
          layout[`xaxis${n}`].title = xlabel;
        }
      }
    }
    layout.width = nDes * 250 + 100;
    layout.height = nOut * 250 + 100;
    layout.title = title;

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
