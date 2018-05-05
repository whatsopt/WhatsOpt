import React from 'react';
import Plot from 'react-plotly.js';

class ParallelCoordinates extends React.Component {
  
  render() {  
    let db = this.props.db;
    let cases = this.props.cases;
    
    let inputVarCases = cases.filter(c => { return db.isInputVarCases(c); })
    let outputVarCases = cases.filter(c => { return db.isOutputVarCases(c) })
    let couplingVarCases = cases.filter(c => { return db.isCouplingVarCases(c) })
    
    let dimensions = this._dimensionFromCases(inputVarCases);
    dimensions.push(...this._dimensionFromCases(couplingVarCases)); 
    dimensions.push(...this._dimensionFromCases(outputVarCases));
    let trace = {
      type: 'parcoords',
      dimensions: dimensions,
    };    
    let data = [trace];
    let title = "Parallel Coordinates"

    return (
      <div>
          <Plot
            data={data}
            layout={{ width: 1000, height: 400, title: title }}
          />
      </div>
    );
  }
  
  _dimensionFromCases(cases) {
    let obj = this.props.db.findObjective();
    let dimensions = cases.map(c => {
      let label = c.varname;
      label += c.coord_index===-1?"":" "+c.coord_index;
      let mini = Math.floor(Math.min(...c.values));
      let maxi = Math.ceil(Math.max(...c.values));
      let dim = { label: label,
                  values: c.values,
                  range: [mini, maxi] };
      if (this.props.db.isObjective(c)) {
        dim['constraintrange'] = [mini, mini+0.1*(maxi - mini)];
      }
      return dim;  
    });
    return dimensions;
  }
  
}

export default ParallelCoordinates;