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
    const { onSelection } = this.props;
    onSelection(event.target.value);
  }

  render() {
    const { nodes, ulabel, label } = this.props;
    let { selected } = this.props;
    const disciplines = nodes.map((node) => {
      const name = node.id === nodes[0].id ? ulabel : node.name;
      return (<option key={node.id} value={node.id}>{name}</option>);
    });

    selected = selected || nodes[0].id;

    return (
      <div className="input-group">
        <div className="input-group-prepend" htmlFor={label}>
          <div className="input-group-text">{label}</div>
        </div>
        <select
          id={label}
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
DisciplineSelector.defaultProps = { selected: undefined };
class ConnectionList extends React.PureComponent {
  render() {
    const {
      // eslint-disable-next-line camelcase
      names, conn_ids, active, onConnectionDelete,
    } = this.props;
    const varnames = names.split(',');
    const vars = varnames.map((varname, i) => {
      const id = conn_ids[i];
      const btn = active ? 'btn' : 'btn text-inactive';
      return (
        <div key={varname} className="btn-group m-1" role="group">
          <button type="button" className={btn}>{varname}</button>
          <button
            type="button"
            className="btn text-danger"
            onClick={() => { onConnectionDelete(id); }}
          >
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

function compare(a, b) {
  if (a.ioMode === b.ioMode) {
    return a.name.localeCompare(b.name);
  }
  return (a.ioMode === 'in') ? -1 : 1;
}

class VariableList extends React.PureComponent {
  render() {
    let { vars } = this.props;
    const sorted = vars.sort(compare);
    vars = sorted.map((v) => {
      const badgeKind = `badge ${(v.ioMode === 'in') ? 'badge-primary' : 'badge-secondary'}`;
      const klass = v.active ? 'btn m-1' : 'btn m-1 text-inactive';
      return (
        <button type="button" key={v.name} className={klass}>
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

class ConnectionsViewer extends React.PureComponent {
  render() {
    const { filter, onConnectionDelete } = this.props;
    let { edges } = this.props;
    let connections = [];
    let title = '';
    let count = 0;
    if (filter.fr === filter.to) {
      // Node selected => display input/output variables
      title = 'Variables';
      edges = edges.filter((edge) => (edge.from === filter.fr) || (edge.to === filter.to), this);
      const uniqEdges = [];
      const uniqNames = [];
      edges.forEach((edge) => {
        edge.name.split(',').forEach((name) => {
          if (!uniqNames.includes(name)) {
            uniqEdges.push({ name, ioMode: (edge.to === filter.to) ? 'in' : 'out', active: edge.active });
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

      edges = edges.filter((edge) => (edge.from === filter.fr) && (edge.to === filter.to), this);
      connections = edges.map((edge) => {
        count += edge.name.split(',').length;
        return (
          <ConnectionList
            key={edge.name}
            names={edge.name}
            active={edge.active}
            conn_ids={edge.conn_ids}
            onConnectionDelete={onConnectionDelete}
          />
        );
      });
    }

    return (
      <div>
        <div>
          {title}
          {' '}
          <span className="badge badge-info">{count}</span>
        </div>
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
  }).isRequired,
  onConnectionDelete: PropTypes.func.isRequired,
};

class ConnectionsForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {

    };
  }

  render() {
    const {
      connectionErrors, selectedConnectionNames, db, filter,
      onConnectionCreate, onConnectionNameChange,
    } = this.props;
    let { edges } = this.props;
    const isErroneous = (connectionErrors.length > 0);
    const selected = selectedConnectionNames;
    // console.log("RENDER ", selected);
    const outvars = db.getOutputVariables(filter.fr);
    // console.log("OUTPUT VARS = " + JSON.stringify(outvars));
    edges = edges.filter(
      (edge) => (edge.from === filter.fr) && (edge.to === filter.to),
      this,
    ) || [];
    const current = edges.map((edge) => edge.name.split(','))[0] || [];
    // console.log("CURRENT = " + JSON.stringify(current));
    const selectable = outvars.filter((e) => !current.includes(e.name));
    // console.log("SELECTABLE", selectable);
    return (
      <form className="form" onSubmit={onConnectionCreate} noValidate>
        <div className="form-group">
          <div htmlFor="typeahead-vars" className="sr-only">
            Name
            <Typeahead
              id="typeahead-vars"
              allowNew
              newSelectionPrefix="New: "
              multiple
              labelKey="name"
              selectHintOnEnter
              isInvalid={isErroneous}
              minLength={1}
              placeholder="Enter variable names..."
              onChange={(sel) => { onConnectionNameChange(sel); }}
              options={selectable}
              selected={selected}
            />
          </div>
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
    const { onFilterChange, db, filter } = this.props;
    onFilterChange({ fr: nodeId, to: filter.to || db.driver.id });
  }

  handleToDisciplineSelected(nodeId) {
    const { onFilterChange, db, filter } = this.props;
    onFilterChange({ to: nodeId, fr: filter.fr || db.driver.id });
  }

  render() {
    let form;
    const {
      filter, db, selectedConnectionNames, onConnectionCreate,
      onConnectionNameChange, connectionErrors, onConnectionDelete,
    } = this.props;
    if (filter.fr !== filter.to) {
      form = (
        <div className="row editor-section">
          <div className="col-12">
            <ConnectionsForm
              db={db}
              filter={filter}
              selectedConnectionNames={selectedConnectionNames}
              onConnectionCreate={onConnectionCreate}
              onConnectionNameChange={onConnectionNameChange}
              connectionErrors={connectionErrors}
              edges={db.edges}
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
              nodes={db.nodes}
              selected={filter.fr}
              onSelection={this.handleFromDisciplineSelected}
            />
          </div>
          <div className="col-2">
            <DisciplineSelector
              label="To"
              ulabel="Driver"
              nodes={db.nodes}
              selected={filter.to}
              onSelection={this.handleToDisciplineSelected}
            />
          </div>
        </div>
        <div className="row editor-section">
          <div className="col-12">
            <ConnectionsViewer
              filter={filter}
              edges={db.edges}
              onConnectionDelete={onConnectionDelete}
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
