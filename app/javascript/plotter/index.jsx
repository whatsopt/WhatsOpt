import React from 'react';
import Plot from 'react-plotly.js';
import update from 'immutability-helper' //import {api, url} from '../utils/WhatsOptApi';
import ParallelCoordinates from 'plotter/components/ParallelCoordinates';
import ScatterPlotMatrix from 'plotter/components/ScatterPlotMatrix';
//import AnalysisDatabase from '../utils/AnalysisDatabase';

class Plotter extends React.Component {
   
//  constructor(props) {
//    super(props)
//    this.db = AnalysisDatabase(this.props.mda)
//  }
  
//  componentDidMount() {
//    api.getOperation(this.props.operationId, (response) => {
//      let newState = update(this.state, { data: {$set: response.data }});
//      this.setState(newState);  
//    });
//  } 
   
  render() {
    return (
      <div>
        <ParallelCoordinates mda={this.props.mda} ope={this.props.ope} />
        <ScatterPlotMatrix mda={this.props.mda} ope={this.props.ope} />
      </div>
    );
  }    
}

export { Plotter };