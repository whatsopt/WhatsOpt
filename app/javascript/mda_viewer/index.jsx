import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';

import XdsmViewer from 'mda_viewer/components/XdsmViewer';
import ToolBar from 'mda_viewer/components/ToolBar';
import Error from 'mda_viewer/components/Error';
import AnalysisEditor from 'mda_viewer/components/AnalysisEditor';
import AnalysisNotePanel from 'mda_viewer/components/AnalysisNotePanel';
import AnalysisBreadCrumbs from 'mda_viewer/components/AnalysisBreadCrumbs';
import DisciplinesEditor from 'mda_viewer/components/DisciplinesEditor';
import ConnectionsEditor from 'mda_viewer/components/ConnectionsEditor';
import VariablesEditor from 'mda_viewer/components/VariablesEditor';
import OpenmdaoImplEditor from 'mda_viewer/components/OpenmdaoImplEditor';
import MetaModelQualification from 'mda_viewer/components/MetaModelQualification';
import AnalysisDatabase from '../utils/AnalysisDatabase';
import { deepIsEqual } from '../utils/compare';

const VAR_REGEXP = /^[a-zA-Z][_a-zA-Z0-9]*$/;

const reorder = (list, startIndex, endIndex) => {
  const result = Array.from(list);
  const [removed] = result.splice(startIndex, 1);
  result.splice(endIndex, 0, removed);

  return result;
};

class MdaViewer extends React.Component {
  constructor(props) {
    super(props);
    this.api = this.props.api;
    const isEditing = this.props.isEditing;
    const filter = { fr: undefined, to: undefined };
    this.db = new AnalysisDatabase(props.mda);
    this.state = {
      filter: filter,
      isEditing: isEditing,
      mda: props.mda,
      analysisMembers: this.props.members,
      newAnalysisName: this.props.mda.name,
      newDisciplineName: '',
      analysisNote: '',
      newConnectionName: [],
      errors: [],
      implEdited: false,
      useScaling: this.db.isScaled(),
    };
    this.handleFilterChange = this.handleFilterChange.bind(this);
    this.handleAnalysisNameChange = this.handleAnalysisNameChange.bind(this);
    this.handleAnalysisNoteChange = this.handleAnalysisNoteChange.bind(this);
    this.handleAnalysisPublicChange = this.handleAnalysisPublicChange.bind(this);
    this.handleAnalysisMemberSearch = this.handleAnalysisMemberSearch.bind(this);
    this.handleAnalysisMemberCreate = this.handleAnalysisMemberCreate.bind(this);
    this.handleAnalysisMemberDelete = this.handleAnalysisMemberDelete.bind(this);
    this.handleAnalysisUpdate = this.handleAnalysisUpdate.bind(this);
    this.handleDisciplineNameChange = this.handleDisciplineNameChange.bind(this);
    this.handleDisciplineCreate = this.handleDisciplineCreate.bind(this);
    this.handleDisciplineUpdate = this.handleDisciplineUpdate.bind(this);
    this.handleDisciplineDelete = this.handleDisciplineDelete.bind(this);
    this.handleSubAnalysisSearch = this.handleSubAnalysisSearch.bind(this);
    this.handleSubAnalysisCreate = this.handleSubAnalysisCreate.bind(this);
    this.handleConnectionNameChange = this.handleConnectionNameChange.bind(this);
    this.handleConnectionCreate = this.handleConnectionCreate.bind(this);
    this.handleConnectionDelete = this.handleConnectionDelete.bind(this);
    this.handleConnectionDelete = this.handleConnectionDelete.bind(this);
    this.handleConnectionChange = this.handleConnectionChange.bind(this);
    this.handleErrorClose = this.handleErrorClose.bind(this);
    this.handleOpenmdaoImplUpdate = this.handleOpenmdaoImplUpdate.bind(this);
    this.handleOpenmdaoImplChange = this.handleOpenmdaoImplChange.bind(this);
    this.handleOpenmdaoImplReset = this.handleOpenmdaoImplReset.bind(this);
  }

  handleFilterChange(filter) {
    const newState = update(this.state, { filter: { $set: filter } });
    this.setState(newState);
    this.xdsmViewer.setSelection(filter);
  }

  // *** Connections *********************************************************

  _validateConnectionNames(names) {
    const errors = [];
    names.forEach((name) => {
      if (!name.match(VAR_REGEXP)) {
        if (name !== '') {
          errors.push(`Variable name '${name}' is invalid`);
          console.log("Error: " + errors);
        }
      }
    }, this);
    return errors;
  }

  handleConnectionNameChange(selected) {
    const names = selected.map((e) => e.name);
    const errors = this._validateConnectionNames(names);
    const newState = update(this.state, {
      newConnectionName: { $set: names },
      errors: { $set: errors },
    });
    this.setState(newState);
  }

  handleConnectionCreate(event) {
    event.preventDefault();

    if (this.state.errors.length > 0) {
      return;
    }
    const names = this.state.newConnectionName;
    const data = { from: this.state.filter.fr, to: this.state.filter.to, names: names };
    this.api.createConnection(this.props.mda.id, data,
      () => {
        const newState = update(this.state, { newConnectionName: { $set: [] } });
        this.setState(newState);
        this.renderXdsm();
      },
      (error) => {
        const message = error.response.data.message || "Error: Creation failed";
        const newState = update(this.state, { errors: { $set: [message] } });
        this.setState(newState);
      });
  };

  handleConnectionChange(connId, connAttrs) {
    // console.log('Change variable connection '+connId+ ' with '+JSON.stringify(connAttrs));
    if (connAttrs.init || connAttrs.init === "") {
      connAttrs['parameter_attributes'] = { init: connAttrs.init };
    }
    if (connAttrs.lower || connAttrs.lower === "") {
      connAttrs['parameter_attributes'] = { lower: connAttrs.lower };
    }
    if (connAttrs.upper || connAttrs.upper === "") {
      connAttrs['parameter_attributes'] = { upper: connAttrs.upper };
    }
    delete connAttrs['init'];
    delete connAttrs['lower'];
    delete connAttrs['upper'];
    if (connAttrs.ref || connAttrs.ref === "") {
      connAttrs['scaling_attributes'] = { ref: connAttrs.ref };
    }
    if (connAttrs.ref0 || connAttrs.ref0 === "") {
      connAttrs['scaling_attributes'] = { ref0: connAttrs.ref0 };
    }
    if (connAttrs.res_ref || connAttrs.res_ref === "") {
      connAttrs['scaling_attributes'] = { res_ref: connAttrs.res_ref };
    }
    delete connAttrs['ref'];
    delete connAttrs['ref0'];
    delete connAttrs['res_ref'];

    if (Object.keys(connAttrs).length !== 0) {
      this.api.updateConnection(
        connId, connAttrs, () => { this.renderXdsm(); },
        (error) => {
          const message = error.response.data.message || "Error: Update failed";
          const newState = update(this.state, { errors: { $set: [message] } });
          this.setState(newState);
        });
    }
  }

  handleConnectionDelete(connId) {
    this.api.deleteConnection(connId, () => { this.renderXdsm(); });
  }

  // *** Disciplines ************************************************************

  handleDisciplineCreate(event) {
    event.preventDefault();
    this.api.createDiscipline(this.props.mda.id, { name: this.state.newDisciplineName, type: 'analysis' },
      () => {
        const newState = update(this.state, { newDisciplineName: { $set: '' } });
        this.setState(newState);
        this.renderXdsm();
      });
  }

  handleDisciplineNameChange(event) {
    event.preventDefault();
    const newState = update(this.state, { newDisciplineName: { $set: event.target.value } });
    this.setState(newState);
  }

  handleDisciplineUpdate(node, discAttrs) {
    if ('position' in discAttrs) {
      const items = reorder(this.state.mda.nodes, this.state.mda.nodes.indexOf(node), discAttrs['position']);
      const newState = update(this.state, { mda: { nodes: { $set: items } } });
      this.setState(newState);
    }
    this.api.updateDiscipline(node.id, discAttrs, () => { this.renderXdsm(); });
  }

  handleDisciplineDelete(node) {
    this.api.deleteDiscipline(node.id, () => {
      if (this.state.filter.fr === node.id || this.state.filter.to === node.id) {
        this.handleFilterChange({ fr: undefined, to: undefined });
      }
      this.renderXdsm();
    });
  }

  handleSubAnalysisSearch(callback) {
    this.api.getSubAnalysisCandidates(
      (response) => {
        const options = response.data
          .filter((analysis) => (analysis.id !== this.props.mda.id))
          .map((analysis) => { return { id: analysis.id, label: `#${analysis.id} ${analysis.name}` }; });
        callback(options);
      }
    );
  }
  handleSubAnalysisCreate(node, selected) {
    if (selected.length) {
      this.api.createSubAnalysisDiscipline(node.id, selected[0].id,
        (response) => {
          console.log(response.data);
          this.renderXdsm();
        }
      );
    }
  }

  // *** Analysis ************************************************************
  handleAnalysisNameChange(event) {
    event.preventDefault();
    const newState = update(this.state, {
      newAnalysisName: { $set: event.target.value },
      errors: { $set: [] },
    });
    this.setState(newState);
    return false;
  }

  handleAnalysisNoteChange(event) {
    event.preventDefault();
    const newState = update(this.state, {
      mda: { note: { $set: event.target.innerHTML } },
    });
    this.setState(newState);
    return false;
  }

  handleAnalysisPublicChange() {
    this.api.updateAnalysis(this.props.mda.id, { public: !this.state.mda.public },
      () => {
        const newState = update(this.state, { mda: { public: { $set: !this.state.mda.public } } });
        this.setState(newState);
      },
      (error) => { console.log(error); }
    );
    return false;
  }

  handleAnalysisMemberSearch(query, callback) {
    // TODO: query could be used to filter user on server side
    this.api.getMemberCandidates(this.props.mda.id,
      (response) => {
        callback(response.data);
      }
    );
  }

  handleAnalysisMemberCreate(selected) {
    if (selected.length) {
      this.api.addMember(selected[0].id, this.props.mda.id,
        () => {
          const newState = update(this.state, { analysisMembers: { $push: selected } });
          this.setState(newState);
        }
      );
    }
  }
  handleAnalysisMemberDelete(user) {
    this.api.removeMember(user.id, this.props.mda.id, () => {
      const idx = this.state.analysisMembers.indexOf(user);
      const newState = update(this.state, { analysisMembers: { $splice: [[idx, 1]] } });
      this.setState(newState);
    });
  }

  handleAnalysisUpdate(event) {
    event.preventDefault();
    this.api.updateAnalysis(this.props.mda.id, { name: this.state.newAnalysisName, note: this.state.mda.note },
      () => {
        this.api.getAnalysis(this.props.mda.id, false,
          () => {
            const newState = update(this.state, {
              mda: {
                name: { $set: this.state.newAnalysisName },
                note: { $set: this.state.mda.note },
              }
            });
            this.setState(newState);
          });
      },
      (error) => {
        const message = error.response.data.message || "Error: Update failed";
        const newState = update(this.state, { errors: { $set: [message] } });
        this.setState(newState);
      });
  }

  renderXdsm() {
    this.api.getAnalysis(this.props.mda.id, true,
      (response) => {
        const newState = update(this.state,
          {
            mda: {
              nodes: { $set: response.data.nodes },
              edges: { $set: response.data.edges },
              inactive_edges: { $set: response.data.inactive_edges },
              vars: { $set: response.data.vars },
            },
          });
        this.setState(newState);
        const mda = { nodes: response.data.nodes, edges: response.data.edges };
        this.xdsmViewer.update(mda);
      });
  }

  handleErrorClose(index) {
    const newState = update(this.state, { errors: { $splice: [[index, 1]] } });
    this.setState(newState);
  }

  // *** OpenmdaoImpl ************************************************************
  handleOpenmdaoImplUpdate(openmdaoImpl) {
    delete openmdaoImpl.components['use_scaling'];
    this.api.updateOpenmdaoImpl(this.props.mda.id, openmdaoImpl,
      () => {
        const newState = update(this.state, {
          implEdited: { $set: false },
          mda: { impl: { openmdao: { $set: openmdaoImpl } } }
        });
        this.setState(newState);
      }
    );
  }
  handleOpenmdaoImplChange(openmdaoImpl) {
    let newState;
    if (deepIsEqual(this.state.mda.impl.openmdao, openmdaoImpl)) {
      newState = update(this.state, { implEdited: { $set: false } });
    } else {
      if (this.state.mda.impl.openmdao.components.use_scaling === openmdaoImpl.components.use_scaling) {
        newState = update(this.state, { implEdited: { $set: openmdaoImpl } });
      } else {
        newState = update(this.state, { useScaling: { $set: openmdaoImpl.components.use_scaling } });
      }
    }
    this.setState(newState);
  }
  handleOpenmdaoImplReset() {
    const newState = update(this.state, { implEdited: { $set: false } });
    this.setState(newState);
  }

  render() {
    const errors = this.state.errors.map((message, i) => {
      return (<Error key={i} msg={message} onClose={() => this.handleErrorClose(i)} />);
    });
    const db = this.db = new AnalysisDatabase(this.state.mda);
    const useScaling = this.state.useScaling || this.db.isScaled();

    let breadcrumbs;
    if (this.props.mda.path.length > 1) {
      breadcrumbs = <AnalysisBreadCrumbs api={this.api} path={this.props.mda.path} />;
    }

    const xdsmViewer =
      (<XdsmViewer ref={(xdsmViewer) => this.xdsmViewer = xdsmViewer}
        api={this.api}
        isEditing={this.state.isEditing}
        mda={this.state.mda}
        filter={this.state.filter}
        onFilterChange={this.handleFilterChange} />);

    const varEditor =
      (<VariablesEditor db={db} filter={this.state.filter} useScaling={useScaling}
        onFilterChange={this.handleFilterChange}
        onConnectionChange={this.handleConnectionChange}
        isEditing={this.state.isEditing} />);

    if (this.state.isEditing) {
      let openmdaoImpl = this.state.implEdited;
      if (!this.state.implEdited) {
        openmdaoImpl = this.state.mda.impl.openmdao;
        openmdaoImpl.components.use_scaling = this.state.useScaling;
      }
      let openmdaoImplMsg;
      if (this.state.implEdited) {
        openmdaoImplMsg = (<div className="alert alert-warning" role="alert">
          Changes are not saved.
        </div>);
      }

      return (
        <div>
          <form className="button_to" method="get" action={this.api.url(`/analyses/${this.props.mda.id}`)}>
            <button className="btn float-right" type="submit">
              <i className="fa fa-times-circle" /> Close
            </button>
          </form>
          <h1>Edit {this.state.mda.name}</h1>
          {breadcrumbs}
          <div className="mda-section">
            {xdsmViewer}
          </div>
          <ul className="nav nav-tabs" id="myTab" role="tablist">
            <li className="nav-item">
              <a className="nav-link " id="analysis-tab" data-toggle="tab" href="#analysis"
                role="tab" aria-controls="analysis" aria-selected="false">Analysis</a>
            </li>
            <li className="nav-item">
              <a className="nav-link" id="disciplines-tab" data-toggle="tab" href="#disciplines"
                role="tab" aria-controls="disciplines" aria-selected="false">Disciplines</a>
            </li>
            <li className="nav-item">
              <a className="nav-link" id="connections-tab" data-toggle="tab" href="#connections"
                role="tab" aria-controls="connections" aria-selected="false">Connections</a>
            </li>
            <li className="nav-item">
              <a className="nav-link active" id="variables-tab" data-toggle="tab" href="#variables"
                role="tab" aria-controls="variables" aria-selected="true">Variables</a>
            </li>
            <li className="nav-item">
              <a className="nav-link" id="openmdao-impl-tab" data-toggle="tab" href="#openmdao-impl"
                role="tab" aria-controls="openmdao-impl" aria-selected="false">OpenMDAO</a>
            </li>
          </ul>
          <div className="tab-content" id="myTabContent">
            {errors}
            <div className="tab-pane fade" id="analysis" role="tabpanel" aria-labelledby="analysis-tab">
              <AnalysisEditor mdaId={db.mda.id} api={this.api} note={db.mda.note}
                newAnalysisName={this.state.newAnalysisName}
                analysisPublic={this.state.mda.public}
                analysisMembers={this.state.analysisMembers}
                onAnalysisUpdate={this.handleAnalysisUpdate}
                onAnalysisNameChange={this.handleAnalysisNameChange}
                onAnalysisNoteChange={this.handleAnalysisNoteChange}
                onAnalysisPublicChange={this.handleAnalysisPublicChange}
                onAnalysisMemberSearch={this.handleAnalysisMemberSearch}
                onAnalysisMemberSelected={this.handleAnalysisMemberCreate}
                onAnalysisMemberDelete={this.handleAnalysisMemberDelete}
              />
            </div>
            <div className="tab-pane fade" id="disciplines" role="tabpanel" aria-labelledby="disciplines-tab">
              <DisciplinesEditor name={this.state.newDisciplineName}
                nodes={db.nodes}
                onDisciplineNameChange={this.handleDisciplineNameChange}
                onSubAnalysisSearch={this.handleSubAnalysisSearch}
                onSubAnalysisSelected={this.handleSubAnalysisCreate}
                onDisciplineCreate={this.handleDisciplineCreate}
                onDisciplineDelete={this.handleDisciplineDelete}
                onDisciplineUpdate={this.handleDisciplineUpdate}
              />
            </div>
            <div className="tab-pane fade" id="connections" role="tabpanel" aria-labelledby="connections-tab">
              <ConnectionsEditor db={db}
                filter={this.state.filter} onFilterChange={this.handleFilterChange}
                newConnectionName={this.state.newConnectionName}
                connectionErrors={this.state.errors}
                onConnectionNameChange={this.handleConnectionNameChange}
                onConnectionCreate={this.handleConnectionCreate}
                onConnectionDelete={this.handleConnectionDelete}
              />
            </div>
            <div className="tab-pane fade show active" id="variables" role="tabpanel" aria-labelledby="variables-tab">
              {varEditor}
            </div>
            <div className="tab-pane fade" id="openmdao-impl" role="tabpanel" aria-labelledby="openmdao-impl-tab">
              {openmdaoImplMsg}
              <OpenmdaoImplEditor impl={openmdaoImpl} db={db}
                onOpenmdaoImplUpdate={this.handleOpenmdaoImplUpdate}
                onOpenmdaoImplChange={this.handleOpenmdaoImplChange}
                onOpenmdaoImplReset={this.handleOpenmdaoImplReset}
              />
            </div>
          </div>
        </div>);
    };

    let noteItem; let notePanel;
    const note = this.props.mda.note;
    if (note && note.length > 0) {
      noteItem = (
        <li className="nav-item">
          <a className="nav-link" id="note-tab" href="#note"
            role="tab" aria-controls="note" data-toggle="tab" aria-selected="false">Note</a>
        </li>);
      notePanel = (<AnalysisNotePanel note={this.props.mda.note} />);
    }

    let metaModelItem; let metaModelPanel;
    const quality = this.props.mda.impl.metamodel.quality;
    if (quality && quality.length > 0) {
      metaModelItem = (
        <li className="nav-item">
          <a className="nav-link" id="metamodel-tab" href="#metamodel"
            role="tab" aria-controls="metamodel" data-toggle="tab" aria-selected="false">MetaModel</a>
        </li>);
      metaModelPanel = (
        <div className="tab-pane fade" id="metamodel" role="tabpanel" aria-labelledby="metamodel-tab">
          <MetaModelQualification quality={this.props.mda.impl.metamodel.quality} />
        </div>
      );
    }

    return (
      <div>
        <div className="mda-section">
          <ToolBar mdaId={this.props.mda.id} api={this.api} db={db} />
        </div>
        {breadcrumbs}
        <div className="mda-section">
          {xdsmViewer}
        </div>
        <div className="mda-section">
          <ul className="nav nav-tabs" id="myTab" role="tablist">
            <li className="nav-item">
              <a className="nav-link active" id="variables-tab" data-toggle="tab" href="#variables"
                role="tab" aria-controls="variables" aria-selected="true">Variables</a>
            </li>
            {noteItem}
            {metaModelItem}
          </ul>
          <div className="tab-content" id="myTabContent">
            <div className="tab-pane fade show active" id="variables" role="tabpanel" aria-labelledby="variables-tab">
              {varEditor}
            </div>
            {notePanel}
            {metaModelPanel}
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
  mda: PropTypes.shape({
    name: PropTypes.string,
    public: PropTypes.bool,
    id: PropTypes.number,
    path: PropTypes.array,
    impl: PropTypes.shape({
      openmdao: PropTypes.object.isRequired,
      metamodel: PropTypes.shape(
        { quality: PropTypes.array.isRequired, }
      )
    }),
  }),
};

export default MdaViewer;
