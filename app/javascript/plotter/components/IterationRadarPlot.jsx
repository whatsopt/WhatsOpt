import React from 'react';
import PropTypes from 'prop-types';
// import Plot from 'react-plotly.js';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

import * as caseUtils from '../../utils/cases.js';

const Plot = createPlotlyComponent(Plotly);

class IterationRadarPlot extends React.Component {
  render() {
    const variables = this.props.cases.i;
    if (variables.length === 0) {
      throw Error('Input variables is empty');
    }
    const data = [];
    for (let i = 0; i < variables[0].values.length; i++) {
      const trace = {
        type: 'scatterpolar',
        name: `Evaluation ${i + 1}`,
        fill: 'none',
      };

      const theta = [];
      const r = [];
      for (let j = 0; j < variables.length; j++) {
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
    const layout = { width: 600, height: 500, title };

    return (<Plot data={data} layout={layout} />);
  }
}

IterationRadarPlot.propTypes = {
  cases: PropTypes.shape({
    i: PropTypes.array.isRequired,
  }),
  title: PropTypes.string,
};

export default IterationRadarPlot;
