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
      let name = node.id==="_U_"?this.props.ulabel:node.name
      return (<option key={node.id} value={node.id}>{name}</option>);
    }); 
      
    return (              
      <select className="form-control mb-1" id="type" value={this.props.selected} onChange={this.handleSelectChange}>
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
    let vars = varnames.map((varname, i) => {
      return <button key={varname} className="btn m-1">{varname}</button>
    });
      
    return (<div className="mb-3">{vars}</div> );
  }
}

class VariableList extends React.Component {
  constructor(props) {
    super(props);
  }  
    
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

class Error extends React.Component {
  constructor(props) {
    super(props);  
  }    
  
  render() {
    return (<div className="alert alert-warning" role="alert">
              <a href="#" data-dismiss="alert" className="close">×</a>
              {this.props.msg}
            </div>);  
  }
}


class ConnectionsForm extends React.Component {
  constructor(props) {
    super(props);  
  } 
  
  render() {
    let errors = this.props.connectionErrors.map((message, i) => {
        return ( <Error key={i} msg={message} /> );
    });
    
    return (
      <div className="container">
        <label className="editor-header">{this.props.title}</label>
        {this.props.connections} 
        <div>{errors}</div>
        <form onSubmit={this.props.onNewConnectionName}>
          <div className="form-group"> 
            <label htmlFor="name" className="sr-only">Name</label>
            <input type="text" value={this.props.newConnectionName} placeholder='Enter name or comma separated names...' 
                   className="form-control mb-1" id="name" onChange={this.props.onNewConnectionNameChange}
            />
            <button type="submit" className="btn btn-primary">New</button>
          </div>
        </form>
      </div>);
  }
}

class ConnectionsEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = { nodes: [], from: '', to: '', edges: {} };
    this.handleFromDisciplineSelected = this.handleFromDisciplineSelected.bind(this);
    this.handleToDisciplineSelected = this.handleToDisciplineSelected.bind(this);
  }
  
  handleFromDisciplineSelected(nodeId) {
    this.props.onFilterChange({fr: nodeId, to: this.props.filter.to});
  }
  
  handleToDisciplineSelected(nodeId) {
    this.props.onFilterChange({to: nodeId, fr: this.props.filter.fr});
  }
  
  componentDidMount() {
    let nodes = update(this.props.nodes, {$unshift: [{id: '_U_', name: 'PENDING'}]});
    if (this.props.nodes.length > 0) {
      this.setState({ nodes: nodes, from: '_U_', to: this.props.nodes[0].id, edges: {}, connName: ''});
    }
  }
  
  render() {
    let connections = [];
    let title = '';
    if (this.props.filter.fr === this.props.filter.to) {
      // Node selected
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
      connections = ( <VariableList vars={edges} /> );
    } else {
      // Edge selected => Display connection
      title = 'Connection';
      
      let edges = this.props.edges.filter((edge) => {
        return (edge.from === this.props.filter.fr) && (edge.to === this.props.filter.to);  
      }, this);    
      
      connections = edges.map((edge, i) => {
        return ( <Connection key={i} names={edge.name} /> );
      });
    }
    
    return (
      <div className="container">
        <div className="row editor-section">
          <div className="col-3">
            <label className="editor-header">From/To</label>
            <DisciplineSelector ulabel="INWARD" nodes={this.state.nodes} selected={this.props.filter.fr} onSelection={this.handleFromDisciplineSelected}/>
            <DisciplineSelector ulabel="OUTWARD" nodes={this.state.nodes} selected={this.props.filter.to} onSelection={this.handleToDisciplineSelected}/>
          </div>
          <div className="col-9">
            <ConnectionsForm title={title} connections={connections} newConnectionName={this.props.newConnectionName} 
                             onNewConnectionName={this.props.onNewConnectionName} 
                             onNewConnectionNameChange={this.props.onNewConnectionNameChange}
                             connectionErrors={this.props.connectionErrors}/>
          </div>      
        </div>
      </div>
    );
  }
} 

export default ConnectionsEditor;