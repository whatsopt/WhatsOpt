import React from 'react';
import Plot from 'react-plotly.js';
import update from 'immutability-helper' //import {api, url} from '../utils/WhatsOptApi';
import ParallelCoordinates from 'plotter/components/ParallelCoordinates';
import ScatterPlotMatrix from 'plotter/components/ScatterPlotMatrix';
import AnalysisDatabase from '../utils/AnalysisDatabase';

class Plotter extends React.Component {
   
  constructor(props) {
    super(props)
    this.db = new AnalysisDatabase(this.props.mda)
  }
    
  render() {
    
    let isOptim = (this.props.ope.category === "optimization");
    let plotoptim = (<ScatterPlotMatrix db={this.db} ope={this.props.ope} optim={isOptim} />);
    if (isOptim) {
        plotoptim = (<div></div>);
    }
      
    return (
      <div>
        <ParallelCoordinates db={this.db} ope={this.props.ope} optim={isOptim} />
        {plotoptim}
      </div>
    );
  }    
}

export { Plotter };