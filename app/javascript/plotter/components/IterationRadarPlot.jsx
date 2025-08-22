import React from 'react';
import PropTypes from 'prop-types';
// import Plot from 'react-plotly.js';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

import * as caseUtils from '../../utils/cases';

const Plot = createPlotlyComponent(Plotly);

class IterationRadarPlot extends React.PureComponent {
  render() {
    const { cases } = this.props;
    const variables = cases.i;
    if (variables.length === 0) {
      throw Error('Input variables is empty');
    }
    const data = [];
    for (let i = 0; i < variables[0].values.length; i += 1) {
      const trace = {
        type: 'scatterpolar',
        name: `Evaluation ${i + 1}`,
        fill: 'none',
      };

      const theta = [];
      const r = [];
      for (let j = 0; j < variables.length; j += 1) {
        theta.push(caseUtils.label(variables[j]));
        r.push(variables[j].values[i]);
      }
      theta.push(theta[0]);
      r.push(r[0]);
      trace.theta = theta;
      trace.r = r;
      data.push(trace);
    }
    const { title } = this.props;
    const layout = { width: 600, height: 500, title: {text: title} };

    return (<Plot data={data} layout={layout} />);
  }
}

IterationRadarPlot.propTypes = {
  cases: PropTypes.shape({
    i: PropTypes.array.isRequired,
  }).isRequired,
  title: PropTypes.string.isRequired,
};

export default IterationRadarPlot;
