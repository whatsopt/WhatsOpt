import React from 'react';
import Plot from 'react-plotly.js';
import update from 'immutability-helper'
import { analysisDatabase } from '../../utils/AnalysisDatabase';

class ParallelCoordinates extends React.Component {
  
  constructor(props) {
    super(props);
    this.db = analysisDatabase(this.props.mda)
  }
  
  render() {    
    let cases = this.props.ope.cases;
    cases.sort(this._sortCases);
    
    let designVarCases = cases.filter(c => { return this.db.isDesignVarCases(c); })
    let outputVarCases = cases.filter(c => { return this.db.isOutputVarCases(c) })
    let couplingVarCases = cases.filter(c => { return this.db.isCouplingVarCases(c) })
    
    let dimensions = this._dimensionFromCases(designVarCases);
    dimensions.push(...this._dimensionFromCases(couplingVarCases)); 
    dimensions.push(...this._dimensionFromCases(outputVarCases));
    let trace = {
      type: 'parcoords',
      dimensions: dimensions,
    };    
    let data = [trace];
    let title = this.props.ope.name + " " + dimensions[0].values.length + " points in parallel coordinates"

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
      let variable = this.db.find(c.varname);
      let label = c.varname;
      label += variable.shape==="(1,)"?"":" "+c.coord_index;
      return { label: label,
               values: c.values,
               range: [Math.floor(Math.min(...c.values)), 
                       Math.ceil(Math.max(...c.values))]};  
    });
    return dimensions;
  }
  
}

export default ParallelCoordinates;