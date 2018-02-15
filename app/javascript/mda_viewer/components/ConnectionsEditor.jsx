import React from 'react';
import update from 'immutability-helper'

class DisciplineSelector extends React.Component {
  constructor(props) {
    super(props)    
    this.handleSelectChange = this.handleSelectChange.bind(this);
  }
  
  handleSelectChange(event) {
    event.preventDefault();
    this.setState({selected: event.target.value});
    this.props.onSelection(event.target.value);
  }
  
  render() {
    let disciplines = this.props.nodes.map((node) => {
      let name = node.id===this.props.nodes[0].id?this.props.ulabel:node.name
      return (<option key={node.id} value={node.id}>{name}</option>);
    }); 
      
    return (  
      <div className="input-group mt-3">
        <div className="input-group-prepend" htmlFor={this.props.label}>
          <label className="input-group-text editor-header">{this.props.label}</label>
        </div>
        <select id={this.props.label} className="custom-select" id="type" value={this.props.selected} onChange={this.handleSelectChange}>
          {disciplines}
        </select>
      </div>
    );
  }
}

class ConnectionList extends React.Component {

  render() {
    let varnames = this.props.names.split(',');  
    let href="#";
    let vars = varnames.map((varname, i) => {
      let id = this.props.conn_ids[i];
      return (<div key={varname} className="btn-group m-1" role="group">
                <button className="btn">{varname}</button>
                <button className="btn text-danger" onClick={(e) => this.props.onConnectionDelete(id)}>
                  <i className="fa fa-close" />
                </button>
              </div>);
    });
      
    return (<div className="mb-3">{vars}</div> );
  }
}

class VariableList extends React.Component {

  compare(a, b) {
    if (a.ioMode === b.ioMode) {
      return a.name.localeCompare(b.name); 
    }
    return (a.ioMode === "in")?-1:1;
  } 
  
  render() {
    let sorted = this.props.vars.sort(this.compare);
    let vars = this.props.vars.map((v, i) => {
      let badgeKind = "badge " + ((v.ioMode==="in")?"badge-primary":"badge-secondary");
      return <button key={v.name} className="btn m-1">{v.name} <span className={badgeKind}>{v.ioMode}</span></button>
    });
      
    return (<div className="mb-3">{vars}</div> );
  }
}

class ConnectionsViewer extends React.Component {

  render() {
    let connections = [];
    let title = '';
    let count = 0;
    if (this.props.filter.fr === this.props.filter.to) {
      // Node selected => display input/output variables
      title = 'Variables';
      
      let edges = this.props.edges.filter((edge) => {
        return (edge.from === this.props.filter.fr) || (edge.to === this.props.filter.to);  
      }, this);
      let uniqEdges = [];
      let uniqNames = [];
      edges.forEach((edge, i) => {
        edge.name.split(',').forEach((name, j) => {  
          if (!uniqNames.includes(name)) {
            uniqEdges.push({name: name, ioMode: (edge.to === this.props.filter.to)?"in":"out"}); 
            uniqNames.push(name);
          }  
        }, this); 
      }, this);
      edges = uniqEdges;
      count = edges.length;
      connections = ( <VariableList vars={edges} /> );
    } else {
      // Edge selected => Display connection
      title = 'Connections';
    
      let edges = this.props.edges.filter((edge) => {
        return (edge.from === this.props.filter.fr) && (edge.to === this.props.filter.to);  
      }, this);    
      connections = edges.map((edge, i) => {
        count += edge.name.split(',').length;
        return ( <ConnectionList key={i} names={edge.name} conn_ids={edge.conn_ids} onConnectionDelete={this.props.onConnectionDelete}/> );
      });
    }

    return (<div>
              <label className="editor-header">{title}  <span className="badge badge-info">{count}</span></label>
              {connections} 
            </div>
            );
  }
}

class Error extends React.Component {

  render() {
    return (<div className="alert alert-warning" role="alert">
              {this.props.msg}
            </div>);  
  }
}

class ConnectionsForm extends React.Component {
  
  render() {
    let isErroneous = (this.props.connectionErrors.length > 0);
    let inputClass = "form-control ml-1";
    if (this.props.newConnectionName.length>0) {
      inputClass += isErroneous?" is-invalid":" is-valid";
    }
    return (
        <form className="form" onSubmit={this.props.onConnectionCreate} noValidate>
          <div className="form-group"> 
            <label htmlFor="name" className="sr-only">Name</label>
            <input type="text" value={this.props.newConnectionName} placeholder='Enter name or comma separated names...' 
                   className={inputClass} id="name" onChange={this.props.onConnectionNameChange}
            />
          </div>
          <div className="form-group">  
            <button type="submit" className="btn btn-primary" disabled={isErroneous}>Add</button>
          </div>
        </form>
      );
  }
}

class ConnectionsEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = { nodes: [], from: '', to: '' };
    this.handleFromDisciplineSelected = this.handleFromDisciplineSelected.bind(this);
    this.handleToDisciplineSelected = this.handleToDisciplineSelected.bind(this);
  }
  
  handleFromDisciplineSelected(nodeId) {
    this.props.onFilterChange({fr: nodeId, to: this.props.filter.to});
  }
  
  handleToDisciplineSelected(nodeId) {
    this.props.onFilterChange({to: nodeId, fr: this.props.filter.fr});
  }
    
  render() {
    let form, errors;
    if (this.props.filter.fr !== this.props.filter.to) {
        errors = this.props.connectionErrors.map((message, i) => {
            return ( <Error key={i} msg={message} /> );
        });

        form = (<div className="row editor-section">
                <div className="col-12">
                 <ConnectionsForm newConnectionName={this.props.newConnectionName} 
                                onConnectionCreate={this.props.onConnectionCreate} 
                                onConnectionNameChange={this.props.onConnectionNameChange}
                                connectionErrors={this.props.connectionErrors}
                                filter={this.props.filter}
                                edges={this.props.edges}/>
                </div>
                </div>);  
    } 
      
    return (
        <div className="container-fluid">
          <div className="row editor-section">
            <div className="col-2">
              <DisciplineSelector label="From" ulabel="Driver" nodes={this.props.nodes} selected={this.props.filter.fr} onSelection={this.handleFromDisciplineSelected}/>
            </div>
            <div className="col-2">  
              <DisciplineSelector label="To" ulabel="Driver" nodes={this.props.nodes} selected={this.props.filter.to} onSelection={this.handleToDisciplineSelected}/>
            </div>
          </div>
          <div className="row editor-section">
            <div className="col-12">
                <ConnectionsViewer filter={this.props.filter} edges={this.props.edges} 
                                   onConnectionDelete={this.props.onConnectionDelete}/>
            </div>
          </div>
          {errors}
          {form}
      </div>
    );
  }
} 

export default ConnectionsEditor;