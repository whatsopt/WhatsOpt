import React from 'react';
import PropTypes from 'prop-types';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

import * as caseUtils from '../../utils/cases';

const Plot = createPlotlyComponent(Plotly);

class IterationLinePlot extends React.PureComponent {
  render() {
    const { cases } = this.props;
    let variables = cases.i.concat(cases.c);
    variables = variables.concat(cases.o);

    const data = [];

    for (let i = 0; i < variables.length; i += 1) {
      const ylabel = caseUtils.label(variables[i]);

      const trace = {
        x: Array.from({ length: variables[i].values.length }, (v, k) => k + 1),
        y: variables[i].values,
        type: 'scatter',
        name: ylabel,
      };

      data.push(trace);
    }

    const { title } = this.props;
    const layout = { width: 600, height: 500, title };

    return (<Plot data={data} layout={layout} />);
  }
}

IterationLinePlot.propTypes = {
  cases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }).isRequired,
  title: PropTypes.string.isRequired,
};

export default IterationLinePlot;
