import React from 'react';


class Discipline extends React.Component {
  constructor(props) {
    super(props);
    this.state = { node: props.node };
  }  
  
  render() {
    return (
        <li className="list-inline-item editor-discipline">{this.state.node.name}</li>
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
    this.props.onNewDisciplineNameChange(event);
  }
  
  render() {
    let disciplines = this.props.nodes.map((node, i) => {
      return ( <Discipline key={i} node={node} /> );
    });

    return (
        <div className='container'>
          <div className="editor-section">
            <ul className="list-inline">
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