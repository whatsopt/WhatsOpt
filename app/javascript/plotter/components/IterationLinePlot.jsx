import React from 'react';
import PropTypes from 'prop-types';
//import Plot from 'react-plotly.js';
import Plotly from './custom-plotly'
import createPlotlyComponent from 'react-plotly.js/factory';
const Plot = createPlotlyComponent(Plotly);

import * as caseUtils from '../../utils/cases.js';

class IterationLinePlot extends React.Component {
  render() {
    let variables = this.props.cases.i.concat(this.props.cases.c);
    variables = variables.concat(this.props.cases.o);

    const data = [];

    for (let i=0; i<variables.length; i++) {
      const ylabel = caseUtils.label(variables[i]);

      const trace = {
        x: Array.from({length: variables[i].values.length}, (v, k) => k+1),
        y: variables[i].values,
        type: 'scatter',
        name: ylabel,
      };

      data.push(trace);
    }

    const title = this.props.title;
    const layout = {width: 600, height: 500, title: title};

    return (<Plot data={data} layout={layout} />);
  }
}

IterationLinePlot.propTypes = {
  cases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }),
  title: PropTypes.string,
};

export default IterationLinePlot;
