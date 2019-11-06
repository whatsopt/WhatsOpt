import React from 'react';
import PropTypes from 'prop-types';
import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd';
import AnalysisSelector from './AnalysisSelector';

// mapping with XDSMjs type values
const DISCIPLINE = 'analysis';
const FUNCTION = 'function';
const ANALYSIS = 'mda';

class Discipline extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      discName: '',
      discType: DISCIPLINE,
      discHost: '',
      discPort: 31400,
      isEditing: false,
    };

    this.handleDiscNameChange = this.handleDiscNameChange.bind(this);
    this.handleDiscHostChange = this.handleDiscHostChange.bind(this);
    this.handleDiscPortChange = this.handleDiscPortChange.bind(this);
    this.handleEdit = this.handleEdit.bind(this);
    this.handleCancelEdit = this.handleCancelEdit.bind(this);
    this.handleUpdate = this.handleUpdate.bind(this);
    this.handleDelete = this.handleDelete.bind(this);
    this.handleSelectChange = this.handleSelectChange.bind(this);
    this.handleSubAnalysisSelected = this.handleSubAnalysisSelected.bind(this);
  }

  handleDiscNameChange(event) {
    this.setState({ discName: event.target.value });
  }

  handleDiscHostChange(event) {
    this.setState({ discHost: event.target.value });
  }

  handleDiscPortChange(event) {
    this.setState({ discPort: event.target.value });
  }

  handleEdit(event) {
    const newState = {
      discName: this.props.node.name,
      discType: this.props.node.type,
      discHost: this.props.node.endpoint ? this.props.node.endpoint.host : '',
      discPort: this.props.node.endpoint ? this.props.node.endpoint.port : 31400,
      isEditing: true,
    };
    this.setState(newState);
  }

  handleCancelEdit() {
    this.setState({ isEditing: false });
  }

  isLocalHost(host) {
    return (host === '' || host === 'localhost' || host === '127.0.0.1');
  }

  handleUpdate(event) {
    event.preventDefault();
    this.handleCancelEdit();
    const discattrs = {
      name: this.state.discName,
      type: this.state.discType,
      endpoint_attributes: { host: this.state.discHost, port: this.state.discPort },
    };
    const { endpoint } = this.props.node;
    if (endpoint && endpoint.id) {
      const endattrs = discattrs.endpoint_attributes;
      endattrs.id = endpoint.id;
      if (this.isLocalHost(endattrs.host)) {
        endattrs._destroy = 1;
      }
    }
    console.log(JSON.stringify(discattrs));
    this.props.onDisciplineUpdate(this.props.node, discattrs);
    if (this.state.selected) {
      this.props.onSubAnalysisSelected(this.props.node, this.state.selected);
    }
  }

  handleDelete(event) {
    const self = this;
    dataConfirmModal.confirm({
      title: 'Are you sure?',
      text: 'Really do this?',
      commit: 'Yes',
      cancel: 'No, cancel',
      onConfirm() { self.props.onDisciplineDelete(self.props.node); },
      onCancel() { },
    });
  }

  handleSelectChange(event) {
    const discType = event.target.value;
    if (discType !== ANALYSIS && this.state.selected) { // unset analysis if needed
      this.setState({ discType, selected: [] });
    } else {
      this.setState({ discType });
    }
  }

  handleSubAnalysisSelected(selected) {
    console.log(`Select ${JSON.stringify(selected)}`);
    this.setState({ selected });
  }

  render() {
    if (this.state.isEditing) {
      let deploymentOrSubAnalysis;
      let selected = [];
      const { link } = this.props.node;
      if (link) {
        selected = [{ id: link.id, label: `#${link.id} ${link.name}` }];
      }
      if (this.state.discType === ANALYSIS) {
        deploymentOrSubAnalysis = (
          <div className="form-group ml-2">
            <AnalysisSelector
              selected={selected}
              onAnalysisSearch={this.props.onSubAnalysisSearch}
              onAnalysisSelected={this.handleSubAnalysisSelected}
            />
          </div>
        );
      } else {
        deploymentOrSubAnalysis = (
          <div className="form-group ml-2">
            <label>deployed on</label>
            <input
              className="form-control ml-1"
              id="name"
              type="text"
              defaultValue={this.state.discHost}
              placeholder="localhost"
              onChange={this.handleDiscHostChange}
            />
          </div>
        );
      }
      return (
        <Draggable draggableId={this.props.node.id} index={this.props.index}>
          {(provided, snapshot) => (
            <li
              ref={provided.innerRef}
              {...provided.dragHandleProps}
              {...provided.draggableProps}
              className="list-group-item editor-discipline"
            >
              <form className="form-inline" onSubmit={this.handleUpdate}>
                <div className="form-group">
                  <input
                    className="form-control"
                    id="name"
                    type="text"
                    defaultValue={this.state.discName}
                    placeholder="Enter Name..."
                    onChange={this.handleDiscNameChange}
                  />
                  <select
                    className="form-control ml-2"
                    id="type"
                    value={this.state.discType}
                    onChange={this.handleSelectChange}
                  >
                    <option value={DISCIPLINE}>Discipline</option>
                    <option value={FUNCTION}>Function</option>
                    <option value={ANALYSIS}>Sub-Analysis</option>
                  </select>
                </div>
                {deploymentOrSubAnalysis}
                <button type="submit" className="btn btn-primary ml-3">Update</button>
                <button type="button" onClick={this.handleCancelEdit} className="btn btn-secondary ml-1">Cancel</button>
              </form>
            </li>
          )}
        </Draggable>
      );
    }
    let item = this.props.node.name;
    const { endpoint } = this.props.node;
    if (endpoint && !this.isLocalHost(endpoint.host)) {
      item += ` on ${endpoint.host}`;
    }

    return (
      <Draggable draggableId={this.props.node.id} index={this.props.index}>
        {(provided, snapshot) => (
          <li
            ref={provided.innerRef}
            {...provided.dragHandleProps}
            {...provided.draggableProps}
            className="list-group-item editor-discipline col-md-4"
          >
            <span className="align-bottom">{item}</span>
            <button
              className="d-inline btn btn-light btn-inverse btn-sm float-right text-danger"
              title="Delete"
              onClick={this.handleDelete}
            >
              <i className="fa fa-times" />
            </button>
            <button className="d-inline btn btn-light btn-sm ml-2" title="Edit" onClick={this.handleEdit}>
              <i className="fa fa-edit" />
            </button>
          </li>
        )}
      </Draggable>
    );
  }
}

Discipline.propTypes = {
  node: PropTypes.object.isRequired,
  index: PropTypes.number.isRequired,
  subAnalysisOption: PropTypes.number,
  onDisciplineUpdate: PropTypes.func.isRequired,
  onDisciplineDelete: PropTypes.func.isRequired,
  onSubAnalysisSearch: PropTypes.func.isRequired,
  onSubAnalysisSelected: PropTypes.func.isRequired,
};

class DisciplinesEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state = { nodes: this.props.nodes.slice(1) };

    this.onDragStart = this.onDragStart.bind(this);
    this.onDragUpdate = this.onDragUpdate.bind(this);
    this.onDragEnd = this.onDragEnd.bind(this);
  }

  onDragStart(result) {
  }

  onDragUpdate(result) {
  }

  onDragEnd(result) {
    if (!result.destination) {
      return;
    }
    this.props.onDisciplineUpdate(
      this.props.nodes[result.source.index + 1],
      { position: result.destination.index + 1 },
    );
  }

  // Take into account in this.state of discipline changes coming
  // from Discipline components that should arrive through new props
  static getDerivedStateFromProps(nextProps, prevState) {
    return { nodes: nextProps.nodes.slice(1) };
  }

  render() {
    let disciplines = this.state.nodes.map((node, i) => (
      <Discipline
        key={node.id}
        pos={i + 1}
        index={i}
        node={node}
        onDisciplineUpdate={this.props.onDisciplineUpdate}
        onDisciplineDelete={this.props.onDisciplineDelete}
        onSubAnalysisSearch={this.props.onSubAnalysisSearch}
        onSubAnalysisSelected={this.props.onSubAnalysisSelected}
      />
    ));
    const nbNodes = disciplines.length;
    if (nbNodes === 0) {
      disciplines = 'None';
    }
    return (
      <div className="container-fluid">
        <div className="editor-section">
          <label>
Disciplines
            <span className="badge badge-info">{nbNodes}</span>
          </label>
          <DragDropContext
            onDragStart={this.onDragStart}
            onDragUpdate={this.onDragUpdate}
            onDragEnd={this.onDragEnd}
          >
            <Droppable droppableId="droppable">
              {(provided, snapshot) => (
                (
                  <ul ref={provided.innerRef} {...provided.droppableProps} className="list-group">
                    {disciplines}
                    {provided.placeholder}
                  </ul>
                )
              )}
            </Droppable>
          </DragDropContext>
        </div>
        <div className="editor-section">
          <form className="form-inline" onSubmit={this.props.onDisciplineCreate}>
            <div className="form-group">
              <input
                type="text"
                value={this.props.name}
                placeholder="Enter Discipline Name..."
                className="form-control"
                id="name"
                onChange={this.props.onDisciplineNameChange}
              />
            </div>
            <button type="submit" className="btn btn-primary ml-3">Add</button>
          </form>
        </div>
      </div>
    );
  }
}

DisciplinesEditor.propTypes = {
  name: PropTypes.string.isRequired,
  nodes: PropTypes.array.isRequired,
  onDisciplineUpdate: PropTypes.func.isRequired,
  onDisciplineDelete: PropTypes.func.isRequired,
  onDisciplineCreate: PropTypes.func.isRequired,
  onDisciplineNameChange: PropTypes.func.isRequired,
  onSubAnalysisSearch: PropTypes.func.isRequired,
  onSubAnalysisSelected: PropTypes.func.isRequired,
};

export default DisciplinesEditor;
