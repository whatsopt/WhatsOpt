import React from 'react';
import Plot from 'react-plotly.js';
import update from 'immutability-helper'

class ParallelCoordinates extends React.Component {
  
  render() {  
    let db = this.props.db;
    let cases = this.props.ope.cases;
    cases.sort(this._sortCases);
    
    let designVarCases = cases.filter(c => { return db.isDesignVarCases(c); })
    let outputVarCases = cases.filter(c => { return db.isOutputVarCases(c) })
    let couplingVarCases = cases.filter(c => { return db.isCouplingVarCases(c) })
    
    let dimensions = this._dimensionFromCases(designVarCases);
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

  _sortCases(a, b) {
    if (a.varname === b.varname) {
      return a.coord_index < b.coord_index ? -1:1
    } 
    return a.varname.localeCompare(b.varname);
  }
  
  _dimensionFromCases(cases) {
    let dimensions = cases.map(c => {
      let label = c.varname;
      label += c.coord_index===-1?"":" "+c.coord_index;
      return { label: label,
               values: c.values,
               range: [Math.floor(Math.min(...c.values)), 
                       Math.ceil(Math.max(...c.values))]};  
    });
    return dimensions;
  }
  
}

export default ParallelCoordinates;