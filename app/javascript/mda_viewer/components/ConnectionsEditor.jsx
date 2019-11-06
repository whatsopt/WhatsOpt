import React from 'react';
import PropTypes from 'prop-types';
import { Typeahead } from 'react-bootstrap-typeahead';

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
    const disciplines = this.props.nodes.map((node) => {
      const name = node.id === this.props.nodes[0].id ? this.props.ulabel : node.name;
      return (<option key={node.id} value={node.id}>{name}</option>);
    });

    const selected = this.props.selected || this.props.nodes[0].id;

    return (
      <div className="input-group">
        <div className="input-group-prepend" htmlFor={this.props.label}>
          <label className="input-group-text">{this.props.label}</label>
        </div>
        <select
          id={this.props.label}
          className="custom-select"
          value={selected}
          onChange={this.handleSelectChange}
        >
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
    const varnames = this.props.names.split(',');
    const vars = varnames.map((varname, i) => {
      const id = this.props.conn_ids[i];
      const btn = this.props.active ? 'btn' : 'btn text-inactive';
      return (
        <div key={varname} className="btn-group m-1" role="group">
          <button className={btn}>{varname}</button>
          <button className="btn text-danger" onClick={(e) => this.props.onConnectionDelete(id)}>
            <i className="fa fa-times" />
          </button>
        </div>
      );
    });

    return (<span className="mb-3">{vars}</span>);
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
    return (a.ioMode === 'in') ? -1 : 1;
  }

  render() {
    const sorted = this.props.vars.sort(this.compare);
    const vars = sorted.map((v, i) => {
      const badgeKind = `badge ${(v.ioMode === 'in') ? 'badge-primary' : 'badge-secondary'}`;
      const klass = v.active ? 'btn m-1' : 'btn m-1 text-inactive';
      return (
        <button key={v.name} className={klass}>
          {v.name}
          {' '}
          <span className={badgeKind}>{v.ioMode}</span>
        </button>
      );
    });

    return (<span className="mb-3">{vars}</span>);
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

      let edges = this.props.edges.filter((edge) => (edge.from === this.props.filter.fr) || (edge.to === this.props.filter.to), this);
      const uniqEdges = [];
      const uniqNames = [];
      edges.forEach((edge, i) => {
        edge.name.split(',').forEach((name, j) => {
          if (!uniqNames.includes(name)) {
            uniqEdges.push({ name, ioMode: (edge.to === this.props.filter.to) ? 'in' : 'out', active: edge.active });
            uniqNames.push(name);
          }
        }, this);
      }, this);
      edges = uniqEdges;
      count = edges.length;
      connections = (<VariableList vars={edges} />);
    } else {
      // Edge selected => Display connection
      title = 'Connections';

      const edges = this.props.edges.filter((edge) => (edge.from === this.props.filter.fr) && (edge.to === this.props.filter.to), this);
      connections = edges.map((edge, i) => {
        count += edge.name.split(',').length;
        return (
          <ConnectionList
            key={i}
            names={edge.name}
            active={edge.active}
            conn_ids={edge.conn_ids}
            onConnectionDelete={this.props.onConnectionDelete}
          />
        );
      });
    }

    return (
      <div>
        <label>
          {title}
          {' '}
          <span className="badge badge-info">{count}</span>
        </label>
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
  constructor(props) {
    super(props);
    this.state = {
      allowNew: true,
      newSelectionPrefix: 'New: ',
      multiple: true,
      labelKey: 'name',
      selectHintOnEnter: true,
    };
  }

  render() {
    const isErroneous = (this.props.connectionErrors.length > 0);
    const selected = this.props.selectedConnectionNames;
    // console.log("RENDER ", selected);
    const outvars = this.props.db.getOutputVariables(this.props.filter.fr);
    // console.log("OUTPUT VARS = " + JSON.stringify(outvars));
    const edges = this.props.edges.filter((edge) => (edge.from === this.props.filter.fr) && (edge.to === this.props.filter.to), this) || [];
    const current = edges.map((edge) => edge.name.split(','))[0] || [];
    // console.log("CURRENT = " + JSON.stringify(current));
    const selectable = outvars.filter((e) => !current.includes(e.name));
    // console.log("SELECTABLE", selectable);
    return (
      <form className="form" onSubmit={this.props.onConnectionCreate} noValidate>
        <div className="form-group">
          <label htmlFor="name" className="sr-only">Name</label>
          <Typeahead
            id="typeahead-vars"
            {...this.state}
            isInvalid={isErroneous}
            minLength={1}
            placeholder="Enter variable names..."
            onChange={(selected) => {
              this.props.onConnectionNameChange(selected);
            }}
            options={selectable}
            selected={selected}
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
  db: PropTypes.object.isRequired,
  filter: PropTypes.object.isRequired,
  edges: PropTypes.array.isRequired,
  selectedConnectionNames: PropTypes.array.isRequired,
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
    this.props.onFilterChange({
      fr: nodeId,
      to: this.props.filter.to || this.props.db.driver.id,
    });
  }

  handleToDisciplineSelected(nodeId) {
    this.props.onFilterChange({
      to: nodeId,
      fr: this.props.filter.fr || this.props.db.driver.id,
    });
  }

  render() {
    let form;
    if (this.props.filter.fr !== this.props.filter.to) {
      form = (
        <div className="row editor-section">
          <div className="col-12">
            <ConnectionsForm
              db={this.props.db}
              filter={this.props.filter}
              selectedConnectionNames={this.props.selectedConnectionNames}
              onConnectionCreate={this.props.onConnectionCreate}
              onConnectionNameChange={this.props.onConnectionNameChange}
              connectionErrors={this.props.connectionErrors}
              edges={this.props.db.edges}
            />
          </div>
        </div>
      );
    }

    return (
      <div className="container-fluid">
        <div className="row editor-section">
          <div className="col-2">
            <DisciplineSelector
              label="From"
              ulabel="Driver"
              nodes={this.props.db.nodes}
              selected={this.props.filter.fr}
              onSelection={this.handleFromDisciplineSelected}
            />
          </div>
          <div className="col-2">
            <DisciplineSelector
              label="To"
              ulabel="Driver"
              nodes={this.props.db.nodes}
              selected={this.props.filter.to}
              onSelection={this.handleToDisciplineSelected}
            />
          </div>
        </div>
        <div className="row editor-section">
          <div className="col-12">
            <ConnectionsViewer
              filter={this.props.filter}
              edges={this.props.db.edges}
              onConnectionDelete={this.props.onConnectionDelete}
            />
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
  selectedConnectionNames: PropTypes.array.isRequired,
  connectionErrors: PropTypes.array.isRequired,
  onFilterChange: PropTypes.func.isRequired,
  onConnectionCreate: PropTypes.func.isRequired,
  onConnectionNameChange: PropTypes.func.isRequired,
  onConnectionDelete: PropTypes.func.isRequired,
};

export default ConnectionsEditor;
