import * as d3 from 'd3';
import React from 'react';
let Graph = require('XDSMjs/src/graph');
let Xdsm = require('XDSMjs/src/xdsm');
let Selectable = require('XDSMjs/src/selectable');

class XdsmViewer extends React.Component {

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
    this.graph = new Graph(this.props.mda, "", "noDefaultDriver");
    this.graph.nodes[0].name = 'Driver';
    this.graph.nodes[0].type = 'driver';
    this.xdsm = new Xdsm(this.graph, 'root', config);
    this.xdsm.draw();
    this.selectable = new Selectable(this.xdsm, this._onSelectionChange.bind(this));
    this.setSelection(this.props.filter);
    this._setTooltips();
  }

  render() {
    return ( <div className="xdsm"></div> );
  }

  shouldComponentUpdate() {
    return false;
  }

  update(mda) {
    this.xdsm.graph = new Graph(mda, "", "noDefaultDriver");
    this.xdsm.graph.nodes[0].name = 'Driver';
    this.xdsm.graph.nodes[0].type = 'driver';
    this._refresh();
  } 
  
  addDiscipline(discattrs) {
    this.xdsm.graph.addNode(discattrs);
    this.xdsm.draw();
    this.selectable.enable();
  }

  updateDiscipline(index, discattrs) {
    var newNode = Object.assign({}, this.xdsm.graph.nodes[index], discattrs);
    console.log(JSON.stringify(discattrs));
    this.xdsm.graph.nodes.splice(index, 1, newNode);
    this._refresh();
  }
  
  removeDiscipline(index) {
    this.xdsm.graph.removeNode(index);
    this.xdsm.draw();
  }
  
  addConnection(connattrs) {
    connattrs.names.map((name) =>
      this.xdsm.graph.addEdgeVar(connattrs.from, connattrs.to, name));
    this._refresh();
  }
    
  removeConnection(connattrs) {
    connattrs.names.map((name) =>
      this.xdsm.graph.removeEdgeVar(connattrs.from, connattrs.to, name));
    this._refresh();
  }
    
  setSelection(filter) {
    // console.log("SELECTION "+JSON.stringify(filter));
    this.selectable.setFilter(filter); 
  }
  
  _onSelectionChange(filter) {
    this.props.onFilterChange(filter);    
  }
  
  _refresh() {
    $(".ellipsized").tooltip('dispose');
    // remove and redraw xdsm 
    this.xdsm.refresh();
    // reattach selection
    this.selectable.enable();
    // select current
    this.setSelection(this.props.filter);
    // reattach tooltips
    this._setTooltips();
  }
  
  _setTooltips() {
    // bootstrap tooltip for connections
    $(".ellipsized").attr("data-toggle", "tooltip")
    $(() => { $('.ellipsized').tooltip({placement: 'right'}); });  
  }
}

export default XdsmViewer;