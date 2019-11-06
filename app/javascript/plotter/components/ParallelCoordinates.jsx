import React from 'react';
import PropTypes from 'prop-types';
// import Plot from 'react-plotly.js';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

import * as caseUtils from '../../utils/cases.js';
import { COLORSCALE } from './colorscale.js';

const Plot = createPlotlyComponent(Plotly);

class ParallelCoordinates extends React.Component {
  render() {
    const dimensions = this._dimensionFromCases(this.props.cases.i);
    dimensions.push(...this._dimensionFromCases(this.props.cases.o));
    dimensions.push(...this._dimensionFromCases(this.props.cases.c));

    const trace = {
      type: 'parcoords',
      dimensions,
    };

    trace.line = {
      color: this.props.success,
      cmin: 0,
      cmax: 1,
      colorscale: COLORSCALE,
    };

    const data = [trace];
    const { title } = this.props;

    return (
      <div>
        <Plot
          data={data}
          layout={{ width: this.props.width, height: 500, title }}
        />
      </div>
    );
  }

  _dimensionFromCases(cases) {
    const isMin = this.props.db.getObjective() && this.props.db.getObjective().isMin;
    const dimensions = cases.map((c) => {
      const label = caseUtils.label(c);
      const minim = Math.min(...c.values);
      const maxim = Math.max(...c.values);
      const mini = Math.floor(minim);
      const maxi = Math.ceil(maxim);
      const dim = {
        label,
        values: c.values,
        range: [mini, maxi],
      };
      const obj = isMin ? minim : maxim;
      const crange = isMin ? [obj, obj + 0.05 * (maxi - mini)] : [obj - 0.05 * (maxi - mini), obj];
      if (this.props.db.isObjective(c)) {
        dim.constraintrange = crange;
      }
      return dim;
    });
    return dimensions;
  }
}

ParallelCoordinates.propTypes = {
  db: PropTypes.object.isRequired,
  cases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }),
  title: PropTypes.string,
  width: PropTypes.number,
  success: PropTypes.array.isRequired,
};

export default ParallelCoordinates;
