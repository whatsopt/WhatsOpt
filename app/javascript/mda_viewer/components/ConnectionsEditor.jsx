import React from 'react';
import update from 'immutability-helper'

class DisciplineSelector extends React.Component {
  constructor(props) {
    super(props)
    this.state = { selected: '_U_'};
    
    this.handleSelectChange = this.handleSelectChange.bind(this);
  }
  
  handleSelectChange(event) {
    event.preventDefault();
    this.setState({selected: event.target.value});
    this.props.onSelection(event.target.value);
  }
  
  render() {
    let disciplines = this.props.nodes.map(node => {
      return (<option key={node.id} value={node.id}>{node.name}</option>);
    }); 
      
    return (              
      <select className="form-control" id="type" value={this.state.selected} onChange={this.handleSelectChange}>
        {disciplines}
      </select>
    );
  }
}


class Connection extends React.Component {
  constructor(props) {
    super(props);
  }  
  
  render() {
    let varnames = this.props.names.split(',');  
    console.log(varnames);
    let vars = varnames.map((varname, i) => {
      return <li key={varname} className="list-group-item">{varname}</li>
    });
      
    return (<ul className="list-group">
            {vars}
            </ul>
            );
  }
}

class ConnectionsEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = { from: '_U_', to: '_U_', edges: {} };
    
    this.handleFromDisciplineSelected = this.handleFromDisciplineSelected.bind(this);
    this.handleToDisciplineSelected = this.handleToDisciplineSelected.bind(this);
  }
  
  handleFromDisciplineSelected(nodeId) {
    let newState = update(this.state, { from: {$set: nodeId} });  
    this.setState(newState);
  }
  
  handleToDisciplineSelected(nodeId) {
    let newState = update(this.state, { to: {$set: nodeId} });  
    this.setState(newState);  
  }
  
  render() {
    let nodes = update(this.props.nodes, {$unshift: [{id:'_U_', name:'PENDING'}]}); 
      
    console.log('Connexion between '+this.state.from+' and '+this.state.to);
    let edges = this.props.edges.filter((edge) => {
      return (edge.from === this.state.from) && (edge.to === this.state.to);  
    }, this);
      
    let connections = edges.map((edge, i) => {
      return ( <Connection key={i} names={edge.name} /> );
    });
    
    return (
        <div className="container">
        <div className="row editor-section">
          <div className="col-3">
            <label className="editor-header">From</label>
            <DisciplineSelector nodes={nodes} onSelection={this.handleFromDisciplineSelected}/>
          </div>
          <div className="col-6">
            <label className="editor-header">Variables</label>
            {connections} 
          </div>
          <div className="col-3">
            <label className="editor-header">To</label>
            <DisciplineSelector nodes={nodes} onSelection={this.handleToDisciplineSelected}/>
          </div>
        </div>
        </div>
        );
  }
} 

export default ConnectionsEditor;