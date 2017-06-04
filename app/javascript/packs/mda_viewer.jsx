import * as d3 from 'd3';
import React from 'react';
import ReactDOM from 'react-dom';
import Graph from 'graph';
import Xdsm from 'xdsm';

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

    console.log(JSON.stringify(this.state));
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
        <td>{this.state.varname}</td>
        <td>{this.state.to}</td>
      </tr>
    );
  }
}

class Connections extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props.mda;
  }

  render() {
    var conns = [];
    this.state.edges.forEach((edge) => {
      var vars = edge.name.split(",");
      vars.forEach((v) => {
        var nameFrom = this._findNode(edge.from).name;
        var nameTo = this._findNode(edge.to).name;
        conns.push({
          id: nameFrom + '_' + v + nameTo,
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
            <th>Variable</th>
            <th>To</th>
          </tr>
        </thead>

        <tbody>
          {connections}
        </tbody>
      </table>
    );
  }

  _findNode(id) {
    if (id === '_U_') return {id: '_U_', name: '_U_'};
    for (var i=0; i < this.state.nodes.length; i++) {
      if (this.state.nodes[i].id === id) {
        return this.state.nodes[i];
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
        <h1>MDA {this.state.name}</h1>
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
