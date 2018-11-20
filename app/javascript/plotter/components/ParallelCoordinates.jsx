import React from 'react';
import PropTypes from 'prop-types';
import Plot from 'react-plotly.js';
import * as caseUtils from '../../utils/cases.js';

class ParallelCoordinates extends React.Component {
  render() {
    const dimensions = this._dimensionFromCases(this.props.cases.i);
    dimensions.push(...this._dimensionFromCases(this.props.cases.o));
    dimensions.push(...this._dimensionFromCases(this.props.cases.c));

    const trace = {
      type: 'parcoords',
      dimensions: dimensions,
    };
    const obj = this.props.cases.o.find((c) => this.props.db.isObjective(c));
    if (obj) {
      const mini = Math.min(...obj.values);
      const maxi = Math.max(...obj.values);
      trace.line = {
        color: obj.values,
        colorscale: 'Blues',
        cmin: mini,
        cmax: maxi,
        showscale: true,
      };
      if (this.props.db.isMaxObjective()) {
        trace.line.reversescale = true;
      }
    }

    const data = [trace];
    const title = this.props.title;

    return (
      <div>
        <Plot
          data={data}
          layout={{width: 1200, height: 500, title: title}}
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
      const dim = {label: label,
        values: c.values,
        range: [mini, maxi]};
      const obj = isMin?minim:maxim;
      const crange = [obj - 0.05*(maxi - mini), obj + 0.05*(maxi - mini)];
      if (this.props.db.isObjective(c)) {
        dim['constraintrange'] = crange;
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
};

export default ParallelCoordinates;
