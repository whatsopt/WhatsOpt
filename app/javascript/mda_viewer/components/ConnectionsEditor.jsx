import React from 'react';
import PropTypes from 'prop-types';

class DisciplineSelector extends React.Component {
  constructor(props) {
    super(props);
    this.handleSelectChange = this.handleSelectChange.bind(this);
  }

  handleSelectChange(event) {
    event.preventDefault();
    this.props.onSelection(event.target.value);
  }

  render() {
    let disciplines = this.props.nodes.map((node) => {
      let name = node.id===this.props.nodes[0].id?this.props.ulabel:node.name;
      return (<option key={node.id} value={node.id}>{name}</option>);
    });

    let selected = this.props.selected || this.props.nodes[0].id;

    return (
      <div className="input-group mt-3">
        <div className="input-group-prepend" htmlFor={this.props.label}>
          <label className="input-group-text editor-header">{this.props.label}</label>
        </div>
        <select id={this.props.label} className="custom-select" value={selected}
                onChange={this.handleSelectChange}>
          {disciplines}
        </select>
      </div>
    );
  }
}

DisciplineSelector.propTypes = {
  onSelection: PropTypes.func.isRequired,
  nodes: PropTypes.array.isRequired,
  ulabel: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  selected: PropTypes.string,
};

class ConnectionList extends React.Component {
  render() {
    let varnames = this.props.names.split(',');
    let vars = varnames.map((varname, i) => {
      let id = this.props.conn_ids[i];
      let btn = this.props.active?"btn":"btn text-inactive";
      return (<div key={varname} className="btn-group m-1" role="group">
                <button className={btn}>{varname}</button>
                <button className="btn text-danger" onClick={(e) => this.props.onConnectionDelete(id)}>
                  <i className="fa fa-close" />
                </button>
              </div>);
    });

    return (<span className="mb-3">{vars}</span> );
  }
}

ConnectionList.propTypes = {
  names: PropTypes.string.isRequired,
  conn_ids: PropTypes.array.isRequired,
  active: PropTypes.bool.isRequired,
  onConnectionDelete: PropTypes.func.isRequired,
};

class VariableList extends React.Component {
  compare(a, b) {
    if (a.ioMode === b.ioMode) {
      return a.name.localeCompare(b.name);
    }
    return (a.ioMode === "in")?-1:1;
  }

  render() {
    let sorted = this.props.vars.sort(this.compare);
    let vars = sorted.map((v, i) => {
      let badgeKind = "badge " + ((v.ioMode==="in")?"badge-primary":"badge-secondary");
      let klass = v.active?"btn m-1":"btn m-1 text-inactive";
      return <button key={v.name} className={klass}>{v.name} <span className={badgeKind}>{v.ioMode}</span></button>;
    });

    return (<span className="mb-3">{vars}</span> );
  }
}

VariableList.propTypes = {
  vars: PropTypes.array.isRequired,
};

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
            uniqEdges.push({name: name, ioMode: (edge.to === this.props.filter.to)?"in":"out", active: edge.active});
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
        return ( <ConnectionList key={i} names={edge.name} active={edge.active}
                 conn_ids={edge.conn_ids} onConnectionDelete={this.props.onConnectionDelete}/> );
      });
    }

    return (<div>
              <label className="editor-header">{title}  <span className="badge badge-info">{count}</span></label>
              <div>
                {connections}
              </div>
            </div>
            );
  }
}

ConnectionsViewer.propTypes = {
  edges: PropTypes.array.isRequired,
  filter: PropTypes.shape({
    fr: PropTypes.string,
    to: PropTypes.string,
  }),
  onConnectionDelete: PropTypes.func.isRequired,
};

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
            <input type="text" value={this.props.newConnectionName}
                   placeholder='Enter name or comma separated names...'
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

ConnectionsForm.propTypes = {
  newConnectionName: PropTypes.string.isRequired,
  connectionErrors: PropTypes.array.isRequired,
  onConnectionCreate: PropTypes.func.isRequired,
  onConnectionNameChange: PropTypes.func.isRequired,
};

class ConnectionsEditor extends React.Component {
  constructor(props) {
    super(props);
    this.handleFromDisciplineSelected = this.handleFromDisciplineSelected.bind(this);
    this.handleToDisciplineSelected = this.handleToDisciplineSelected.bind(this);
  }

  handleFromDisciplineSelected(nodeId) {
    this.props.onFilterChange({fr: nodeId,
      to: this.props.filter.to || this.props.db.driver.id});
  }

  handleToDisciplineSelected(nodeId) {
    this.props.onFilterChange({to: nodeId,
      fr: this.props.filter.fr || this.props.db.driver.id});
  }

  render() {
    let form;
    if (this.props.filter.fr !== this.props.filter.to) {
        form = (<div className="row editor-section">
                <div className="col-12">
                 <ConnectionsForm newConnectionName={this.props.newConnectionName}
                                onConnectionCreate={this.props.onConnectionCreate}
                                onConnectionNameChange={this.props.onConnectionNameChange}
                                connectionErrors={this.props.connectionErrors}
                                filter={this.props.filter}
                                edges={this.props.db.edges}/>
                </div>
                </div>);
    }

    return (
        <div className="container-fluid">
          <div className="row editor-section">
            <div className="col-2">
              <DisciplineSelector label="From" ulabel="Driver" nodes={this.props.db.nodes}
                                  selected={this.props.filter.fr}
                                  onSelection={this.handleFromDisciplineSelected}/>
            </div>
            <div className="col-2">
              <DisciplineSelector label="To" ulabel="Driver" nodes={this.props.db.nodes}
                                  selected={this.props.filter.to}
                                  onSelection={this.handleToDisciplineSelected}/>
            </div>
          </div>
          <div className="row editor-section">
            <div className="col-12">
                <ConnectionsViewer filter={this.props.filter} edges={this.props.db.edges}
                                   onConnectionDelete={this.props.onConnectionDelete}/>
            </div>
          </div>
          {form}
      </div>
    );
  }
}

ConnectionsEditor.propTypes = {
  db: PropTypes.object.isRequired,
  filter: PropTypes.object.isRequired,
  newConnectionName: PropTypes.string.isRequired,
  connectionErrors: PropTypes.array.isRequired,
  onFilterChange: PropTypes.func.isRequired,
  onConnectionCreate: PropTypes.func.isRequired,
  onConnectionNameChange: PropTypes.func.isRequired,
  onConnectionDelete: PropTypes.func.isRequired,
};

export default ConnectionsEditor;
