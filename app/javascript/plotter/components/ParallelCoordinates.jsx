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
    let obj = this.props.cases.o.find(c => this.props.db.isObjective(c  ));
    let mini = Math.min(...obj.values);
    let maxi = Math.max(...obj.values);
    if (obj) {
      trace.line = {
        color: obj.values,
        colorscale: 'Jet',
        cmin: mini,
        cmax: maxi,
        showscale: true,
      };
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
    let obj = this.props.db.getObjective();
    let dimensions = cases.map(c => {
      let label = caseUtils.label(c);
      let minim = Math.min(...c.values);
      let mini = Math.floor(minim);
      let maxi = Math.ceil(Math.max(...c.values));
      let dim = { label: label,
                  values: c.values,
                  range: [mini, maxi] };
      if (this.props.db.isObjective(c)) {
        dim['constraintrange'] = [minim - 0.05*(maxi - mini), minim + 0.05*(maxi - mini)];
      }
      return dim;  
    });
    return dimensions;
  }
  
}

export default ParallelCoordinates;