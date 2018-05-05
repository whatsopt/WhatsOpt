import React from 'react';
import Plot from 'react-plotly.js';
import update from 'immutability-helper' //import {api, url} from '../utils/WhatsOptApi';
import ParallelCoordinates from 'plotter/components/ParallelCoordinates';
import ScatterPlotMatrix from 'plotter/components/ScatterPlotMatrix';
import IterationLinePlot from 'plotter/components/IterationLinePlot';
import AnalysisDatabase from '../utils/AnalysisDatabase';
import compare from '../utils/cases.js'; 

class Plotter extends React.Component {
   
  constructor(props) {
    super(props)
    this.db = new AnalysisDatabase(this.props.mda)
  }
    
  render() {
    let db = this.props.db;
    let cases = this.props.ope.cases.sort(compare);
    
    let isOptim = (this.props.ope.category === "optimization");
    let plotoptim = (<ScatterPlotMatrix db={this.db} cases={cases} optim={isOptim} />);
    if (isOptim) {
        plotoptim = (<IterationLinePlot db={this.db} cases={cases} optim={isOptim} />);
    }
      
    return (
      <div>
        <ParallelCoordinates db={this.db} cases={cases} optim={isOptim} />
        {plotoptim}
      </div>
    );
  }    
}

export { Plotter };