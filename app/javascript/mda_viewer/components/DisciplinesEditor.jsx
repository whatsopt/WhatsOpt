import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';
import {DragDropContext, Droppable, Draggable} from 'react-beautiful-dnd';

class Discipline extends React.Component {
  constructor(props) {
    super(props);
    this.state = {discName: '', discType: 'analysis', isEditing: false};

    this.handleDiscNameChange = this.handleDiscNameChange.bind(this);
    this.handleEdit = this.handleEdit.bind(this);
    this.handleCancelEdit = this.handleCancelEdit.bind(this);
    this.handleUpdate = this.handleUpdate.bind(this);
    this.handleDelete = this.handleDelete.bind(this);
    this.handleSelectChange = this.handleSelectChange.bind(this);
  }

  handleDiscNameChange(event) {
    let newState = update(this.state, {discName: {$set: event.target.value}});
    this.setState(newState);
  }

  handleEdit(event) {
    let newState = {discName: this.props.node.name,
                    discType: this.props.node.type,
                    isEditing: true};
    this.setState(newState);
  }

  handleCancelEdit(event) {
    let newState = update(this.state, {isEditing: {$set: false}});
    this.setState(newState);
  }

  handleUpdate(event) {
    event.preventDefault();
    this.handleCancelEdit(event);
    let discattrs = {name: this.state.discName, type: this.state.discType};
    this.props.onDisciplineUpdate(this.props.node, discattrs);
  }

  handleDelete(event) {
    let self = this;
    dataConfirmModal.confirm({
      title: 'Are you sure?',
      text: 'Really do this?',
      commit: 'Yes',
      cancel: 'No, cancel',
      onConfirm: function() {self.props.onDisciplineDelete(self.props.node);},
      onCancel: function() {},
    });
  }

  handleSelectChange(event) {
    let newState = update(this.state, {discType: {$set: event.target.value}});
    this.setState(newState);
  }

  render() {
    if (this.state.isEditing) {
      return (
          <Draggable draggableId={this.props.node.id} index={this.props.index}>
            {(provided, snapshot) => (
              <li ref={provided.innerRef} {...provided.dragHandleProps} {...provided.draggableProps}
                  className="list-group-item editor-discipline" >
                <form className="form-inline" onSubmit={this.handleUpdate}>
                  <div className="form-group mr-3">
                    <input className="form-control" id="name" type="text" defaultValue={this.state.discName}
                           placeholder='Enter Name...' onChange={this.handleDiscNameChange}/>
                    <select className="form-control ml-1" id="type" value={this.state.discType}
                            onChange={this.handleSelectChange}>
                      <option value="analysis">Analysis</option>
                      <option value="function">Function</option>
                    </select>
                  </div>
                  <button type="submit" className="btn btn-primary">Update</button>
                  <button type="button" onClick={this.handleCancelEdit} className="btn ml-1">Cancel</button>
                </form>
              </li>)}
         </Draggable>
        );
      } else {
        return (
          <Draggable draggableId={this.props.node.id} index={this.props.index}>
            {(provided, snapshot) => (
              <li ref={provided.innerRef} {...provided.dragHandleProps} {...provided.draggableProps}
                  className="list-group-item editor-discipline col-md-4">
                <span className="align-bottom">{this.props.node.name}</span>
                <button className="d-inline btn btn-light btn-inverse btn-sm float-right text-danger"
                 onClick={this.handleDelete}>
                  <i className="fa fa-close"/>
                </button>
                <button className="d-inline btn btn-light btn-sm ml-2" onClick={this.handleEdit}>
                  <i className="fa fa-pencil"/>
                </button>
              </li>)}
          </Draggable>
        );
    }
  }
}

Discipline.propTypes = {
  node: PropTypes.object.isRequired,
  index: PropTypes.number.isRequired,
  onDisciplineUpdate: PropTypes.func.isRequired,
  onDisciplineDelete: PropTypes.func.isRequired,
};

const reorder = (list, startIndex, endIndex) => {
  const result = Array.from(list);
  const [removed] = result.splice(startIndex, 1);
  result.splice(endIndex, 0, removed);

  return result;
};

class DisciplinesEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state = {nodes: this.props.nodes.slice(1)};

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

    const items = reorder(
      this.state.nodes,
      result.source.index,
      result.destination.index
    );
    this.setState({nodes: items});
    this.props.onDisciplineUpdate(this.props.nodes[result.source.index+1],
                                  {position: result.destination.index+1});
  };

  // Take into account in this.state of discipline changes coming
  // from Discipline components that should arrive through new props
  static getDerivedStateFromProps(nextProps, prevState) {
    return {nodes: nextProps.nodes.slice(1)};
  }

  render() {
    let disciplines = this.state.nodes.map((node, i) => {
      return (<Discipline key={node.id} pos={i+1} index={i} node={node}
                onDisciplineUpdate={this.props.onDisciplineUpdate}
                onDisciplineDelete={this.props.onDisciplineDelete} />);
    });
    let nbNodes = disciplines.length;
    if (nbNodes === 0) {
      disciplines = 'None'  
    }
    return (
        <div className='container-fluid'>
          <div className="editor-section">
            <label>Disciplines <span className="badge badge-info">{nbNodes}</span></label>
            <DragDropContext onDragStart={this.onDragStart}
                             onDragUpdate={this.onDragUpdate}
                             onDragEnd={this.onDragEnd}>
              <Droppable droppableId="droppable">
                {(provided, snapshot) => (
                  (<ul ref={provided.innerRef} {...provided.droppableProps} className="list-group">
                    {disciplines}
                    {provided.placeholder}
                  </ul>)
                )}
              </Droppable>
            </DragDropContext>
          </div>
          <div className="editor-section">
            <form className="form-inline" onSubmit={this.props.onDisciplineCreate}>
              <div className="form-group">
                <input type="text" value={this.props.name}
                       placeholder='Enter Discipline Name...' className="form-control"
                       id="name" onChange={this.props.onDisciplineNameChange}/>
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
};

export default DisciplinesEditor;
