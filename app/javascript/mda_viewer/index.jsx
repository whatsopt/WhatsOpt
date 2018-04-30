import React from 'react';
import XdsmViewer from 'mda_viewer/components/XdsmViewer'
import ToolBar from 'mda_viewer/components/ToolBar'
import Error from 'mda_viewer/components/Error'
import AnalysisEditor from 'mda_viewer/components/AnalysisEditor'
import DisciplinesEditor from 'mda_viewer/components/DisciplinesEditor'
import ConnectionsEditor from 'mda_viewer/components/ConnectionsEditor'
import VariablesEditor from 'mda_viewer/components/VariablesEditor'
import update from 'immutability-helper'
let Graph = require('XDSMjs/src/graph');
import {api, url} from '../utils/WhatsOptApi';

let VAR_REGEXP = /^[a-zA-Z][a-zA-Z0-9]*$/;

class MdaViewer extends React.Component {
    
  constructor(props) {
    super(props);
    let isEditing = props.isEditing;
    let filter = { fr: undefined, to: undefined };
    this.state = {
      filter: filter,
      isEditing: isEditing,
      mda: props.mda,
      newAnalysisName: props.mda.name,
      newDisciplineName: '',
      newConnectionName: '',
      errors: []
    }
    this.handleFilterChange = this.handleFilterChange.bind(this);
    this.handleAnalysisNameChange = this.handleAnalysisNameChange.bind(this);
    this.handleAnalysisUpdate = this.handleAnalysisUpdate.bind(this);
    this.handleDisciplineNameChange = this.handleDisciplineNameChange.bind(this);
    this.handleDisciplineCreate = this.handleDisciplineCreate.bind(this);
    this.handleDisciplineUpdate = this.handleDisciplineUpdate.bind(this);
    this.handleDisciplineDelete = this.handleDisciplineDelete.bind(this);
    this.handleConnectionNameChange = this.handleConnectionNameChange.bind(this); 
    this.handleConnectionCreate = this.handleConnectionCreate.bind(this); 
    this.handleConnectionDelete = this.handleConnectionDelete.bind(this); 
    this.handleConnectionDelete = this.handleConnectionDelete.bind(this); 
    this.handleConnectionChange = this.handleConnectionChange.bind(this); 
  }
  
  handleFilterChange(filter) { 
    let newState = update(this.state, {filter: {$set: filter}});
    this.setState(newState);
    this.xdsmViewer.setSelection(filter);
  }
  
  // *** Connections *********************************************************
  
  _validateConnectionNames(namesStr) {
    let names = namesStr.split(',');
    names = names.map((name) => { return name.trim(); });
    let errors = [];
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
    let errors = this._validateConnectionNames(event.target.value);
    let newState = update(this.state, { newConnectionName: {$set: event.target.value}, 
                                        errors: {$set: errors} });
    this.setState(newState);
  }

  handleConnectionCreate(event) {
    event.preventDefault();

    if (this.state.errors.length > 0) {
      return;
    }
    let names = this.state.newConnectionName.split(',');
    names = names.map((name) => { return name.trim(); });
    names = names.filter((name) => name !== '');
    
    let data = {from: this.state.filter.fr, to: this.state.filter.to, names: names};
    console.log(data);
    api.createConnection(this.props.mda.id, data,
        (response) => {
            let newState = update(this.state, {newConnectionName: {$set: ''}});
            this.setState(newState);
            this.renderXdsm();
          },
        (error) => { 
          let message = error.response.data.message;
          let newState = update(this.state, {errors: {$set: [message]}});
          this.setState(newState);
        });
  };
  
  handleConnectionChange(connId, connAttrs) {
    //console.log('Change variable connection '+connId+ ' with '+JSON.stringify(connAttrs));
    if (connAttrs.init === "") {
      connAttrs['parameter_attributes'] = { _destroy: '1' };
    } else if (connAttrs.init) {
      connAttrs['parameter_attributes'] = { init: connAttrs.init };
    }
    if (connAttrs.lower) {
      connAttrs['parameter_attributes'] = { lower: connAttrs.lower};
    }
    if (connAttrs.upper) {
      connAttrs['parameter_attributes'] = { upper: connAttrs.upper };
    }
    delete connAttrs['init'];
    delete connAttrs['lower'];
    delete connAttrs['upper'];
    api.updateConnection(
      connId, connAttrs, (response) => { this.renderXdsm(); },
      (error) => { 
        let message = error.response.data.message;
        let newState = update(this.state, {errors: {$set: [message]}});
        this.setState(newState);
      }); 
  }
  
  
  handleConnectionDelete(connId) {
    api.deleteConnection(connId, (response) => { this.renderXdsm(); });
  }
  
  // *** Disciplines ************************************************************

  handleDisciplineCreate(event) { 
    event.preventDefault();
    api.createDiscipline(this.props.mda.id, {name: this.state.newDisciplineName, type: 'analysis'}, 
      (response) => {
        let newState = update(this.state, {newDisciplineName: {$set: ''}});
        this.setState(newState);
        this.renderXdsm();
      });
  }
  
  handleDisciplineNameChange(event) { 
    event.preventDefault();
    let newState = update(this.state, {newDisciplineName: {$set: event.target.value}});
    this.setState(newState);
    return false;
  }
    
  handleDisciplineUpdate(node, pos, discAttrs) {
    api.updateDiscipline(node.id, discAttrs,
        (response) => { this.renderXdsm(); });
  }
  
  handleDisciplineDelete(node, pos) {
    api.deleteDiscipline(node.id, (response) => {
      if (this.state.filter.fr===node.id || this.state.filter.to===node.id) {
        this.handleFilterChange({fr: undefined, to: undefined}); 
      }
      this.renderXdsm(); 
    });
  }
  
  // *** Analysis ************************************************************
  handleAnalysisNameChange(event) { 
    event.preventDefault();
    let newState = update(this.state, {newAnalysisName: {$set: event.target.value}});
    this.setState(newState);
    return false;
  }
  
  handleAnalysisUpdate(event) { 
      event.preventDefault(); 
      api.updateAnalysis(this.props.mda.id, {name: this.state.newAnalysisName}, 
        (response) => {
          let newState = update(this.state, {mda: { name: {$set: this.state.newAnalysisName}}});
          this.setState(newState);
        });
    }

  
  renderXdsm() {
    api.getAnalysisXdsm(this.props.mda.id, 
        (response) => {
          let newState = update(this.state, 
             {mda: {nodes: {$set: response.data.nodes}, 
                    edges: {$set: response.data.edges}, 
                    inactive_edges: {$set: response.data.inactive_edges},
                    vars:  {$set: response.data.vars}}});
          this.setState(newState);
          let mda = {nodes: response.data.nodes, edges: response.data.edges};
          this.xdsmViewer.update(mda);
        }); 
  }
  
  render() {
    let errors = this.state.errors.map((message, i) => {
      return ( <Error key={i} msg={message} /> );
    });  
    let edges = this.state.mda.edges.concat(this.state.mda.inactive_edges);
        
    if (this.state.isEditing) {
      return(
      <div>
        <form className="button_to" method="get" action={url(`/analyses/${this.props.mda.id}`)}>
          <button className="btn float-right" type="submit">
            <i className="fa fa-times-circle" /> Close
          </button>
        </form>
        <h1>Edit {this.state.mda.name}</h1>
        <div className="mda-section">     
          <XdsmViewer ref={xdsmViewer => this.xdsmViewer = xdsmViewer} mda={this.state.mda} 
                      filter={this.state.filter} onFilterChange={this.handleFilterChange}/>
        </div>
        <ul className="nav nav-tabs" id="myTab" role="tablist">
          <li className="nav-item">
            <a className="nav-link " id="analysis-tab" data-toggle="tab" href="#analysis" role="tab" aria-controls="analysis" aria-selected="false">Analysis</a>
          </li>
          <li className="nav-item">
            <a className="nav-link" id="disciplines-tab" data-toggle="tab" href="#disciplines" role="tab" aria-controls="disciplines" aria-selected="false">Disciplines</a>
          </li>
          <li className="nav-item">
            <a className="nav-link" id="connections-tab" data-toggle="tab" href="#connections" role="tab" aria-controls="connections" aria-selected="false">Connections</a>
          </li>
          <li className="nav-item">
            <a className="nav-link active" id="variables-tab" data-toggle="tab" href="#variables" role="tab" aria-controls="variables" aria-selected="true">Variables</a>
          </li>
        </ul>
        <div className="tab-content" id="myTabContent">
          {errors}  
          <div className="tab-pane fade" id="analysis" role="tabpanel" aria-labelledby="analysis-tab">
            <AnalysisEditor newAnalysisName={this.state.newAnalysisName} 
                            onAnalysisUpdate={this.handleAnalysisUpdate} 
                            onAnalysisNameChange={this.handleAnalysisNameChange}/>
          </div>
          <div className="tab-pane fade" id="disciplines" role="tabpanel" aria-labelledby="disciplines-tab">
            <DisciplinesEditor name={this.state.newDisciplineName} 
                               nodes={this.state.mda.nodes} 
                               onDisciplineNameChange={this.handleDisciplineNameChange}
                               onDisciplineCreate={this.handleDisciplineCreate} 
                               onDisciplineDelete={this.handleDisciplineDelete}
                               onDisciplineUpdate={this.handleDisciplineUpdate}
             />
          </div>
          <div className="tab-pane fade" id="connections" role="tabpanel" aria-labelledby="connections-tab">
            <ConnectionsEditor nodes={this.state.mda.nodes} edges={edges} 
                               filter={this.state.filter} onFilterChange={this.handleFilterChange}
                               newConnectionName={this.state.newConnectionName}
                               connectionErrors={this.state.errors}
                               onConnectionNameChange={this.handleConnectionNameChange}
                               onConnectionCreate={this.handleConnectionCreate}
                               onConnectionDelete={this.handleConnectionDelete}
            />
          </div>
          <div className="tab-pane fade show active" id="variables" role="tabpanel" aria-labelledby="variables-tab">
            <VariablesEditor nodes={this.state.mda.nodes} edges={edges} vars={this.state.mda.vars}
                             filter={this.state.filter} onFilterChange={this.handleFilterChange}
                             onConnectionChange={this.handleConnectionChange} 
                             isEditing={this.state.isEditing} />   
          </div>      
        </div>
      </div>);      
    };
    return (
      <div>
        <div className="mda-section">
          <ToolBar mdaId={this.props.mda.id}/>
        </div>
        <div className="mda-section">      
            <XdsmViewer ref={xdsmViewer => this.xdsmViewer = xdsmViewer} mda={this.state.mda} 
                        filter={this.state.filter} onFilterChange={this.handleFilterChange}/>
        </div>
        <div className="mda-section">
          <VariablesEditor nodes={this.state.mda.nodes} edges={edges} vars={this.state.mda.vars}
                           filter={this.state.filter} onFilterChange={this.handleFilterChange}
                           onConnectionChange={this.handleConnectionChange} 
                           isEditing={this.state.isEditing} />
        </div>
      </div>
    );
  }
} 

export { MdaViewer };
    