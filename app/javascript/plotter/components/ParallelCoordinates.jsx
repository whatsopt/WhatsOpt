import React from 'react';
import PropTypes from 'prop-types';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

import * as caseUtils from '../../utils/cases';
import { COLORSCALE } from './colorscale';

const Plot = createPlotlyComponent(Plotly);

class ParallelCoordinates extends React.PureComponent {
  _dimensionFromCases(cases) {
    const { db } = this.props;
    const isMin = db.getObjective() && db.getObjective().isMin;
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
      if (db.isObjective(c)) {
        dim.constraintrange = crange;
      }
      return dim;
    });
    return dimensions;
  }

  render() {
    const { cases, success, title } = this.props;
    const dimensions = this._dimensionFromCases(cases.i);
    dimensions.push(...this._dimensionFromCases(cases.o));
    dimensions.push(...this._dimensionFromCases(cases.c));

    const trace = {
      type: 'parcoords',
      dimensions,
    };

    trace.line = {
      color: success,
      cmin: 0,
      cmax: 1,
      colorscale: COLORSCALE,
    };

    const data = [trace];
    const { width } = this.props;
    return (
      <div>
        <Plot
          data={data}
          layout={{ width, height: 500, title }}
        />
      </div>
    );
  }
}

ParallelCoordinates.propTypes = {
  db: PropTypes.object.isRequired,
  cases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }).isRequired,
  title: PropTypes.string.isRequired,
  width: PropTypes.number.isRequired,
  success: PropTypes.array.isRequired,
};

export default ParallelCoordinates;
