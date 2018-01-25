import React from 'react';
import XdsmViewer from 'mda_viewer/components/XdsmViewer'
import Connections from 'mda_viewer/components/Connections'
import ToolBar from 'mda_viewer/components/ToolBar'
import DisciplinesEditor from 'mda_viewer/components/DisciplinesEditor'
import ConnectionsEditor from 'mda_viewer/components/ConnectionsEditor'
import update from 'immutability-helper'
let Graph = require('XDSMjs/src/graph');
import {api, url} from '../utils/WhatsOptApi';

class MdaViewer extends React.Component {
  constructor(props) {
    super(props);
    let nodes = props.mda.nodes.map(function(n) { return {id: n.id, name: n.name, type: n.type}; });
    let edges = props.mda.edges.map(function(e) { return {from: e.from, to: e.to, name: e.name}; });
    let isEditing = props.isEditing;
    this.state = {
      filter: { fr: undefined, to: undefined },
      isEditing: isEditing,
      mda: {name: props.mda.name, nodes: nodes, edges: edges, vars: props.mda.vars},
      mdaNewName: props.mda.name,
      newDisciplineName: '',
    }
    this.handleFilterChange = this.handleFilterChange.bind(this);
    this.handleNewDisciplineName = this.handleNewDisciplineName.bind(this);
    this.handleNewDisciplineNameChange = this.handleNewDisciplineNameChange.bind(this);
    this.handleMdaNewNameChange = this.handleMdaNewNameChange.bind(this);
    this.handleMdaNewName = this.handleMdaNewName.bind(this);
    this.handleDisciplineUpdate = this.handleDisciplineUpdate.bind(this);
    this.handleDisciplineDelete = this.handleDisciplineDelete.bind(this);
  }

  handleFilterChange(filter) { 
    this.setState({filter: {fr: filter.fr, to: filter.to}});
  }

  handleNewDisciplineName(event) { 
    event.preventDefault();
    api.createDiscipline(this.props.mda.id, {name: this.state.newDisciplineName, type: 'analysis'}, 
      (function(response) {
        let newdisc = {id: response.data.id, name: this.state.newDisciplineName, type: 'analysis'};
        let newState = update(this.state, {mda: {nodes: {$push: [newdisc]}}, newDisciplineName: {$set: ''}});
        this.setState(newState);
        this.xdsmViewer.addDiscipline(newdisc);
    }).bind(this));
  }
  
  handleNewDisciplineNameChange(event) { 
    event.preventDefault();
    let newState = update(this.state, {newDisciplineName: {$set: event.target.value}});
    this.setState(newState);
    return false;
  }

  handleMdaNewName(event) { 
    event.preventDefault();
    api.updateAnalysis(this.props.mda.id, {name: this.state.mdaNewName}, 
      (function(response) {
        let newState = update(this.state, {mda: { name: {$set: this.state.mdaNewName}}});
        this.setState(newState);
      }).bind(this));
  }
  
  handleMdaNewNameChange(event) { 
    event.preventDefault();
    let newState = update(this.state, {mdaNewName: {$set: event.target.value}});
    this.setState(newState);
    return false;
  }

  handleDisciplineUpdate(node, pos, discattrs) {
    console.log("INDEX="+pos+" ATTRS="+JSON.stringify(discattrs));
    api.updateDiscipline(node.id, discattrs,
        (function(response) {
          let index = pos-1;
          let newState = update(this.state, {mda: {nodes: {[index]: {$merge: discattrs }} }});
          this.setState(newState);
          this.xdsmViewer.updateDiscipline(pos, discattrs);
    }).bind(this));
  }
  
  handleDisciplineDelete(node, pos) {
    api.deleteDiscipline(node.id, 
        (function(response) {
          let newState = update(this.state, {mda: {nodes: {$splice: [[pos-1, 1]]}}});
          this.setState(newState);
          this.xdsmViewer.removeDiscipline(pos);
    }).bind(this));
  }
  
  render() {
    if (this.state.isEditing) {
      return(
      <div>
        <h1>Edit {this.state.mda.name}</h1>
        <div className="mda-section">     
          <XdsmViewer ref={xdsmViewer => this.xdsmViewer = xdsmViewer} mda={this.state.mda} onFilterChange={this.handleFilterChange}/>
        </div>
        <ul className="nav nav-tabs" id="myTab" role="tablist">
          <li className="nav-item">
            <a className="nav-link " id="analysis-tab" data-toggle="tab" href="#analysis" role="tab" aria-controls="analysis" aria-selected="false">Analysis</a>
          </li>
          <li className="nav-item">
            <a className="nav-link" id="disciplines-tab" data-toggle="tab" href="#disciplines" role="tab" aria-controls="disciplines" aria-selected="false">Disciplines</a>
          </li>
          <li className="nav-item">
            <a className="nav-link active" id="connection-tab" data-toggle="tab" href="#connections" role="tab" aria-controls="connections" aria-selected="true">Connections</a>
          </li>
        </ul>
        <div className="tab-content" id="myTabContent">
          <div className="tab-pane fade" id="analysis" role="tabpanel" aria-labelledby="analysis-tab">
            <div className="container editor-section">
              <label className="editor-header">Name</label>
              <form className="form-inline" onSubmit={this.handleMdaNewName}>
                <div className="form-group">
                  <label htmlFor="name" className="sr-only">Name</label>
                  <input type="text" value={this.state.mdaNewName} className="form-control" id="name" onChange={this.handleMdaNewNameChange}/>
                </div>
                <button type="submit" className="btn btn-primary ml-3">Update</button>
              </form>
            </div>
          </div>
          <div className="tab-pane fade" id="disciplines" role="tabpanel" aria-labelledby="disciplines-tab">
            <DisciplinesEditor name={this.state.newDisciplineName} 
                               nodes={this.state.mda.nodes} 
                               onNewDisciplineName={this.handleNewDisciplineName} 
                               onNewDisciplineNameChange={this.handleNewDisciplineNameChange}
                               onDisciplineDelete={this.handleDisciplineDelete}
                               onDisciplineUpdate={this.handleDisciplineUpdate}
             />
          </div>
          <div className="tab-pane fade show active" id="connections" role="tabpanel" aria-labelledby="connections-tab">
            <ConnectionsEditor nodes={this.state.mda.nodes} edges={this.state.mda.edges} />
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
          <XdsmViewer mda={this.state.mda} onFilterChange={this.handleFilterChange}/>
        </div>
        <div className="mda-section">
          <Connections mda={this.state.mda} filter={this.state.filter} />
        </div>
      </div>
    );
  }
} 

export { MdaViewer };
    