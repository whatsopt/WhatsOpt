import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper'; // import {api, url} from '../utils/WhatsOptApi';
import ParallelCoordinates from 'plotter/components/ParallelCoordinates';
import ScatterPlotMatrix from 'plotter/components/ScatterPlotMatrix';
import IterationLinePlot from 'plotter/components/IterationLinePlot';
import IterationRadarPlot from 'plotter/components/IterationRadarPlot';
import VariableSelector from 'plotter/components/VariableSelector';
import AnalysisDatabase from '../utils/AnalysisDatabase';
import * as caseUtils from '../utils/cases.js';

class PlotPanel extends React.Component {
  render() {
    let plotoptim = (<ScatterPlotMatrix db={this.props.db} optim={this.props.optim}
                                        cases={this.props.cases} title={this.props.title}/>);
    if (this.props.optim) {
      plotoptim = (<div>
                     <IterationLinePlot db={this.props.db} optim={this.props.optim}
                                        cases={this.props.cases} title={this.props.title}/>
                     <IterationRadarPlot db={this.props.db} optim={this.props.optim}
                                         cases={this.props.cases} title={this.props.title}/>
                   </div>);
    }
    let klass = "tab-pane fade"+this.props.active?" show active":"";
    return (<div className={klass} id="plots" role="tabpanel" aria-labelledby="plots-tab">
              <ParallelCoordinates db={this.props.db} optim={this.props.optim}
                                   cases={this.props.cases} title={this.props.title}/>
              {plotoptim}
            </div>);
  }
};

PlotPanel.propTypes = {
  db: PropTypes.object.isRequired,
  active: PropTypes.bool.isRequired,
  optim: PropTypes.bool.isRequired,
  cases: PropTypes.object.isRequired,
  title: PropTypes.string.isRequired,
};

class VariablePanel extends React.Component {
  render() {
    let klass = "tab-pane fade "+this.props.active?" show active":"";
    return (
      <div className={klass} id="variables" role="tabpanel" aria-labelledby="variables-tab">
        <VariableSelector db={this.props.db} optim={this.props.optim}
                          cases={this.props.cases} selCases={this.props.selCases}
                          onSelectionChange={this.props.onSelectionChange}/>
      </div>
    );
  };
};

VariablePanel.propTypes = {
  db: PropTypes.object.isRequired,
  active: PropTypes.bool.isRequired,
  optim: PropTypes.bool.isRequired,
  cases: PropTypes.object.isRequired,
  selCases: PropTypes.object.isRequired,
  onSelectionChange: PropTypes.func.isRequired,
};

class Plotter extends React.Component {
  constructor(props) {
    super(props);
    this.db = new AnalysisDatabase(this.props.mda);
    this.cases = this.props.ope.cases.sort(caseUtils.compare);

    this.inputVarCases = this.cases.filter((c) => this.db.isDesignVarCases(c));
    this.outputVarCases = this.cases.filter((c) => this.db.isOutputVarCases(c));
    this.couplingVarCases = this.cases.filter((c) => this.db.isCouplingVarCases(c));

    let selection = this.initializeSelection(this.inputVarCases, this.outputVarCases);
    this.state = {selection: selection, plotActive: true};

    this.handleSelectionChange = this.handleSelectionChange.bind(this);
    this.activatePlot = this.activatePlot.bind(this);
  }

  initializeSelection(inputs, outputs) {
    let i = inputs.length;
    let o = outputs.length;

    let sel = [];
    if (i+o < 10 && i*o < 50) {
      sel.push(...this.inputVarCases, ...this.outputVarCases);
    } else {
      let obj = this.outputVarCases.find((c) => this.db.isObjective(c));
      let cstrs = this.outputVarCases.filter((c) => this.db.isConstraint(c));
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
      let selected = this.cases.find((c) => caseUtils.label(c) === target.name);
      newSelection = update(this.state.selection, {$push: [selected]});
    } else {
      let index = this.state.selection.findIndex((c) => caseUtils.label(c) === target.name);
      newSelection = update(this.state.selection, {$splice: [[index, 1]]});
    }
    this.setState({selection: newSelection});
  }

  activatePlot(active) {
    let newState = update(this.state, {plotActive: {$set: active}});
    this.setState(newState);
  }

  render() {
    let isOptim = (this.props.ope.category === "optimization");
    let selection = this.state.selection;
    let cases = {i: this.inputVarCases, o: this.outputVarCases, c: this.couplingVarCases};
    let selCases = {i: cases.i.filter((c) => selection.includes(c)),
                    o: cases.o.filter((c) => selection.includes(c)),
                    c: cases.c.filter((c) => selection.includes(c))};
    let nbPts = this.cases[0]?this.cases[0].values.length:0;
    let details = `${nbPts} cases`;
    if (isOptim) {
        let objname = this.db.getObjective().variable.name;
        let extremization = this.db.getObjective().isMin?"minimization":"maximization";
        details = `Variable '${objname}' ${extremization} in ${nbPts} evaluations`;
    }
    let title = `${this.props.ope.name} on ${this.props.mda.name} - ${details}`;
    let child = (<PlotPanel db={this.db} optim={isOptim} cases={selCases}
                 title={title} active={this.state.plotActive}/>);
    if (!this.state.plotActive) {
      child = (<VariablePanel db={this.db} optim={isOptim} cases={cases} selCases={selCases}
                active={!this.state.plotActive} onSelectionChange={this.handleSelectionChange}/>);
    }

    return (
      <div>
        <h1>Plots for {this.props.mda.name} {this.props.ope.driver} {this.props.ope.category} </h1>

        <ul className="nav nav-tabs" id="myTab" role="tablist">
          <li className="nav-item">
            <a className="nav-link active" id="plots-tab" href="#plots"
               role="tab" aria-controls="plots" data-toggle="tab" aria-selected="true"
               onClick={(e) => this.activatePlot(true)}>Plots</a>
          </li>
          <li className="nav-item">
            <a className="nav-link" id="variables-tab" href="#variables"
               role="tab" aria-controls="variables" data-toggle="tab" aria-selected="false"
               onClick={(e) => this.activatePlot(false)}>Variables</a>
          </li>
        </ul>
        <div className="tab-content" id="myTabContent">
          {child}
        </div>
      </div>
    );
  }
}

Plotter.propTypes = {
  mda: PropTypes.shape({
    name: PropTypes.string,
  }),
  ope: PropTypes.shape({
    name: PropTypes.string,
    category: PropTypes.string,
    cases: PropTypes.array,
  }),
};

export default Plotter;
