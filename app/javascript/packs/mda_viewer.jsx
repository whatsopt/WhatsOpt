import * as d3 from 'd3';
import React from 'react';
import ReactDOM from 'react-dom';
import Graph from 'xdsmjs/graph';
import Xdsm from 'xdsmjs/xdsm';

class XdsmViewer extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props.mda;
  } 

  componentDidMount() {
    // D3 drawing
    var tooltip = d3.select("body").selectAll(".tooltip").data(['tooltip'])
    .enter().append("div")
    .attr("class", "tooltip")
    .style("opacity", 0);

    var graph = new Graph(this.state);
    var xdsm = new Xdsm(graph, 'root', tooltip);
    xdsm.draw();
  }

  shouldComponentUpdate() {
    return false; // This prevents future re-renders of this component
  }

  render() {
    return ( <div className="xdsm"></div> );
  }
}

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

class Mda extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props.mda;
  }

  render() {
    return (
      <div>
        <XdsmViewer mda={this.state}/>
        <Connections mda={this.state}/>
      </div>
    );
  }
} 

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Mda mda={MDA} />,
    document.getElementById('mda-viewer')
  );
});

    