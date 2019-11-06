import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper'; // import {api, url} from '../utils/WhatsOptApi';
import ParallelCoordinates from 'plotter/components/ParallelCoordinates';
import ScatterPlotMatrix from 'plotter/components/ScatterPlotMatrix';
import IterationLinePlot from 'plotter/components/IterationLinePlot';
import IterationRadarPlot from 'plotter/components/IterationRadarPlot';
import ScatterSurfacePlot from 'plotter/components/ScatterSurfacePlot';
import ScreeningScatterPlot from 'plotter/components/ScreeningScatterPlot';
import VariableSelector from 'plotter/components/VariableSelector';
import MetaModelManager from 'plotter/components/MetaModelManager';
import AnalysisDatabase from '../utils/AnalysisDatabase';
import * as caseUtils from '../utils/cases.js';

const PLOTS_TAB = 'plots';
const VARIABLES_TAB = 'variables';
const SCREENING_TAB = 'screening';
const METAMODEL_TAB = 'metamodel';

class PlotPanel extends React.Component {
  render() {
    let plotoptim = (
      <ScatterPlotMatrix
        db={this.props.db}
        optim={this.props.optim}
        cases={this.props.cases}
        success={this.props.success}
        title={this.props.title}
      />
    );
    if (this.props.optim) {
      plotoptim = (
        <div>
          <IterationLinePlot
            db={this.props.db}
            optim={this.props.optim}
            cases={this.props.cases}
            title={this.props.title}
          />
          <IterationRadarPlot
            db={this.props.db}
            optim={this.props.optim}
            cases={this.props.cases}
            title={this.props.title}
          />
        </div>
      );
    }
    let plotparall = (
      <ParallelCoordinates
        db={this.props.db}
        optim={this.props.optim}
        cases={this.props.cases}
        success={this.props.success}
        title={this.props.title}
        width={1200}
      />
    );
    const inputCases = [].concat(this.props.cases.i).concat(this.props.cases.c);
    if (inputCases.length == 2 && this.props.cases.o.length == 1) {
      plotparall = (
        <span>
          <ScatterSurfacePlot
            casesx={inputCases[0]}
            casesy={inputCases[1]}
            casesz={this.props.cases.o[0]}
            success={this.props.success}
          />
          <ParallelCoordinates
            db={this.props.db}
            optim={this.props.optim}
            cases={this.props.cases}
            success={this.props.success}
            title={this.props.title}
            width={600}
          />
        </span>
      );
    }

    return (
      <div className="tab-pane fade" id={PLOTS_TAB} role="tabpanel" aria-labelledby="plots-tab">
        {plotparall}
        {plotoptim}
      </div>
    );
  }
}

PlotPanel.propTypes = {
  db: PropTypes.object.isRequired,
  active: PropTypes.bool.isRequired,
  optim: PropTypes.bool.isRequired,
  cases: PropTypes.object.isRequired,
  title: PropTypes.string.isRequired,
  success: PropTypes.array.isRequired,
};

class VariablePanel extends React.Component {
  render() {
    const klass = 'tab-pane fade';
    return (
      <div className={klass} id={VARIABLES_TAB} role="tabpanel" aria-labelledby="variables-tab">
        <VariableSelector
          db={this.props.db}
          optim={this.props.optim}
          cases={this.props.cases}
          selCases={this.props.selCases}
          onSelectionChange={this.props.onSelectionChange}
        />
      </div>
    );
  }
}

VariablePanel.propTypes = {
  db: PropTypes.object.isRequired,
  active: PropTypes.bool.isRequired,
  optim: PropTypes.bool.isRequired,
  cases: PropTypes.object.isRequired,
  selCases: PropTypes.object.isRequired,
  success: PropTypes.array,
  onSelectionChange: PropTypes.func.isRequired,
};

class ScreeningPanel extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      loading: false,
      statusOk: false,
      sensitivity: null,
      error: '',
    };
  }

  componentDidMount() {
    this.props.api.openmdaoScreening(
      this.props.opeId,
      (response) => {
        console.log(response.data);
        this.setState({ loading: false, ...response.data });
      },
    );
  }

  render() {
    let screenings;
    if (this.state.sensitivity) {
      const varnames = Object.keys(this.state.sensitivity).sort();
      const outs = [];
      for (const output of varnames) {
        outs.push([output, this.state.sensitivity[output]]);
      }
      screenings = outs.map((o) => (<ScreeningScatterPlot key={o[0]} outVarName={o[0]} saData={o[1]} />));
    }
    return (
      <div className="tab-pane fade" id={SCREENING_TAB} role="tabpanel" aria-labelledby="screening-tab">
        {screenings}
      </div>
    );
  }
}

ScreeningPanel.propTypes = {
  opeId: PropTypes.number.isRequired,
  api: PropTypes.object.isRequired,
  active: PropTypes.bool.isRequired,
};

class MetaModelPanel extends React.Component {
  constructor(props) {
    super(props);
  }

  componentDidMount() {
  }

  render() {
    const metamodel = (<MetaModelManager {...this.props} />);
    return (
      <div className="tab-pane fade" id={METAMODEL_TAB} role="tabpanel" aria-labelledby="metamodel-tab">
        {metamodel}
      </div>
    );
  }
}

MetaModelPanel.propTypes = {
  active: PropTypes.bool.isRequired,
  opeId: PropTypes.number.isRequired,
  api: PropTypes.object.isRequired,
  selCases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }),
  onMetaModelCreate: PropTypes.func.isRequired,
};

class Plotter extends React.Component {
  constructor(props) {
    super(props);
    this.api = this.props.api;
    this.db = new AnalysisDatabase(this.props.mda);
    this.cases = this.props.ope.cases.sort(caseUtils.compare);

    this.inputVarCases = this.cases.filter((c) => this.db.isDesignVarCases(c));
    this.outputVarCases = this.cases.filter((c) => this.db.isOutputVarCases(c));
    this.couplingVarCases = this.cases.filter((c) => this.db.isCouplingVarCases(c));

    const selection = this.initializeSelection(this.inputVarCases, this.outputVarCases);
    this.state = { selection, activeTab: true };

    this.handleSelectionChange = this.handleSelectionChange.bind(this);
    this.handleMetaModelCreate = this.handleMetaModelCreate.bind(this);
    this.activateTab = this.activateTab.bind(this);
  }

  initializeSelection(inputs, outputs) {
    const i = inputs.length;
    const o = outputs.length;

    const sel = [];
    if (i + o < 10 && i * o < 50) {
      sel.push(...this.inputVarCases, ...this.outputVarCases);
    } else {
      const obj = this.outputVarCases.find((c) => this.db.isObjective(c));
      const cstrs = this.outputVarCases.filter((c) => this.db.isConstraint(c));
      if (obj) {
        sel.push(...this.inputVarCases.slice(0, 5), obj, ...cstrs.slice(0, 4));
      } else {
        sel.push(...this.inputVarCases.slice(0, 5), ...this.outputVarCases.slice(0, 5));
      }
    }
    return sel;
  }

  handleSelectionChange(event) {
    const { target } = event;
    let newSelection;
    if (target.checked) {
      const selected = this.cases.find((c) => caseUtils.label(c) === target.name);
      newSelection = update(this.state.selection, { $push: [selected] });
    } else {
      const index = this.state.selection.findIndex((c) => caseUtils.label(c) === target.name);
      newSelection = update(this.state.selection, { $splice: [[index, 1]] });
    }
    this.setState({ selection: newSelection });
  }

  handleMetaModelCreate(event) {
    console.log('Create MetaModel... ');
    this.props.api.createMetaModel(
      this.props.ope.id,
      (response) => {
        console.log(response.data);
      },
    );
  }

  activateTab(event, active) {
    const newState = update(this.state, { activeTab: { $set: active } });
    this.setState(newState);
  }

  componentDidMount() {
    $('#plots').tab('show');
  }

  render() {
    const isOptim = (this.props.ope.category === 'optimization');
    const isScreening = (this.props.ope.category === 'screening');
    const isDoe = (this.props.ope.category === 'doe');
    const { selection } = this.state;
    const cases = { i: this.inputVarCases, o: this.outputVarCases, c: this.couplingVarCases };
    const selCases = {
      i: cases.i.filter((c) => selection.includes(c)),
      o: cases.o.filter((c) => selection.includes(c)),
      c: cases.c.filter((c) => selection.includes(c)),
    };
    const nbPts = this.cases[0] ? this.cases[0].values.length : 0;
    let details = `${nbPts} cases`;
    if (isOptim) {
      const objname = this.db.getObjective().variable.name;
      const extremization = this.db.getObjective().isMin ? 'minimization' : 'maximization';
      details = `${objname} ${extremization}`;
    }
    const title = `${this.props.ope.name} on ${this.props.mda.name} - ${details}`;


    let screeningItem; let screeningPanel;
    if (isScreening) {
      screeningItem = (
        <li className="nav-item">
          <a
            className="nav-link"
            id="screening-tab"
            href="#screening"
            role="tab"
            aria-controls="screening"
            data-toggle="tab"
            aria-selected="false"
            onClick={(e) => this.activateTab(e, SCREENING_TAB)}
          >
Screening
          </a>
        </li>
      );
      screeningPanel = (
        <ScreeningPanel
          active={this.state.activeTab === SCREENING_TAB}
          api={this.api}
          opeId={this.props.ope.id}
        />
      );
    }
    let metaModelItem; let metaModelPanel;
    if (isDoe) {
      const varnames = [...new Set(selection.map((v) => v.varname))];
      metaModelItem = (
        <li className="nav-item">
          <a
            className="nav-link"
            id="metamodel-tab"
            href="#metamodel"
            role="tab"
            aria-controls="metamodel"
            data-toggle="tab"
            aria-selected="false"
            onClick={(e) => this.activateTab(e, METAMODEL_TAB)}
          >
MetaModel
          </a>
        </li>
      );
      metaModelPanel = (
        <MetaModelPanel
          active={this.state.activeTab === METAMODEL_TAB}
          api={this.api}
          opeId={this.props.ope.id}
          selCases={selCases}
          onMetaModelCreate={this.handleMetaModelCreate}
        />
      );
    }

    const exportUrl = this.api.url(`/operations/${this.props.ope.id}/exports/new`);
    return (
      <div>
        <h1>
          {this.props.ope.name}
          {' '}
on
          {' '}
          {this.props.mda.name}
        </h1>

        <div className="btn-group mr-2  float-right" role="group">
          <a className="btn btn-primary" href={exportUrl}>Export Csv</a>
        </div>

        <ul className="nav nav-tabs" id="myTab" role="tablist">
          <li className="nav-item">
            <a
              className="nav-link active"
              id="plots-tab"
              href="#plots"
              role="tab"
              aria-controls="plots"
              data-toggle="tab"
              aria-selected="true"
              onClick={(e) => this.activateTab(e, 'plots')}
            >
Plots
            </a>
          </li>
          {screeningItem}
          {metaModelItem}
          <li className="nav-item">
            <a
              className="nav-link"
              id="variables-tab"
              href="#variables"
              role="tab"
              aria-controls="variables"
              data-toggle="tab"
              aria-selected="false"
              onClick={(e) => this.activateTab(e, 'variables')}
            >
Variables
            </a>
          </li>
        </ul>
        <div className="tab-content" id="myTabContent">
          <PlotPanel
            db={this.db}
            optim={isOptim}
            cases={selCases}
            title={title}
            active={this.state.activeTab === PLOTS_TAB}
            success={this.props.ope.success}
          />
          {screeningPanel}
          {metaModelPanel}
          <VariablePanel
            db={this.db}
            optim={isOptim}
            cases={cases}
            selCases={selCases}
            active={this.state.activeTab === VARIABLES_TAB}
            onSelectionChange={this.handleSelectionChange}
          />
        </div>
      </div>
    );
  }
}

Plotter.propTypes = {
  api: PropTypes.object.isRequired,
  mda: PropTypes.shape({
    name: PropTypes.string.isRequired,
  }),
  ope: PropTypes.shape({
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
    driver: PropTypes.string.isRequired,
    category: PropTypes.string.isRequired,
    cases: PropTypes.array.isRequired,
    success: PropTypes.array.isRequired,
  }),
};

export default Plotter;
