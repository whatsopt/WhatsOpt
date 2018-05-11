import React from 'react';
import Plot from 'react-plotly.js';
import * as caseUtils from '../../utils/cases.js'; 

class ParallelCoordinates extends React.Component {
  
  render() {  
    let dimensions = this._dimensionFromCases(this.props.cases.i);
    dimensions.push(...this._dimensionFromCases(this.props.cases.o)); 
    dimensions.push(...this._dimensionFromCases(this.props.cases.c));
    
    let trace = {
      type: 'parcoords',
      dimensions: dimensions,
    };
    let obj = this.props.cases.o.find(c => this.props.db.isObjective(c));
    if (obj) {
      let mini = Math.min(...obj.values);
      let maxi = Math.max(...obj.values);
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
    
    let data = [trace];
    let title = this.props.title;

    return (
      <div>
          <Plot
            data={data}
            layout={{ width: 1200, height: 500, title: title }}
          />
      </div>
    );
  }
  
  _dimensionFromCases(cases) {
    let isMin = this.props.db.getObjective().isMin;
    let dimensions = cases.map(c => {
      let label = caseUtils.label(c);
      let minim = Math.min(...c.values);
      let maxim = Math.max(...c.values);
      let mini = Math.floor(minim);
      let maxi = Math.ceil(maxim);
      let dim = { label: label,
                  values: c.values,
                  range: [mini, maxi] };
      let obj = isMin?minim:maxim;
      let crange = [obj - 0.05*(maxi - mini), obj + 0.05*(maxi - mini)];
      if (this.props.db.isObjective(c)) {
        dim['constraintrange'] = crange;
      }
      return dim;  
    });
    return dimensions;
  }
  
}

export default ParallelCoordinates;