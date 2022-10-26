import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper'; // import {api, url} from '../utils/WhatsOptApi';
import ParallelCoordinates from 'plotter/components/ParallelCoordinates';
import ScatterPlotMatrix from 'plotter/components/ScatterPlotMatrix';
import IterationLinePlot from 'plotter/components/IterationLinePlot';
import IterationRadarPlot from 'plotter/components/IterationRadarPlot';
import ScatterSurfacePlot from 'plotter/components/ScatterSurfacePlot';
import VariableSelector from 'plotter/components/VariableSelector';
import MetaModelManager from 'plotter/components/MetaModelManager';
import AnalysisDatabase from '../utils/AnalysisDatabase';
import * as caseUtils from '../utils/cases';
import DistributionHistogram from './components/DistributionHistogram';

const PLOTS_TAB = 'plots';
const VARIABLES_TAB = 'variables';
const METAMODEL_TAB = 'metamodel';

class PlotPanel extends React.Component {
  shouldComponentUpdate(nextProps /* ,  nextState */) {
    return nextProps.active;
  }

  render() {
    const {
      db, optim, cases, success, title, uqMode,
    } = this.props;

    let plotdist;
    if (uqMode) {
      plotdist = (
        <DistributionHistogram
          db={db}
          optim
          cases={cases}
          success={success}
          title={title}
        />
      );
    }

    let plotoptim = (
      <ScatterPlotMatrix
        db={db}
        optim
        cases={cases}
        success={success}
        title={title}
      />
    );
    if (optim) {
      plotoptim = (
        <div>
          <IterationLinePlot
            db={db}
            optim
            cases={cases}
            title={title}
          />
          <IterationRadarPlot
            db={db}
            optim
            cases={cases}
            title={title}
          />
        </div>
      );
    }
    let plotparall = (
      <ParallelCoordinates
        db={db}
        optim
        cases={cases}
        success={success}
        title={title}
        width={1200}
      />
    );
    const inputCases = [].concat(cases.i).concat(cases.c);
    if (inputCases.length === 2 && cases.o.length === 1) {
      plotparall = (
        <div>
          <ScatterSurfacePlot
            casesx={inputCases[0]}
            casesy={inputCases[1]}
            casesz={cases.o[0]}
            success={success}
            title={title}
          />
          <ParallelCoordinates
            db={db}
            optim
            cases={cases}
            success={success}
            title={title}
            width={600}
          />
        </div>
      );
    }

    return (
      <div className="tab-pane fade" id={PLOTS_TAB} role="tabpanel" aria-labelledby="plots-tab">
        {plotdist}
        {plotparall}
        {plotoptim}
      </div>
    );
  }
}

PlotPanel.propTypes = {
  active: PropTypes.bool.isRequired,
  db: PropTypes.object.isRequired,
  optim: PropTypes.bool.isRequired,
  cases: PropTypes.object.isRequired,
  title: PropTypes.string.isRequired,
  success: PropTypes.array.isRequired,
  uqMode: PropTypes.bool.isRequired,
};

class VariablePanel extends React.PureComponent {
  render() {
    const {
      db, optim, uqMode, cases, selCases, onSelectionChange,
    } = this.props;
    const klass = 'tab-pane fade';
    return (
      <div className={klass} id={VARIABLES_TAB} role="tabpanel" aria-labelledby="variables-tab">
        <VariableSelector
          db={db}
          optim={optim}
          uqMode={uqMode}
          cases={cases}
          selCases={selCases}
          onSelectionChange={onSelectionChange}
        />
      </div>
    );
  }
}

VariablePanel.propTypes = {
  db: PropTypes.object.isRequired,
  optim: PropTypes.bool.isRequired,
  uqMode: PropTypes.bool.isRequired,
  cases: PropTypes.object.isRequired,
  selCases: PropTypes.object.isRequired,
  onSelectionChange: PropTypes.func.isRequired,
};

class MetaModelPanel extends React.Component {
  shouldComponentUpdate(nextProps /* , nextState */) {
    return nextProps.active;
  }

  render() {
    const {
      active, opeId, api, selCases, onMetaModelCreate, uqMode,
    } = this.props;
    const metamodel = (
      <MetaModelManager
        active={active}
        opeId={opeId}
        api={api}
        uqMode={uqMode}
        selCases={selCases}
        onMetaModelCreate={onMetaModelCreate}
      />
    );
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
  uqMode: PropTypes.bool.isRequired,
  selCases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }).isRequired,
  onMetaModelCreate: PropTypes.func.isRequired,
};

class Plotter extends React.Component {
  constructor(props) {
    super(props);
    const {
      api, mda, uqMode, ope,
    } = this.props;
    this.api = api;
    this.db = new AnalysisDatabase(mda);
    this.cases = ope.cases.sort(caseUtils.compare);

    this.outputVarCases = this.cases.filter((c) => this.db.isOutputVarCases(c));
    this.couplingVarCases = this.cases.filter((c) => this.db.isCouplingVarCases(c));

    let inputVarCases = [];
    if (uqMode) {
      inputVarCases = this.cases.filter((c) => this.db.isUncertainVarCases(c));
    } else {
      inputVarCases = this.cases.filter((c) => this.db.isDesignVarCases(c));
    }
    const selection = this.initializeSelection(inputVarCases, this.outputVarCases);
    this.state = { inputVarCases, selection, activeTab: PLOTS_TAB };

    this.handleSelectionChange = this.handleSelectionChange.bind(this);
    this.handleMetaModelCreate = this.handleMetaModelCreate.bind(this);
    this.activateTab = this.activateTab.bind(this);
  }

  componentDidMount() {
    // eslint-disable-next-line no-undef
    $('#plots').tab('show');
  }

  handleSelectionChange(event) {
    const { target } = event;
    const { selection } = this.state;
    let newSelection;
    if (target.checked) {
      const selected = this.cases.find((c) => caseUtils.label(c) === target.name);
      newSelection = update(selection, { $push: [selected] });
    } else {
      const index = selection.findIndex((c) => caseUtils.label(c) === target.name);
      newSelection = update(selection, { $splice: [[index, 1]] });
    }
    this.setState({ selection: newSelection });
  }

  handleMetaModelCreate() {
    console.log('Create MetaModel... ');
    const { api, ope } = this.props;
    api.createMetaModel(
      ope.id,
      (response) => { console.log(response.data); },
    );
  }

  initializeSelection(inputs, outputs) {
    const i = inputs.length;
    const o = outputs.length;

    const sel = [];
    if (i + o < 10 && i * o < 50) {
      sel.push(...inputs, ...outputs);
    } else {
      const obj = inputs.find((c) => this.db.isObjective(c));
      const cstrs = outputs.filter((c) => this.db.isConstraint(c));
      if (obj) {
        sel.push(...inputs.slice(0, 5), obj, ...cstrs.slice(0, 4));
      } else {
        sel.push(...inputs.slice(0, 5), ...this.outputVarCases.slice(0, 5));
      }
    }
    return sel;
  }

  activateTab(event, active) {
    const newState = update(this.state, { activeTab: { $set: active } });
    this.setState(newState);
  }

  render() {
    const { ope, mda, uqMode } = this.props;
    const isOptim = (ope.category === 'optimization' || ope.category === 'egmdo');
    const isDoe = (ope.category === 'doe' || ope.category === 'egdoe');
    const { selection, inputVarCases } = this.state;
    const cases = { i: inputVarCases, o: this.outputVarCases, c: this.couplingVarCases };
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
    const title = `${ope.name} on ${mda.name} - ${details}`;

    const { activeTab } = this.state;

    let metaModelItem; let metaModelPanel;
    if (isDoe) {
      metaModelItem = (
        <li className="nav-item">
          <a
            className="nav-link"
            id="metamodel-tab"
            href="#metamodel"
            role="tab"
            aria-controls="metamodel"
            data-bs-toggle="tab"
            aria-selected="false"
            onClick={(e) => this.activateTab(e, METAMODEL_TAB)}
          >
            MetaModel
          </a>
        </li>
      );
      metaModelPanel = (
        <MetaModelPanel
          active={activeTab === METAMODEL_TAB}
          api={this.api}
          opeId={ope.id}
          uqMode={uqMode}
          selCases={selCases}
          onMetaModelCreate={this.handleMetaModelCreate}
        />
      );
    }

    const exportUrl = this.api.url(`/operations/${ope.id}/exports/new`);
    return (
      <div>
        <h1>
          {ope.name}
          {' '}
          on
          {' '}
          <a href={this.api.url(`/analyses/${mda.id}`)}>{mda.name}</a>
          <small>
            {` (#${mda.id})`}
          </small>
        </h1>

        <div className="btn-group me-2  float-end" role="group">
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
              data-bs-toggle="tab"
              aria-selected="true"
              onClick={(e) => this.activateTab(e, PLOTS_TAB)}
            >
              Plots
            </a>
          </li>
          {metaModelItem}
          <li className="nav-item">
            <a
              className="nav-link"
              id="variables-tab"
              href="#variables"
              role="tab"
              aria-controls="variables"
              data-bs-toggle="tab"
              aria-selected="false"
              onClick={(e) => this.activateTab(e, VARIABLES_TAB)}
            >
              Variables
            </a>
          </li>
        </ul>
        <div className="tab-content" id="myTabContent">
          <PlotPanel
            db={this.db}
            optim={isOptim}
            uqMode={uqMode}
            cases={selCases}
            title={title}
            active={activeTab === PLOTS_TAB}
            success={ope.success}
          />
          {metaModelPanel}
          <VariablePanel
            db={this.db}
            optim={isOptim}
            uqMode={uqMode}
            cases={cases}
            selCases={selCases}
            active={activeTab === VARIABLES_TAB}
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
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
  }).isRequired,
  ope: PropTypes.shape({
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
    driver: PropTypes.string.isRequired,
    category: PropTypes.string.isRequired,
    cases: PropTypes.array.isRequired,
    success: PropTypes.array.isRequired,
  }).isRequired,
  uqMode: PropTypes.bool.isRequired,
};

export default Plotter;
