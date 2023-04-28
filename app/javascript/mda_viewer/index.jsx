import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';

import XdsmViewer from 'mda_viewer/components/XdsmViewer';
import AnalysisEditor from 'mda_viewer/components/AnalysisEditor';
import AnalysisNotePanel from 'mda_viewer/components/AnalysisNotePanel';
import AnalysisBreadCrumbs from 'mda_viewer/components/AnalysisBreadCrumbs';
import DisciplinesEditor from 'mda_viewer/components/DisciplinesEditor';
import ConnectionsEditor from 'mda_viewer/components/ConnectionsEditor';
import VariablesEditor from 'mda_viewer/components/VariablesEditor';
import OpenmdaoImplEditor from 'mda_viewer/components/OpenmdaoImplEditor';
import ExportPanel from 'mda_viewer/components/ExportPanel';
import HistoryPanel from 'mda_viewer/components/HistoryPanel';
import ComparisonPanel from 'mda_viewer/components/ComparisonPanel';
import DistributionModals from 'mda_viewer/components/DistributionModals';

import Error from '../utils/components/Error';
import MetaModelQualification from '../utils/components/MetaModelQualification';
import AnalysisDatabase from '../utils/AnalysisDatabase';
import deepIsEqual from '../utils/compare';

const VAR_REGEXP = /^[a-zA-Z][_a-zA-Z0-9:.=]*$/;

const reorder = (list, startIndex, endIndex) => {
  const result = Array.from(list);
  const [removed] = result.splice(startIndex, 1);
  result.splice(endIndex, 0, removed);

  return result;
};

function _check_and_set_new_openmdao_impl(old_impl, new_impl) {
  new_impl.nodes.forEach((node, i) => {
    if (node.egmdo_surrogate && node.egmdo_surrogate
      !== old_impl.nodes[i].egmdo_surrogate) {
      // eslint-disable-next-line no-param-reassign
      node.implicit_component = false;
      // eslint-disable-next-line no-param-reassign
      node.support_derivatives = false;
    }
    if ((node.implicit_component && node.implicit_component
        !== old_impl.nodes[i].implicit_component)
      || (node.support_derivatives && node.support_derivatives
        !== old_impl.nodes[i].support_derivatives)) {
      // eslint-disable-next-line no-param-reassign
      node.egmdo_surrogate = false;
    }
  });
}
class MdaViewer extends React.Component {
  constructor(props) {
    super(props);
    const {
      api, members, coOwners, currentUser, mda,
    } = this.props;
    this.api = api;
    const { isEditing } = this.props;
    const filter = { fr: undefined, to: undefined };
    this.db = new AnalysisDatabase(props.mda);
    this.state = {
      filter,
      isEditing,
      mda: props.mda,
      currentUser,
      analysisMembers: members,
      analysisCoOwners: coOwners,
      newAnalysisName: mda.name,
      newDisciplineName: '',
      analysisNote: '',
      selectedConnectionNames: [],
      errors: [],
      implEdited: false,
      mdaEdited: false,
      useScaling: this.db.isScaled(),
    };
    this.handleFilterChange = this.handleFilterChange.bind(this);
    this.handleAnalysisNameChange = this.handleAnalysisNameChange.bind(this);
    this.handleAnalysisNoteChange = this.handleAnalysisNoteChange.bind(this);
    this.handleAnalysisPublicChange = this.handleAnalysisPublicChange.bind(this);
    this.handleAnalysisLockedChange = this.handleAnalysisLockedChange.bind(this);
    this.handleAnalysisUserSearch = this.handleAnalysisUserSearch.bind(this);
    this.handleAnalysisUserCreate = this.handleAnalysisUserCreate.bind(this);
    this.handleAnalysisUserDelete = this.handleAnalysisUserDelete.bind(this);
    this.handleAnalysisUpdate = this.handleAnalysisUpdate.bind(this);
    this.handleDisciplineNameChange = this.handleDisciplineNameChange.bind(this);
    this.handleDisciplineCreate = this.handleDisciplineCreate.bind(this);
    this.handleDisciplineImport = this.handleDisciplineImport.bind(this);
    this.handleDisciplineUpdate = this.handleDisciplineUpdate.bind(this);
    this.handleDisciplineDelete = this.handleDisciplineDelete.bind(this);
    this.handleSubAnalysisSearch = this.handleSubAnalysisSearch.bind(this);
    this.handleConnectionNameChange = this.handleConnectionNameChange.bind(this);
    this.handleConnectionCreate = this.handleConnectionCreate.bind(this);
    this.handleConnectionDelete = this.handleConnectionDelete.bind(this);
    this.handleConnectionDelete = this.handleConnectionDelete.bind(this);
    this.handleConnectionChange = this.handleConnectionChange.bind(this);
    this.handleErrorClose = this.handleErrorClose.bind(this);
    this.handleOpenmdaoImplUpdate = this.handleOpenmdaoImplUpdate.bind(this);
    this.handleOpenmdaoImplChange = this.handleOpenmdaoImplChange.bind(this);
    this.handleOpenmdaoImplReset = this.handleOpenmdaoImplReset.bind(this);
    this.handleProjectSearch = this.handleProjectSearch.bind(this);
    this.handleProjectSelected = this.handleProjectSelected.bind(this);
    this.renderXdsm = this.renderXdsm.bind(this);
    this.displayError = this.displayError.bind(this);
  }

  handleFilterChange(filter) {
    const newState = update(this.state, { filter: { $set: filter } });
    this.setState(newState);
    this.xdsmViewer.setSelection(filter);
  }

  // *** Connections *********************************************************

  handleConnectionNameChange(selected) {
    // console.log(selected);
    const selection = this._validateConnectionNames(selected);
    const newState = update(this.state, {
      selectedConnectionNames: { $set: selection.selected },
      errors: { $set: selection.errors },
    });
    this.setState(newState);
  }

  handleConnectionCreate(event) {
    event.preventDefault();

    const { errors, selectedConnectionNames, filter } = this.state;
    const { mda } = this.props;
    if (errors.length > 0) {
      return;
    }
    const names = selectedConnectionNames.map((e) => e.name);
    // console.log("CREATE", names);
    const data = { from: filter.fr, to: filter.to, names };
    this.api.createConnection(mda.id, data, () => {
      const newState = update(this.state, { selectedConnectionNames: { $set: [] } });
      this.setState(newState);
      // console.log("NEW CONNECTION RESET");
      this.renderXdsm();
    }, this.displayError);
  }

  handleConnectionChange(connId, connAttrs) {
    const { mda } = this.state;
    // parameter
    const cAttrs = JSON.parse(JSON.stringify(connAttrs));
    if (connAttrs.init || connAttrs.init === '') {
      cAttrs.parameter_attributes = { init: connAttrs.init };
    }
    if (connAttrs.lower || connAttrs.lower === '') {
      cAttrs.parameter_attributes = { lower: connAttrs.lower };
    }
    if (connAttrs.upper || connAttrs.upper === '') {
      cAttrs.parameter_attributes = { upper: connAttrs.upper };
    }
    delete cAttrs.init;
    delete cAttrs.lower;
    delete cAttrs.upper;

    // scaling
    if (connAttrs.ref || connAttrs.ref === '') {
      cAttrs.scaling_attributes = { ref: connAttrs.ref };
    }
    if (connAttrs.ref0 || connAttrs.ref0 === '') {
      cAttrs.scaling_attributes = { ref0: connAttrs.ref0 };
    }
    if (connAttrs.res_ref || connAttrs.res_ref === '') {
      cAttrs.scaling_attributes = { res_ref: connAttrs.res_ref };
    }
    delete cAttrs.ref;
    delete cAttrs.ref0;
    delete cAttrs.res_ref;

    if (Object.keys(cAttrs).length !== 0) {
      this.api.updateConnection(
        mda.id,
        connId,
        cAttrs,
        this.renderXdsm,
        this.displayError,
      );
    }
  }

  handleConnectionDelete(connId) {
    const { mda } = this.state;
    this.api.deleteConnection(
      mda.id,
      connId,
      this.renderXdsm,
      this.displayError,
    );
  }

  // *** Disciplines ************************************************************

  handleDisciplineCreate(event) {
    event.preventDefault();
    const { mda, newDisciplineName } = this.state;
    this.api.createDiscipline(
      mda.id,
      { name: newDisciplineName, type: 'analysis' },
      () => {
        const newState = update(this.state, { newDisciplineName: { $set: '' } });
        this.setState(newState);
        this.renderXdsm();
      },
      this.displayError,
    );
  }

  handleDisciplineImport(mdaFromId, discId, mdaId) {
    this.api.importDiscipline(
      mdaFromId,
      discId,
      mdaId,
      this.renderXdsm,
      this.displayError,
    );
  }

  handleDisciplineNameChange(event) {
    event.preventDefault();
    const newState = update(this.state, { newDisciplineName: { $set: event.target.value } });
    this.setState(newState);
  }

  handleDisciplineUpdate(node, discAttrs) {
    const { mda } = this.state;
    if ('position' in discAttrs) {
      const items = reorder(mda.nodes, mda.nodes.indexOf(node), discAttrs.position);
      const newState = update(this.state, { mda: { nodes: { $set: items } } });
      this.setState(newState);
    }
    this.api.updateDiscipline(
      mda.id,
      node.id,
      discAttrs,
      this.renderXdsm,
      this.displayError,
    );
  }

  handleDisciplineDelete(node) {
    const { filter, mda } = this.state;
    this.api.deleteDiscipline(
      mda.id,
      node.id,
      () => {
        if (filter.fr === node.id || filter.to === node.id) {
          this.handleFilterChange({ fr: undefined, to: undefined });
        }
        this.renderXdsm();
      },
      this.displayError,
    );
  }

  handleSubAnalysisSearch(callback) {
    const { mda } = this.state;
    this.api.getSubAnalysisCandidates(
      (response) => {
        const options = response.data
          .filter((analysis) => analysis.id !== mda.id)
          .map((analysis) => ({ id: analysis.id, label: `#${analysis.id} ${analysis.name}` }));
        callback(options);
      },
    );
  }

  // *** Analysis ************************************************************
  handleAnalysisNameChange(event) {
    event.preventDefault();
    const newState = update(this.state, {
      newAnalysisName: { $set: event.target.value },
      errors: { $set: [] },
      mdaEdited: { $set: true },
    });
    this.setState(newState);
    return false;
  }

  handleProjectSearch(callback) {
    // TODO: query could be used to filter user on server side
    this.api.getProjects((response) => callback(response.data));
  }

  handleProjectSelected(selected) {
    const { mda: { project } } = this.state;
    if (selected !== project) {
      let newState = update(this.state, {
        mdaEdited: { $set: true },
        mda: {
          project: { $set: { id: -1, name: '' } },
        },
      });
      if (selected.length) {
        console.log(`Project: ${JSON.stringify(selected[0])}`);
        newState = update(this.state, {
          mda: { project: { $set: selected[0] } },
        });
      }
      this.setState(newState);
    }
  }

  handleAnalysisNoteChange(event) {
    const newState = update(this.state, {
      mda: { note: { $set: event.target.innerHTML } },
      mdaEdited: { $set: true },
    });
    this.setState(newState);
  }

  handleAnalysisPublicChange() {
    const { mda } = this.state;
    this.api.updateAnalysis(
      mda.id,
      { public: !mda.public },
      () => {
        const newState = update(this.state, { mda: { public: { $set: !mda.public } } });
        this.setState(newState);
      },
      this.displayError,
    );
    return false;
  }

  handleAnalysisLockedChange() {
    const { mda } = this.state;
    this.api.updateAnalysis(
      mda.id,
      { locked: !mda.locked },
      () => {
        const newState = update(this.state, { mda: { locked: { $set: !mda.locked } } });
        this.setState(newState);
      },
      this.displayError,
    );
    return false;
  }

  handleAnalysisUserSearch(query, role, callback) {
    // TODO: query could be used to filter user on server side
    const { mda } = this.state;
    this.api.getUserCandidates(
      mda.id,
      role,
      (response) => {
        callback(response.data);
      },
    );
  }

  handleAnalysisUserCreate(selected, role) {
    const { mda } = this.state;
    if (selected.length) {
      this.api.addUser(
        selected[0].id,
        mda.id,
        role,
        () => {
          this.api.getUsers(mda.id, 'members', (response) => {
            this.setState({ analysisMembers: response.data });
          });
          this.api.getUsers(mda.id, 'co_owners', (response) => {
            this.setState({ analysisCoOwners: response.data });
          });
        },
      );
    }
  }

  handleAnalysisUserDelete(user, role) {
    const { mda } = this.state;
    this.api.removeUser(user.id, mda.id, role, () => {
      this.api.getUsers(mda.id, 'members', (response) => {
        this.setState({ analysisMembers: response.data });
      });
      this.api.getUsers(mda.id, 'co_owners', (response) => {
        this.setState({ analysisCoOwners: response.data });
      });
    });
  }

  handleAnalysisUpdate(event) {
    event.preventDefault();
    const { mda, newAnalysisName } = this.state;
    const params = {
      name: newAnalysisName,
      note: mda.note,
      design_project_id: mda.project.id,
    };
    this.api.updateAnalysis(
      mda.id,
      params,
      () => {
        this.api.getAnalysis(
          mda.id,
          false,
          () => {
            const newState = update(this.state, {
              mdaEdited: { $set: false },
              mda: {
                name: { $set: newAnalysisName },
                note: { $set: mda.note },
                project: { $set: mda.project },
              },
            });
            this.setState(newState);
          },
        );
      },
      this.displayError,
    );
  }

  handleErrorClose(index) {
    const newState = update(this.state, { errors: { $splice: [[index, 1]] } });
    this.setState(newState);
  }

  // *** OpenmdaoImpl ************************************************************
  handleOpenmdaoImplUpdate(openmdaoImpl) {
    const oImpl = JSON.parse(JSON.stringify(openmdaoImpl));
    delete oImpl.use_scaling;
    const { mda } = this.props;
    this.api.updateOpenmdaoImpl(
      mda.id,
      oImpl,
      () => {
        const newState = update(this.state, {
          implEdited: { $set: false },
          mda: { impl: { openmdao: { $set: oImpl } } },
        });
        this.setState(newState);
      },
      this.displayError,
    );
  }

  handleOpenmdaoImplChange(openmdaoImpl) {
    let newState;
    const { mda, implEdited } = this.state;
    if (deepIsEqual(mda.impl.openmdao, openmdaoImpl)) {
      newState = update(this.state, { implEdited: { $set: false } });
    } else if (mda.impl.openmdao.use_scaling === openmdaoImpl.use_scaling) {
      const oldImpl = implEdited || JSON.parse(JSON.stringify(mda.impl.openmdao));
      _check_and_set_new_openmdao_impl(oldImpl, openmdaoImpl);
      newState = update(this.state, { implEdited: { $set: openmdaoImpl } });
    } else {
      newState = update(this.state, { useScaling: { $set: openmdaoImpl.use_scaling } });
    }
    this.setState(newState);
  }

  handleOpenmdaoImplReset() {
    const newState = update(this.state, {
      implEdited: { $set: false },
    });
    this.setState(newState);
  }

  _validateConnectionNames(selected) {
    const names = selected.map((e) => e.name);
    const newSelected = [];
    const errors = [];
    // console.log("VALID: ", names);
    names.forEach((n) => {
      const vnames = n.split(','); // allow "var1, var2" input
      const varnames = vnames.map((name) => name.trim());
      // console.log(varnames);
      varnames.forEach((name) => {
        if (!name.match(VAR_REGEXP)) {
          if (name !== '') {
            errors.push(`Variable name '${name}' is invalid`);
            // console.log("Error: " + errors);
          }
        }
        newSelected.push({ name });
      }, this);
    }, this);
    // console.log(JSON.stringify({ selected: newSelected, errors: errors }));
    return { selected: newSelected, errors };
  }

  displayError(error) {
    const message = error.response.data.message || 'Error: Operation failed';
    const newState = update(this.state, { errors: { $set: [message] } });
    this.setState(newState);
  }

  renderXdsm() {
    const { mda } = this.state;
    this.api.getAnalysis(
      mda.id,
      'whatsopt_ui',
      (response) => {
        const newState = update(
          this.state,
          {
            mda: {
              nodes: { $set: response.data.nodes },
              edges: { $set: response.data.edges },
              inactive_edges: { $set: response.data.inactive_edges },
              vars: { $set: response.data.vars },
              impl: { $set: response.data.impl },
            },
          },
        );
        this.setState(newState);
        const newMda = { nodes: response.data.nodes, edges: response.data.edges };
        this.xdsmViewer.update(newMda);
      },
    );
  }

  render() {
    const {
      mda, currentUser, useScaling, errors, isEditing, filter, implEdited, mdaEdited,
      newAnalysisName, analysisMembers, analysisCoOwners,
      selectedConnectionNames, newDisciplineName,
    } = this.state;
    const errs = errors.map(
      // eslint-disable-next-line react/no-array-index-key
      (message, i) => (<Error key={i} msg={message} onClose={() => this.handleErrorClose(i)} />),
    );
    const db = new AnalysisDatabase(mda);
    this.db = db;
    const scaled = useScaling || this.db.isScaled();

    let breadcrumbs;
    if (mda.path.length > 1) {
      breadcrumbs = <AnalysisBreadCrumbs api={this.api} path={mda.path} />;
    }

    const xdsmViewer = (
      <XdsmViewer
        ref={(viewer) => { this.xdsmViewer = viewer; }}
        api={this.api}
        isEditing={isEditing}
        mda={mda}
        filter={filter}
        onFilterChange={this.handleFilterChange}
      />
    );

    const varEditor = (
      <VariablesEditor
        db={db}
        filter={filter}
        useScaling={useScaling}
        onFilterChange={this.handleFilterChange}
        onConnectionChange={this.handleConnectionChange}
        isEditing={isEditing}
        limited={db.isAnalysisUsed()}
      />
    );

    if (isEditing) {
      let openmdaoImpl = implEdited;
      if (!implEdited) {
        openmdaoImpl = mda.impl.openmdao;
        openmdaoImpl.use_scaling = scaled;
      }
      let openmdaoImplMsg;
      if (implEdited) {
        openmdaoImplMsg = (
          <div className="alert alert-warning" role="alert">
            Changes are not saved.
          </div>
        );
      }
      let mdaMsg;
      if (mdaEdited) {
        mdaMsg = (
          <div className="alert alert-warning" role="alert">
            Changes are not saved.
          </div>
        );
      }
      let warningIfUsed;
      if (!db.mda.locked && db.isAnalysisUsed()) {
        warningIfUsed = (
          <div className="alert alert-info alert-dismissible fade show" role="alert">
            As this analysis is already operated or packaged,
            {' '}
            <strong>your edition access is limited</strong>
            .
            <br />
            {' '}
            If you need full edition access either restart with a copy of the analysis
            or discard existing operations and attached package.
            <button type="button" className="btn-close" data-bs-dismiss="alert" aria-label="Close" />
          </div>
        );
      }

      let mdaProjectLink;
      if (db.mda.project.id > 0) {
        mdaProjectLink = (
          <span>
            <a href={this.api.url(`/design_projects/${db.mda.project.id}`)}>
              {db.mda.project.name}
            </a>
            {' '}
            /
            {' '}
          </span>
        );
      }

      const analysisPermissionsEditable = (mda.owner.id === currentUser.id);

      let restricted;
      if (!db.mda.public) {
        restricted = (<i className="fas fa-user-secret" title="Analysis with restricted access" />);
      }
      let lock;
      let locked = ('');
      if (db.mda.locked) {
        lock = (<i className="fas fa-lock" title="Analysis is locked readonly" />);
        locked = lock;
      } else {
        lock = (<i className="fas fa-unlock" title="Analysis is editable/deletable" />);
      }
      const tab_disabled = db.mda.locked ? 'disabled' : '';
      const tab_lock_active = db.mda.locked ? 'active' : '';
      const tab_vars_active = !db.mda.locked ? 'active' : '';
      const tab_lock_show = db.mda.locked ? 'show' : '';
      const tab_vars_show = !db.mda.locked ? 'show' : '';
      let co_owned;
      if (analysisCoOwners.length > 0) {
        co_owned = (<i className="fas fa-users-cog" title="Analysis has co-owners" />);
      }

      return (
        <div>
          <form className="button_to" method="get" action={this.api.url(`/analyses/${mda.id}`)}>
            <button className="btn float-end" type="submit">
              <i className="fa fa-times-circle" />
              {' '}
              Close
            </button>
          </form>
          <h1>
            Edit
            {' '}
            {mdaProjectLink}
            <a href={this.api.url(`/analyses/${mda.id}`)}>{mda.name}</a>
            {' '}
            <small>
              (#
              {mda.id}
              )
              {' '}
              {locked}
              {' '}
              {restricted}
              {' '}
              {co_owned}
            </small>
          </h1>
          {warningIfUsed}
          {breadcrumbs}
          <div className="mda-section">
            {xdsmViewer}
          </div>
          <ul className="nav nav-tabs" id="myTab" role="tablist">
            <li className="nav-item">
              <a
                className={`nav-link ${tab_lock_active}`}
                id="lock-tab"
                data-bs-toggle="tab"
                href="#lock"
                role="tab"
                aria-controls="lock"
                aria-selected="false"
              >
                { lock }
              </a>
            </li>
            <li className="nav-item">
              <a
                className={`nav-link ${tab_disabled}`}
                id="analysis-tab"
                data-bs-toggle="tab"
                href="#analysis"
                role="tab"
                aria-controls="analysis"
                aria-selected="false"
              >
                Analysis
              </a>
            </li>
            <li className="nav-item">
              <a
                className={`nav-link ${tab_disabled}`}
                id="disciplines-tab"
                data-bs-toggle="tab"
                href="#disciplines"
                role="tab"
                aria-controls="disciplines"
                aria-selected="false"
              >
                Disciplines
              </a>
            </li>
            <li className="nav-item">
              <a
                className={`nav-link ${tab_disabled}`}
                id="connections-tab"
                data-bs-toggle="tab"
                href="#connections"
                role="tab"
                aria-controls="connections"
                aria-selected="false"
              >
                Connections
              </a>
            </li>
            <li className="nav-item">
              <a
                className={`nav-link ${tab_vars_active} ${tab_disabled}`}
                id="variables-tab"
                data-bs-toggle="tab"
                href="#variables"
                role="tab"
                aria-controls="variables"
                aria-selected="true"
              >
                Variables
              </a>
            </li>
            <li className="nav-item">
              <a
                className={`nav-link ${tab_disabled}`}
                id="openmdao-impl-tab"
                data-bs-toggle="tab"
                href="#openmdao-impl"
                role="tab"
                aria-controls="openmdao-impl"
                aria-selected="false"
              >
                OpenMDAO
              </a>
            </li>
          </ul>
          <div className="tab-content" id="myTabContent">
            {errs}
            <div className={`tab-pane fade ${tab_lock_show} ${tab_lock_active}`} id="lock" role="tabpanel" aria-labelledby="lock-tab">
              <div className="container-fluid">
                <div className="editor-section">
                  <div className="editor-section-label">
                    <i className="fas fa-lock" title="Analysis locked in readonly mode" />
                    {' '}
                    Readonly
                    {' '}
                    <small>
                      (when locked, edition or deletion are disabled)
                    </small>
                  </div>
                  <form className="form" onSubmit={this.handleAnalysisUpdate}>
                    <div className="mb-3 form-check">
                      <label htmlFor="locked" className="form-check-label">
                        <input
                          type="checkbox"
                          className="form-check-input"
                          defaultChecked={db.mda.locked}
                          id="locked"
                          onChange={this.handleAnalysisLockedChange}
                          disabled={!analysisPermissionsEditable}
                        />
                        Locked
                      </label>
                    </div>
                  </form>
                </div>
              </div>
            </div>
            <div className="tab-pane fade" id="analysis" role="tabpanel" aria-labelledby="analysis-tab">
              {mdaMsg}
              <AnalysisEditor
                mdaId={db.mda.id}
                mdaProject={db.mda.project}
                api={this.api}
                note={db.mda.note}
                newAnalysisName={newAnalysisName}
                analysisPublic={mda.public}
                analysisPermissionsEditable={analysisPermissionsEditable}
                analysisMembers={analysisMembers}
                analysisCoOwners={analysisCoOwners}
                onAnalysisUpdate={this.handleAnalysisUpdate}
                onAnalysisNameChange={this.handleAnalysisNameChange}
                onAnalysisNoteChange={this.handleAnalysisNoteChange}
                onAnalysisPublicChange={this.handleAnalysisPublicChange}
                onAnalysisUserSearch={this.handleAnalysisUserSearch}
                onAnalysisUserSelected={this.handleAnalysisUserCreate}
                onAnalysisUserDelete={this.handleAnalysisUserDelete}
                onProjectSearch={this.handleProjectSearch}
                onProjectSelected={this.handleProjectSelected}
              />
            </div>
            <div className="tab-pane fade" id="disciplines" role="tabpanel" aria-labelledby="disciplines-tab">
              <DisciplinesEditor
                db={db}
                api={this.api}
                name={newDisciplineName}
                onDisciplineNameChange={this.handleDisciplineNameChange}
                onSubAnalysisSearch={this.handleSubAnalysisSearch}
                onDisciplineCreate={this.handleDisciplineCreate}
                onDisciplineDelete={this.handleDisciplineDelete}
                onDisciplineUpdate={this.handleDisciplineUpdate}
                onDisciplineImport={this.handleDisciplineImport}
              />
            </div>
            <div className="tab-pane fade" id="connections" role="tabpanel" aria-labelledby="connections-tab">
              <ConnectionsEditor
                db={db}
                filter={filter}
                limited={db.isAnalysisUsed()}
                onFilterChange={this.handleFilterChange}
                selectedConnectionNames={selectedConnectionNames}
                connectionErrors={errors}
                onConnectionNameChange={this.handleConnectionNameChange}
                onConnectionCreate={this.handleConnectionCreate}
                onConnectionDelete={this.handleConnectionDelete}
              />
            </div>
            <div className={`tab-pane fade ${tab_vars_show} ${tab_vars_active}`} id="variables" role="tabpanel" aria-labelledby="variables-tab">
              {varEditor}
              <DistributionModals db={db} onConnectionChange={this.handleConnectionChange} />
            </div>
            <div className="tab-pane fade" id="openmdao-impl" role="tabpanel" aria-labelledby="openmdao-impl-tab">
              {openmdaoImplMsg}
              <OpenmdaoImplEditor
                impl={openmdaoImpl}
                db={db}
                onOpenmdaoImplUpdate={this.handleOpenmdaoImplUpdate}
                onOpenmdaoImplChange={this.handleOpenmdaoImplChange}
                onOpenmdaoImplReset={this.handleOpenmdaoImplReset}
              />
            </div>
          </div>
        </div>
      );
    }

    let noteItem; let noteTab;
    if (mda.note && mda.note.length > 0) {
      noteItem = (
        <li className="nav-item">
          <a
            className="nav-link"
            id="note-tab"
            href="#note"
            role="tab"
            aria-controls="note"
            data-bs-toggle="tab"
            aria-selected="false"
          >
            Notes
          </a>
        </li>
      );
      noteTab = (<AnalysisNotePanel note={mda.note} />);
    }

    let metaModelItem; let metaModelTab;
    const { quality } = mda.impl.metamodel;
    if (quality && quality.length > 0) {
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
          >
            MetaModel
          </a>
        </li>
      );
      metaModelTab = (
        <div className="tab-pane fade" id="metamodel" role="tabpanel" aria-labelledby="metamodel-tab">
          <MetaModelQualification quality={mda.impl.metamodel.quality} />
        </div>
      );
    }

    return (
      <div>
        {breadcrumbs}
        <div className="mda-section">
          {xdsmViewer}
        </div>
        <div className="mda-section">
          <ul className="nav nav-tabs" id="myTab" role="tablist">
            <li className="nav-item">
              <a
                className="nav-link active"
                id="variables-tab"
                data-bs-toggle="tab"
                href="#variables"
                role="tab"
                aria-controls="variables"
                aria-selected="true"
              >
                Variables
              </a>
            </li>
            {noteItem}
            {metaModelItem}
            <li className="nav-item">
              <a
                className="nav-link"
                id="exports-tab"
                data-bs-toggle="tab"
                href="#exports"
                role="tab"
                aria-controls="exports"
                aria-selected="false"
              >
                Export...
              </a>
            </li>
            <li className="nav-item">
              <a
                className="nav-link"
                id="diff-tab"
                data-bs-toggle="tab"
                href="#diffs"
                role="tab"
                aria-controls="diffs"
                aria-selected="false"
              >
                Compare...
              </a>
            </li>
            <li className="nav-item">
              <a
                className="nav-link"
                id="history-tab"
                data-bs-toggle="tab"
                href="#history"
                role="tab"
                aria-controls="history"
                aria-selected="false"
              >
                History
              </a>
            </li>
          </ul>
          <div className="tab-content" id="myTabContent">
            <div className="tab-pane fade show active" id="variables" role="tabpanel" aria-labelledby="variables-tab">
              {varEditor}
            </div>
            {noteTab}
            {metaModelTab}
            <div className="tab-pane fade" id="exports" role="tabpanel" aria-labelledby="exports-tab">
              <ExportPanel
                api={this.api}
                db={db}
              />
            </div>
            <div className="tab-pane fade" id="diffs" role="tabpanel" aria-labelledby="diffs-tab">
              <ComparisonPanel api={this.api} mdaId={db.mda.id} />
            </div>
            <div className="tab-pane fade" id="history" role="tabpanel" aria-labelledby="history-tab">
              <HistoryPanel api={this.api} mdaId={db.mda.id} />
            </div>
          </div>
        </div>
      </div>
    );
  }
}

MdaViewer.propTypes = {
  isEditing: PropTypes.bool.isRequired,
  api: PropTypes.object.isRequired,
  members: PropTypes.array,
  coOwners: PropTypes.array,
  currentUser: PropTypes.object,
  mda: PropTypes.shape({
    owner: PropTypes.object.isRequired,
    name: PropTypes.string.isRequired,
    public: PropTypes.bool.isRequired,
    locked: PropTypes.bool.isRequired,
    note: PropTypes.string.isRequired,
    id: PropTypes.number.isRequired,
    path: PropTypes.array.isRequired,
    impl: PropTypes.shape({
      openmdao: PropTypes.object.isRequired,
      metamodel: PropTypes.shape(
        { quality: PropTypes.array.isRequired },
      ),
    }),
  }).isRequired,
};
MdaViewer.defaultProps = {
  currentUser: null,
  members: [],
  coOwners: [],
};

export default MdaViewer;
