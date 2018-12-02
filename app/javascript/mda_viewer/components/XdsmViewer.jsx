import React from 'react';
import PropTypes from 'prop-types';

import Graph from 'XDSMjs/src/graph';
import Xdsm from 'XDSMjs/src/xdsm';
import Selectable from 'XDSMjs/src/selectable';

class XdsmViewer extends React.Component {
  componentDidMount() {
    const config = {
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
    this._draw();
    this.selectable = new Selectable(this.xdsm, this._onSelectionChange.bind(this));
    this.setSelection(this.props.filter);
    this._setTooltips();
  }

  render() {
    return ( <div id="xdsm" className="xdsm"></div> );
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
    this.xdsm._draw();
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
    this.xdsm._draw();
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
    this.selectable.setFilter(filter);
  }

  _draw() {
    this.xdsm.draw();
    this._setLinks();
  }
  
  _onSelectionChange(filter) {
    this.props.onFilterChange(filter);
  }

  _refresh() {
    $(".ellipsized").tooltip('dispose');
    // remove and redraw xdsm
    this.xdsm.refresh();
    // links
    this._setLinks();
    // reattach selection
    this.selectable.enable();
    // select current
    this.setSelection(this.props.filter);
    // reattach tooltips
    this._setTooltips();
  }

  _setTooltips() {
    // bootstrap tooltip for connections
    $(".ellipsized").attr("data-toggle", "tooltip");
    $(() => {$('.ellipsized').tooltip({placement: 'right'});});
  }
  
  _setLinks() {
    this.props.mda.nodes.forEach((node) => {
      if (node.link) {
        let edit = this.props.isEditing?"/edit":"";
        let link = `/analyses/${node.link.id}${edit}`; 
        let $label = $('.id'+node.id+' tspan');
        console.log($label);
        let label = $label.text();
        $label.html(`<a class='analysis-link' href="${link}">${label}</a>`);
      }
    });
  }
}

XdsmViewer.propTypes = {
  isEditing: PropTypes.bool.isRequired,
  mda: PropTypes.object.isRequired,
  filter: PropTypes.object.isRequired,
  onFilterChange: PropTypes.func.isRequired,
};

export default XdsmViewer;
