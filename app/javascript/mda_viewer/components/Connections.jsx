import React from 'react';

class Connection extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props.conn;
  }

  render() {
    return (
      <tr>
        <td>{this.state.from}</td>
        <td>{this.state.to}</td>
        <td>{this.state.varname}</td>
      </tr>
    );
  }
}

class Connections extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      mda: this.props.mda,
      filter: this.props.filter,
    };
  }

  render() {
    var conns = [];
    var edges = this.state.mda.edges;
    var filter = this.state.filter;

    if (filter) {
      var nodeFrom = this._findNodeFromIndex(filter.from);
      var nodeTo = this._findNodeFromIndex(filter.to);
      var edges = edges.filter((edge) => {
        return edge.from === nodeFrom.id && edge.to === nodeTo.id;
      });
    }

    edges.forEach((edge) => {
      var vars = edge.name.split(",");
      vars.forEach((v) => {
        var nameFrom = this._findNodeFromId(edge.from).name;
        var nameTo = this._findNodeFromId(edge.to).name;
        conns.push({
          id: nameFrom + '_' + v + + '_' + nameTo,
          from: nameFrom,
          to: nameTo,
          varname: v,
        });
      }, this);
    }, this);

    var connections = conns.map((conn) => {
      return ( <Connection key={conn.id} conn={conn}/> );
    });

    return (
      <table className="table table-striped connections">
        <thead>
          <tr>
            <th>From</th>
            <th>To</th>
            <th>Variable</th>
          </tr>
        </thead>

        <tbody>
          {connections}
        </tbody>
      </table>
     );
  };

  _findNodeFromIndex(index) {
    if ( 0 <= index && index < this.state.mda.nodes.length ) {
      return this.state.mda.nodes[index];
    }
    throw Error("Node index ("+ index +") out of range: " + JSON.stringify(this.state.nodes));
  }

  _findNodeFromId(id) {
    if (id === '_U_') return {id: '_U_', name: '_U_'}; 
    for (var i=0; i < this.state.mda.nodes.length; i++) {
      if (this.state.mda.nodes[i].id === id) {
        return this.state.mda.nodes[i];
      }
    };
    throw Error("Node id ("+ id +") unknown: " + JSON.stringify(this.state.nodes));  
  }
}

export default Connections;