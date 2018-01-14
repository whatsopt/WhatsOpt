import React from 'react';


class Discipline extends React.Component {
  constructor(props) {
    super(props);
    this.state = { node: props.node, isEditing: false };
    
    this.handleEdit = this.handleEdit.bind(this);
    this.handleCancelEdit = this.handleCancelEdit.bind(this);
    this.handleUpdate = this.handleUpdate.bind(this);
    this.handleDelete = this.handleDelete.bind(this);
    this.onDisciplineUpdate = this.props.onDisciplineUpdate.bind(this);
    this.onDisciplineDelete = this.props.onDisciplineDelete.bind(this);
  }  
  
  handleEdit(event) {
    this.setState({ node: this.state.node, isEditing: true });
  }
  
  handleCancelEdit(event) {
    this.setState({ node: this.state.node, isEditing: false });
  }
  
  handleUpdate(event) {
    event.preventDefault();
    this.onDisciplineUpdate(this.props.node)
  }
  
  handleDelete(event) {
    this.onDisciplineDelete(parseInt(this.props.pos), this.props.node)
  }
  
  render() {
    if (this.state.isEditing) {        
      return (
          <li className="list-group-item editor-discipline">
            <form className="form-inline" onSubmit={this.handleUpdate}>
              <div className="form-group mx-md-3">
                <input type="text" value={this.state.node.name} placeholder='Enter Name...' className="form-control" id="name" onChange={this.handleChange}/>
              </div>
              <button type="submit" className="btn btn-primary">Update</button>
              <button type="button" onClick={this.handleCancelEdit} className="btn ml-md-2">Cancel</button>
             </form>
          </li>); 
      } else {
        return (
          <li className="list-group-item editor-discipline col-md-4">
            <span className="align-bottom">{this.state.node.name}</span>
            <button className="d-inline btn btn-link btn-inverse btn-sm float-right text-danger" onClick={this.handleDelete}>
              <i className="fa fa-close"/>
            </button>
            <button className="d-inline btn btn-link btn-sm ml-2" onClick={this.handleEdit}>
              <i className="fa fa-pencil"/>
            </button>
          </li>); 
    }
  }
}

class DisciplinesEditor extends React.Component {
  constructor(props) {
    super(props);   
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    event.preventDefault();
    this.setState({ name: event.target.value });
    this.props.onNewDisciplineNameChange(event);
  }
  
  render() {
    let disciplines = this.props.nodes.map((node, i) => {
      return (<Discipline key={node.id} pos={i+1} node={node} 
                onDisciplineUpdate={this.props.onDisciplineUpdate}
                onDisciplineDelete={this.props.onDisciplineDelete}/>);
    });

    return (
        <div className='container'>
          <div className="editor-section">
            <ul className="list-group">
              {disciplines}
            </ul>
          </div>
          <div className="editor-section">          
            <form className="form-inline" onSubmit={this.props.onNewDisciplineName}>
              <div className="form-group mx-sm-3">
                <label htmlFor="name" className="sr-only">Name</label>
                <input type="text" value={this.props.name} placeholder='Enter Name...' className="form-control" id="name" onChange={this.handleChange}/>
              </div>
              <button type="submit" className="btn btn-primary">New</button>
            </form>
          </div>
        </div>
        );
  }
}

export default DisciplinesEditor;