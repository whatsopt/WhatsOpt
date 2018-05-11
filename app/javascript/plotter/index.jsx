import React from 'react';
import Plot from 'react-plotly.js';
import update from 'immutability-helper' //import {api, url} from '../utils/WhatsOptApi';
import ParallelCoordinates from 'plotter/components/ParallelCoordinates';
import ScatterPlotMatrix from 'plotter/components/ScatterPlotMatrix';
import IterationLinePlot from 'plotter/components/IterationLinePlot';
import IterationRadarPlot from 'plotter/components/IterationRadarPlot';
import VariableSelector from 'plotter/components/VariableSelector';
import AnalysisDatabase from '../utils/AnalysisDatabase';
import * as caseUtils from '../utils/cases.js'; 

class Plotter extends React.Component {
   
  constructor(props) {
    super(props)
    this.db = new AnalysisDatabase(this.props.mda);
    this.cases = this.props.ope.cases.sort(caseUtils.compare);
        
    this.inputVarCases = this.cases.filter(c => this.db.isInputVarCases(c));
    this.outputVarCases = this.cases.filter(c => this.db.isOutputVarCases(c));
    this.couplingVarCases = this.cases.filter(c => this.db.isCouplingVarCases(c));

    let sel = this.initializeSelection(this.inputVarCases, this.outputVarCases)
    this.state = { selection: sel };
    
    this.handleSelectionChange = this.handleSelectionChange.bind(this);
  }
    
  initializeSelection(inputs, outputs) {
    let i = inputs.length;
    let o = outputs.length;
    
    let sel = [];
    if (i+o < 10 && i*o < 50) {
      sel.push(...this.inputVarCases, ...this.outputVarCases);
    } else {
      let obj = this.outputVarCases.find(c => this.db.isObjective(c));
      let cstrs = this.outputVarCases.filter(c => this.db.isConstraint(c));
      if (obj) {
        sel.push(...this.inputVarCases.slice(0, 5), obj, ...cstrs.slice(0, 4));
      } else {
        sel.push(...this.inputVarCases.slice(0, 5), ...this.outputVarCases(0, 5));
      }
    }
    return sel;
  }
  
  handleSelectionChange(event) {
    let target = event.target;
    let newSelection;
    if (target.checked) {
      let selected = this.cases.find(c => caseUtils.label(c) === target.name) 
      newSelection = update(this.state.selection, {$push: [selected]}); 
    } else {
      let index = this.state.selection.findIndex(c => caseUtils.label(c) === target.name);
      newSelection = update(this.state.selection, {$splice: [[index, 1]]});       
    }
    this.setState({selection: newSelection });
  }
  
  render() {  
    let isOptim = (this.props.ope.category === "optimization");
    let selection = this.state.selection;
    let cases = {i: this.inputVarCases, o: this.outputVarCases, c: this.couplingVarCases};
    let selCases = {i: cases.i.filter(c => selection.includes(c)),
                    o: cases.o.filter(c => selection.includes(c)),
                    c: cases.c.filter(c => selection.includes(c)),};    
    let nbPts = this.cases[0]?this.cases[0].values.length:0; 
    let details = `${nbPts} cases`;
    if (isOptim) {
        let objname = this.db.getObjective().variable.name;
        let extremization = this.db.getObjective().isMin?"minimization":"maximization"
        details = `Variable '${objname}' ${extremization} in ${nbPts} evaluations`;
    }
    let title = `${this.props.ope.name} on ${this.props.mda.name} - ${details}`;
    let plotoptim = (<ScatterPlotMatrix db={this.db} optim={isOptim} cases={selCases} title={title}/>);
    if (isOptim) {    
        plotoptim = (<div>
                       <IterationLinePlot db={this.db} optim={isOptim} cases={selCases} title={title}/>
                       <IterationRadarPlot db={this.db} optim={isOptim} cases={selCases} title={title}/>
                     </div>);
    }

    return (      
      <div>
        <ul className="nav nav-tabs" id="myTab" role="tablist">
          <li className="nav-item">
            <a className="nav-link active" id="plots-tab" data-toggle="tab" href="#plots" role="tab" aria-controls="plots" aria-selected="true">Plots</a>
          </li>
          <li className="nav-item">
            <a className="nav-link" id="variables-tab" data-toggle="tab" href="#variables" role="tab" aria-controls="variables" aria-selected="false">Variables</a>
          </li>
        </ul>
        <div className="tab-content" id="myTabContent">
          <div className="tab-pane fade show active" id="plots" role="tabpanel" aria-labelledby="plots-tab">    
            <ParallelCoordinates db={this.db} optim={isOptim} cases={selCases} title={title}/>
            {plotoptim}
          </div>
          <div className="tab-pane fade" id="variables" role="tabpanel" aria-labelledby="variables-tab">
            <VariableSelector db={this.db} optim={isOptim} cases={cases} selCases={selCases}
                              onSelectionChange={this.handleSelectionChange}/>
          </div>
        </div>
      </div>
    );
  }    
}

export { Plotter };