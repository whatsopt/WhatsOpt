import React from 'react';


class Connection extends React.Component {
  constructor(props) {
    super(props);
    this.state = props.node;
  }  
  
  render() {
    return (
        <li className="list-group-item">{this.props.node.name}</li>
        );
  }
}

class ConnectionsEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = { nodes: props.nodes };
  }
  
  render() {
    let disciplines = nodes.map((node, i) => {
      return ( <Discipline key={i} node={node} /> );
    });

    return (
        <ul className="list-group">
          {disciplines}
        </ul>
        );
  }
}

export default ConnectionsEditor;