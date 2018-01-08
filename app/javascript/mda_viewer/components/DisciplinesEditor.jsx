import React from 'react';


class Discipline extends React.Component {
  constructor(props) {
    super(props);
    this.state = { node: props.node };
  }  
  
  render() {
    return (
        <div className="list-group-item editor-discipline">{this.state.node.name}</div>
        ); 
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
    this.props.onNewNameChange(event);
  }
  
  render() {
    let disciplines = this.props.nodes.map((node, i) => {
      return ( <Discipline key={i} node={node} /> );
    });

    return (
        <div className='container'>
          <div className="row editor-section">
            <div className="list-group">
              {disciplines}
            </div>
          </div>
          <div className="row editor-section">          
            <form className="form-inline" onSubmit={this.props.onNewDiscipline}>
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