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
    let disciplines = this.props.nodes.map(node => {
      return (<option key={node.id} value={node.id}>{node.name}</option>);
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


class ConnectionsEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = { nodes: [], from: '', to: '', edges: {}, connName: ''};
    this.handleFromDisciplineSelected = this.handleFromDisciplineSelected.bind(this);
    this.handleToDisciplineSelected = this.handleToDisciplineSelected.bind(this);
    this.handleConnectionNameChange = this.handleConnectionNameChange.bind(this);
  }
  
  handleFromDisciplineSelected(nodeId) {
    this.props.onFilterChange({fr: nodeId, to: this.props.filter.to});
  }
  
  handleToDisciplineSelected(nodeId) {
    this.props.onFilterChange({to: nodeId, fr: this.props.filter.fr});
  }
  
  handleConnectionNameChange(event) {
    event.preventDefault();
    let newState = update(this.state, { connName: {$set: event.target.value } }); 
    //this.props.onNewConnectionNameChange(event);
  }
  
  componentDidMount() {
    let nodes = update(this.props.nodes, {$unshift: [{id: '_U_', name: 'PENDING'}]});
    if (this.props.nodes.length > 0) {
      this.setState({ nodes: nodes, from: '_U_', to: this.props.nodes[0].id, edges: {}, connName: ''});
    }
  }
  
  render() {
      
    console.log('Connection between '+this.props.filter.fr+' and '+this.props.filter.to);
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
      console.log(JSON.stringify(edges));
      connections = ( <VariableList vars={edges} /> );
    } else {
      // Edge selected => Display connection
      title = 'Connection';
      
      let edges = this.props.edges.filter((edge) => {
        return (edge.from === this.props.filter.fr) && (edge.to === this.props.filter.to);  
      }, this);    
      
      console.log(JSON.stringify(edges));
      connections = edges.map((edge, i) => {
        return ( <Connection key={i} names={edge.name} /> );
      });
    }
    
    return (
      <div className="container">
        <div className="row editor-section">
          <div className="col-3">
            <label className="editor-header">From/To</label>
            <DisciplineSelector nodes={this.state.nodes} selected={this.props.filter.fr} onSelection={this.handleFromDisciplineSelected}/>
            <DisciplineSelector nodes={this.state.nodes} selected={this.props.filter.to} onSelection={this.handleToDisciplineSelected}/>
          </div>
          <div className="col-9">
            <label className="editor-header">{title}</label>
            {connections} 
             <form onSubmit={this.props.onNewConnectionName}>
              <div className="form-group"> 
                <label htmlFor="name" className="sr-only">Name</label>
                <input type="text" value={this.props.name} placeholder='Enter name or comma separated names...' 
                       className="form-control mb-1" id="name" onChange={this.handleConnectionNameChange}
                />
                <button type="submit" className="btn btn-primary">New</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    );
  }
} 

export default ConnectionsEditor;