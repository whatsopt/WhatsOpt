import React from 'react';
import XdsmViewer from 'mda_viewer/components/XdsmViewer'
import Connections from 'mda_viewer/components/Connections'
import ToolBar from 'mda_viewer/components/ToolBar'
import EditionToolBar from 'mda_viewer/components/EditionToolBar'
import DisciplinesEditor from 'mda_viewer/components/DisciplinesEditor'
import update from 'immutability-helper'
import Graph from 'XDSMjs/src/graph';
import api from '../../utils/WhatsOptApi';

class MdaViewer extends React.Component {
  constructor(props) {
    super(props);
    let nodes = props.mda.nodes.map(function(n) { return {id: n.id, name: n.name, type: n.type}; });
    let edges = props.mda.edges.map(function(e) { return {from: e.from, to: e.to, name: e.name}; });
    let isEditing = props.isEditing;
    this.state = {
      filter: { fr: undefined, to: undefined },
      isEditing: isEditing,
      mda: {id: props.mda.id, nodes: nodes, edges: edges, vars: props.mda.vars},
      newDisciplineName: '',
    }
    this.handleFilterChange = this.handleFilterChange.bind(this);
    this.handleNewDiscipline = this.handleNewDiscipline.bind(this);
    this.handleNewNameChange = this.handleNewNameChange.bind(this);
  }

  handleFilterChange(filter) { 
    this.setState({filter: {fr: filter.fr, to: filter.to}});
  }

  handleNewDiscipline(event) { 
    event.preventDefault();
    api.create_discipline({name: this.state.newDisciplineName, type: 'analysis'}, function() {
      let newState = update(this.state, {mda: {nodes: {$push: [{id:'NewNode', name: this.state.newDisciplineName, type: 'analysis'}] }}});
      this.setState(newState);
    });
  }
  
  handleNewNameChange(event) { 
    event.preventDefault();
    this.setState({newDisciplineName: event.target.value});
    return false;
  }
  
  render() {
    if (this.state.isEditing) {
      return(
      <div>
        <div className="mda-section">     
          <XdsmViewer mda={this.state.mda} onFilterChange={this.handleFilterChange}/>
        </div>
        <ul className="nav nav-tabs" id="myTab" role="tablist">
          <li className="nav-item">
            <a className="nav-link active" id="disciplines-tab" data-toggle="tab" href="#disciplines" role="tab" aria-controls="disciplines" aria-selected="true">Disciplines</a>
          </li>
          <li className="nav-item">
            <a className="nav-link" id="connection-tab" data-toggle="tab" href="#connections" role="tab" aria-controls="connections" aria-selected="false">Connections</a>
          </li>
        </ul>
        <div className="tab-content" id="myTabContent">
          <div className="tab-pane fade show active" id="disciplines" role="tabpanel" aria-labelledby="disciplines-tab">
            <DisciplinesEditor nodes={this.state.mda.nodes} onNewDiscipline={this.handleNewDiscipline} onNewNameChange={this.handleNewNameChange}/>
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
    