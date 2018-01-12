import React from 'react';
import XdsmViewer from 'mda_viewer/components/XdsmViewer'
import Connections from 'mda_viewer/components/Connections'
import ToolBar from 'mda_viewer/components/ToolBar'
import DisciplinesEditor from 'mda_viewer/components/DisciplinesEditor'
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
      mda: {id: props.mda.id, name: props.mda.name, nodes: nodes, edges: edges, vars: props.mda.vars},
      mdaNewName: props.mda.name,
      newDisciplineName: '',
    }
    this.handleFilterChange = this.handleFilterChange.bind(this);
    this.handleNewDisciplineName = this.handleNewDisciplineName.bind(this);
    this.handleNewDisciplineNameChange = this.handleNewDisciplineNameChange.bind(this);
    this.handleMdaNewNameChange = this.handleMdaNewNameChange.bind(this);
    this.handleMdaNewName = this.handleMdaNewName.bind(this);
  }

  handleFilterChange(filter) { 
    this.setState({filter: {fr: filter.fr, to: filter.to}});
  }

  handleNewDisciplineName(event) { 
    event.preventDefault();
    api.createDiscipline(this.props.mda.id, {name: this.state.newDisciplineName, kind: 'analysis'}, 
      (function(response) {
        let newdisc = {id: response.data.id, name: this.state.newDisciplineName, kind: 'analysis'};
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
            <a className="nav-link active" id="analysis-tab" data-toggle="tab" href="#analysis" role="tab" aria-controls="analysis" aria-selected="true">Analysis</a>
          </li>
          <li className="nav-item">
            <a className="nav-link" id="disciplines-tab" data-toggle="tab" href="#disciplines" role="tab" aria-controls="disciplines" aria-selected="false">Disciplines</a>
          </li>
          <li className="nav-item">
            <a className="nav-link" id="connection-tab" data-toggle="tab" href="#connections" role="tab" aria-controls="connections" aria-selected="false">Connections</a>
          </li>
        </ul>
        <div className="tab-content" id="myTabContent">
          <div className="tab-pane fade show active" id="analysis" role="tabpanel" aria-labelledby="analysis-tab">
            <div className="editor-section">
              <form className="form-inline" onSubmit={this.handleMdaNewName}>
                <div className="form-group mx-sm-3">
                  <label htmlFor="name" className="sr-only">Name</label>
                  <input type="text" value={this.state.mdaNewName} className="form-control" id="name" onChange={this.handleMdaNewNameChange}/>
                </div>
                <button type="submit" className="btn btn-primary">Update</button>
              </form>
            </div>
          </div>
          <div className="tab-pane fade" id="disciplines" role="tabpanel" aria-labelledby="disciplines-tab">
            <DisciplinesEditor name={this.state.newDisciplineName} 
                               nodes={this.state.mda.nodes} 
                               onNewDisciplineName={this.handleNewDisciplineName} 
                               onNewDisciplineNameChange={this.handleNewDisciplineNameChange}/>
          </div>
          <div className="tab-pane fade" id="connections" role="tabpanel" aria-labelledby="connections-tab">...</div>
        </div>
      </div>);      
    };
    return (
      <div>
        <div className="mda-section">
          <ToolBar mda_id={this.state.mda.id} isEditing={this.props.isEditing}/>
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
    