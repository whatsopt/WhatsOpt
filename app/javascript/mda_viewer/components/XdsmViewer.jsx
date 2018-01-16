import * as d3 from 'd3';
import React from 'react';
let Graph = require('XDSMjs/src/graph');
let Xdsm = require('XDSMjs/src/xdsm');
let Selectable = require('XDSMjs/src/selectable');

class XdsmViewer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      filter: undefined,
    }
    console.log(props.mda)
    this.graph = new Graph(props.mda);
  } 

  componentDidMount() {
    let config = {
        labelizer: {
          ellipsis: 5,
          subSupScript: false,
          showLinkNbOnly: true,
        },
        layout: { 
          origin: {x: 50, y: 20},
          cellsize: {w: 150, h: 50},
          padding: 10,
        },
        titleTooltip: true,
      };
    this.xdsm = new Xdsm(this.graph, 'root', config);
    this.xdsm.draw();
    var selectable_xdsm = new Selectable(this.xdsm, this._onXDSMSelectionChange.bind(this));
    
    // bootstrap tooltip for connections
    $(".ellipsized").attr("data-toggle", "tooltip").attr("data-placement", "right");
    $(function () {
      $('.ellipsized').tooltip()
    })
  }

  render() {
    return ( <div className="xdsm"></div> );
  }

  shouldComponentUpdate() {
    return false;
  }

  addDiscipline(discattrs) {
    this.xdsm.graph.addNode(discattrs);
    this.xdsm.draw();
  }

  updateDiscipline(index, discattrs) {
    var newNode = Object.assign({}, this.xdsm.graph.nodes[index], discattrs);
    console.log(JSON.stringify(discattrs));
    this.xdsm.graph.nodes.splice(index, 1, newNode);
    this.xdsm.refresh();
  }
  removeDiscipline(index) {
    this.xdsm.graph.removeNode(index);
    this.xdsm.draw();
  }
  
  _onXDSMSelectionChange(filter) {
    this.props.onFilterChange(filter);    
  }
}

export default XdsmViewer;