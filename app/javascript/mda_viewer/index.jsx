import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';

import XdsmViewer from 'mda_viewer/components/XdsmViewer';
import ToolBar from 'mda_viewer/components/ToolBar';
import Error from 'mda_viewer/components/Error';
import AnalysisEditor from 'mda_viewer/components/AnalysisEditor';
import DisciplinesEditor from 'mda_viewer/components/DisciplinesEditor';
import ConnectionsEditor from 'mda_viewer/components/ConnectionsEditor';
import VariablesEditor from 'mda_viewer/components/VariablesEditor';
import AnalysisDatabase from '../utils/AnalysisDatabase';

const VAR_REGEXP = /^[a-zA-Z][_a-zA-Z0-9]*$/;

class MdaViewer extends React.Component {
  constructor(props) {
    super(props);
    this.api = this.props.api;
    const isEditing = props.isEditing;
    const filter = {fr: undefined, to: undefined};
    this.state = {
      filter: filter,
      isEditing: isEditing,
      mda: props.mda,
      analysisMembers: this.props.members,
      newAnalysisName: this.props.mda.name,
      newDisciplineName: '',
      newConnectionName: '',
      errors: [],
    };
    this.handleFilterChange = this.handleFilterChange.bind(this);
    this.handleAnalysisNameChange = this.handleAnalysisNameChange.bind(this);
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
  }

  handleFilterChange(filter) {
    const newState = update(this.state, {filter: {$set: filter}});
    this.setState(newState);
    this.xdsmViewer.setSelection(filter);
  }

  // *** Connections *********************************************************

  _validateConnectionNames(namesStr) {
    let names = namesStr.split(',');
    names = names.map((name) => {return name.trim();});
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

  handleConnectionNameChange(event) {
    event.preventDefault();
    const errors = this._validateConnectionNames(event.target.value);
    const newState = update(this.state, {newConnectionName: {$set: event.target.value},
      errors: {$set: errors}});
    this.setState(newState);
  }

  handleConnectionCreate(event) {
    event.preventDefault();

    if (this.state.errors.length > 0) {
      return;
    }
    let names = this.state.newConnectionName.split(',');
    names = names.map((name) => {return name.trim();});
    names = names.filter((name) => name !== '');

    const data = {from: this.state.filter.fr, to: this.state.filter.to, names: names};
    this.api.createConnection(this.props.mda.id, data,
        (response) => {
          const newState = update(this.state, {newConnectionName: {$set: ''}});
          this.setState(newState);
          this.renderXdsm();
        },
        (error) => {
          const message = error.response.data.message || "Error: Creation failed";
          const newState = update(this.state, {errors: {$set: [message]}});
          this.setState(newState);
        });
  };

  handleConnectionChange(connId, connAttrs) {
    // console.log('Change variable connection '+connId+ ' with '+JSON.stringify(connAttrs));
    if (connAttrs.init || connAttrs.init === "") {
      connAttrs['parameter_attributes'] = {init: connAttrs.init};
    }
    if (connAttrs.lower || connAttrs.lower === "") {
      connAttrs['parameter_attributes'] = {lower: connAttrs.lower};
    }
    if (connAttrs.upper || connAttrs.upper === "") {
      connAttrs['parameter_attributes'] = {upper: connAttrs.upper};
    }
    delete connAttrs['init'];
    delete connAttrs['lower'];
    delete connAttrs['upper'];
    if (Object.keys(connAttrs).length !== 0) {
      this.api.updateConnection(
          connId, connAttrs, (response) => {this.renderXdsm();},
          (error) => {
            const message = error.response.data.message || "Error: Update failed";
            const newState = update(this.state, {errors: {$set: [message]}});
            this.setState(newState);
          });
    }
  }

  handleConnectionDelete(connId) {
    this.api.deleteConnection(connId, (response) => {this.renderXdsm();});
  }

  // *** Disciplines ************************************************************

  handleDisciplineCreate(event) {
    event.preventDefault();
    this.api.createDiscipline(this.props.mda.id, {name: this.state.newDisciplineName, type: 'analysis'},
        (response) => {
          const newState = update(this.state, {newDisciplineName: {$set: ''}});
          this.setState(newState);
          this.renderXdsm();
        });
  }

  handleDisciplineNameChange(event) {
    event.preventDefault();
    const newState = update(this.state, {newDisciplineName: {$set: event.target.value}});
    this.setState(newState);
  }

  handleDisciplineUpdate(node, discAttrs) {
    this.api.updateDiscipline(node.id, discAttrs, (response) => {this.renderXdsm();});
  }

  handleDisciplineDelete(node) {
    this.api.deleteDiscipline(node.id, (response) => {
      if (this.state.filter.fr===node.id || this.state.filter.to===node.id) {
        this.handleFilterChange({fr: undefined, to: undefined});
      }
      this.renderXdsm();
    });
  }

  handleSubAnalysisSearch(query, callback) {
    this.api.getSubAnalysisCandidates(
        (response) => {
          let options = response.data
            .filter((analysis) => (analysis.id !== this.props.mda.id))
            .map((analysis) => {return {id: analysis.id, label: `#${analysis.id} ${analysis.name}`}})
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
    const newState = update(this.state, {newAnalysisName: {$set: event.target.value},
      errors: {$set: []}});
    this.setState(newState);
    return false;
  }

  handleAnalysisPublicChange(event) {
    this.api.updateAnalysis(this.props.mda.id, {public: !this.state.mda.public},
        (response) => {
          const newState = update(this.state, {mda: {public: {$set: !this.state.mda.public}}});
          this.setState(newState);
        },
        (error) => {console.log(error);}
    );
    return false;
  }

  handleAnalysisMemberSearch(query, callback) {
    this.api.getMemberCandidates(this.props.mda.id,
        (response) => {
          callback(response.data);
        }
    );
  }
  
  handleAnalysisMemberCreate(selected) {
    if (selected.length) {
      this.api.addMember(selected[0].id, this.props.mda.id,
          (response) => {
            const newState = update(this.state, {analysisMembers: {$push: selected}});
            this.setState(newState);
          }
      );
    }
  }
  handleAnalysisMemberDelete(user) {
    this.api.removeMember(user.id, this.props.mda.id, (response) => {
      const idx = this.state.analysisMembers.indexOf(user);
      const newState = update(this.state, {analysisMembers: {$splice: [[idx, 1]]}});
      this.setState(newState);
    });
  }

  handleAnalysisUpdate(event) {
    event.preventDefault();
    this.api.updateAnalysis(this.props.mda.id, {name: this.state.newAnalysisName},
        (response) => {
          this.api.getAnalysis(this.props.mda.id, false,
              (response) => {
                const newState = update(this.state, {mda: {name: {$set: this.state.newAnalysisName}}});
                this.setState(newState);
              });
        },
        (error) => {
          const message = error.response.data.message || "Error: Update failed";
          const newState = update(this.state, {errors: {$set: [message]}});
          this.setState(newState);
        });
  }

  renderXdsm() {
    console.log("renderXdsm");
    this.api.getAnalysis(this.props.mda.id, true,
        (response) => {
          const newState = update(this.state,
              {mda: {nodes: {$set: response.data.nodes},
                edges: {$set: response.data.edges},
                inactive_edges: {$set: response.data.inactive_edges},
                vars: {$set: response.data.vars}}});
          this.setState(newState);
          const mda = {nodes: response.data.nodes, edges: response.data.edges};
          this.xdsmViewer.update(mda);
        });
  }

  handleErrorClose(index) {
    const newState = update(this.state, {errors: {$splice: [[index, 1]]}});
    this.setState(newState);
  }

  render() {
    const errors = this.state.errors.map((message, i) => {
      return ( <Error key={i} msg={message} onClose={() => this.handleErrorClose(i)}/> );
    });
    const db = new AnalysisDatabase(this.state.mda);

    if (this.state.isEditing) {
      return (
        <div>
          <form className="button_to" method="get" action={this.api.url(`/analyses/${this.props.mda.id}`)}>
            <button className="btn float-right" type="submit">
              <i className="fa fa-times-circle" /> Close
            </button>
          </form>
          <h1>Edit {this.state.mda.name}</h1> 
          <div className="mda-section">
            <XdsmViewer ref={(xdsmViewer) => this.xdsmViewer = xdsmViewer} 
              isEditing={this.state.isEditing}
              mda={this.state.mda}
              filter={this.state.filter} 
              onFilterChange={this.handleFilterChange}/>
          </div>
          <ul className="nav nav-tabs" id="myTab" role="tablist">
            <li className="nav-item">
              <a className="nav-link " id="analysis-tab" data-toggle="tab" href="#analysis"
                role="tab" aria-controls="analysis" aria-selected="false">Analysis</a>
            </li>
            <li className="nav-item active">
              <a className="nav-link" id="disciplines-tab" data-toggle="tab" href="#disciplines"
                role="tab" aria-controls="disciplines" aria-selected="true">Disciplines</a>
            </li>
            <li className="nav-item">
              <a className="nav-link" id="connections-tab" data-toggle="tab" href="#connections"
                role="tab" aria-controls="connections" aria-selected="false">Connections</a>
            </li>
            <li className="nav-item">
              <a className="nav-link" id="variables-tab" data-toggle="tab" href="#variables"
                role="tab" aria-controls="variables" aria-selected="false">Variables</a>
            </li>
          </ul>
          <div className="tab-content" id="myTabContent">
            {errors}
            <div className="tab-pane fade" id="analysis" role="tabpanel" aria-labelledby="analysis-tab">
              <AnalysisEditor newAnalysisName={this.state.newAnalysisName}
                analysisPublic={this.state.mda.public}
                analysisMembers={this.state.analysisMembers}
                onAnalysisUpdate={this.handleAnalysisUpdate}
                onAnalysisNameChange={this.handleAnalysisNameChange}
                onAnalysisPublicChange={this.handleAnalysisPublicChange}
                onAnalysisMemberSearch={this.handleAnalysisMemberSearch}
                onAnalysisMemberSelected={this.handleAnalysisMemberCreate}
                onAnalysisMemberDelete={this.handleAnalysisMemberDelete}
              />
            </div>
            <div className="tab-pane fade show active" id="disciplines" role="tabpanel" aria-labelledby="disciplines-tab">
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
            <div className="tab-pane fade" id="variables" role="tabpanel" aria-labelledby="variables-tab">
              <VariablesEditor db={db} filter={this.state.filter}
                onFilterChange={this.handleFilterChange}
                onConnectionChange={this.handleConnectionChange}
                isEditing={this.state.isEditing} />
            </div>
          </div>
        </div>);
    };
    return (
      <div>
        <div className="mda-section">
          <ToolBar mdaId={this.props.mda.id} api={this.api} db={db}/>
        </div>
        <div className="mda-section">
          <XdsmViewer ref={(xdsmViewer) => this.xdsmViewer = xdsmViewer} 
            isEditing={this.state.isEditing}
            mda={this.state.mda}
            filter={this.state.filter} 
            onFilterChange={this.handleFilterChange}/>
        </div>
        <div className="mda-section">
          <VariablesEditor db={db}
            filter={this.state.filter} onFilterChange={this.handleFilterChange}
            onConnectionChange={this.handleConnectionChange}
            isEditing={this.state.isEditing} />
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
  }),
};

export default MdaViewer;
