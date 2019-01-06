import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';
import {DragDropContext, Droppable, Draggable} from 'react-beautiful-dnd';
import AnalysisSelector from './AnalysisSelector';

// mapping with XDSMjs type values
const DISCIPLINE='analysis';
const FUNCTION='function';
const ANALYSIS='mda'

class Discipline extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {discName: '', discType: DISCIPLINE, isEditing: false};

    this.handleDiscNameChange = this.handleDiscNameChange.bind(this);
    this.handleEdit = this.handleEdit.bind(this);
    this.handleCancelEdit = this.handleCancelEdit.bind(this);
    this.handleUpdate = this.handleUpdate.bind(this);
    this.handleDelete = this.handleDelete.bind(this);
    this.handleSelectChange = this.handleSelectChange.bind(this);
    this.handleSubAnalysisSelected = this.handleSubAnalysisSelected.bind(this);
  }

  handleDiscNameChange(event) {
    this.setState({discName: event.target.value});
  }

  handleEdit(event) {
    const newState = {discName: this.props.node.name,
      discType: this.props.node.type,
      isEditing: true};
    this.setState(newState);
  }

  handleCancelEdit() {
    this.setState({isEditing: false});
  }

  handleUpdate(event) {
    event.preventDefault();
    this.handleCancelEdit();
    const discattrs = {name: this.state.discName, type: this.state.discType};
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
      onConfirm: function() {self.props.onDisciplineDelete(self.props.node);},
      onCancel: function() {},
    });
  }

  handleSelectChange(event) {
    let discType = event.target.value;
    if (discType !== ANALYSIS && this.state.selected) {  // unset analysis if needed
      this.setState({discType, selected: []});
    } else {
      this.setState({discType});
    }
  }

  handleSubAnalysisSelected(selected) {
    console.log("Select "+JSON.stringify(selected));
    this.setState({selected});
    // let name = selected[0].label.match(/#\d+ (.*)/);
    // if (name) {
    //   this.setState({selected, discName: name[1]});
    // } else {
    //   this.setState({selected});
    // }
    //this.props.onSubAnalysisSelected(this.props.node, selected);
  }
  
  render() {
    if (this.state.isEditing) {
      let subAnalysis = null;
      let selected = [];
      let link = this.props.node.link;
      if (link) {
        selected = [{id: link.id, label: `#${link.id} ${link.name}`}];
      }
      if (this.state.discType === ANALYSIS) {
        subAnalysis = 
          <AnalysisSelector
            selected={selected}
            onAnalysisSearch={this.props.onSubAnalysisSearch}
            onAnalysisSelected={this.handleSubAnalysisSelected}
          />
      }
      return (
        <Draggable draggableId={this.props.node.id} index={this.props.index}>
          {(provided, snapshot) => (
            <li ref={provided.innerRef} {...provided.dragHandleProps} {...provided.draggableProps}
              className="list-group-item editor-discipline" >
              <form className="form-inline" onSubmit={this.handleUpdate}>
                <div className="form-group">
                  <input className="form-control" id="name" type="text" defaultValue={this.state.discName}
                    placeholder='Enter Name...' onChange={this.handleDiscNameChange}/>
                  <select className="form-control ml-2" id="type" value={this.state.discType}
                    onChange={this.handleSelectChange}>
                    <option value={DISCIPLINE}>Discipline</option>
                    <option value={FUNCTION}>Function</option>
                    <option value={ANALYSIS}>Sub-Analysis</option>
                  </select>
                </div>
                {subAnalysis}
                <button type="submit" className="btn btn-primary ml-3">Update</button>
                <button type="button" onClick={this.handleCancelEdit} className="btn btn-secondary ml-1">Cancel</button>
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
                <i className="fa fa-times"/>
              </button>
              <button className="d-inline btn btn-light btn-sm ml-2" onClick={this.handleEdit}>
                <i className="fa fa-edit"/>
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
  subAnalysisOption: PropTypes.number,
  onDisciplineUpdate: PropTypes.func.isRequired,
  onDisciplineDelete: PropTypes.func.isRequired,
  onSubAnalysisSearch: PropTypes.func.isRequired,
  onSubAnalysisSelected: PropTypes.func.isRequired,
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
        onDisciplineDelete={this.props.onDisciplineDelete} 
        onSubAnalysisSearch={this.props.onSubAnalysisSearch} 
        onSubAnalysisSelected={this.props.onSubAnalysisSelected} />);
    });
    const nbNodes = disciplines.length;
    if (nbNodes === 0) {
      disciplines = 'None';
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
  onSubAnalysisSearch: PropTypes.func.isRequired,
  onSubAnalysisSelected: PropTypes.func.isRequired,
};

export default DisciplinesEditor;
