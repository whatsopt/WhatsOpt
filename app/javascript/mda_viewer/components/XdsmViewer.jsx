import React from 'react';
import PropTypes from 'prop-types';

import Graph from 'XDSMjs/src/graph';
import Xdsm, { VERSION2 } from 'XDSMjs/src/xdsm';
import Selectable from 'XDSMjs/src/selectable';

function _setTooltips() {
  // bootstrap tooltip for connections

  // eslint-disable-next-line no-undef
  $('.ellipsized').attr('data-toggle', 'tooltip');
  // eslint-disable-next-line no-undef
  $(() => { $('.ellipsized').tooltip({ placement: 'right' }); });
}

const DEFAULT_XDSM_VERSION = VERSION2;

class XdsmViewer extends React.Component {
  constructor(props) {
    super(props);
    this.state = { version: DEFAULT_XDSM_VERSION };
  }

  componentDidMount() {
    const { version } = this.state;
    const config = {
      labelizer: {
        ellipsis: 5,
        subSupScript: false,
        showLinkNbOnly: true,
      },
      layout: {
        origin: { x: 50, y: 20 },
        cellsize: { w: 150, h: 50 },
        padding: 10,
      },
      withTitleTooltip: false,
      withDefaultDriver: false,
      version,
    };
    const { mda, filter } = this.props;
    this.graph = new Graph(mda, '', config.withDefaultDriver);
    this.graph.nodes[0].name = 'Driver';
    this.graph.nodes[0].type = 'driver';
    this.xdsm = new Xdsm(this.graph, 'root', config);
    this._draw();
    this.selectable = new Selectable(this.xdsm, this._onSelectionChange.bind(this));
    this.setSelection(filter);
    _setTooltips();
  }

  shouldComponentUpdate() {
    return false;
  }

  setSelection(filter) {
    this.selectable.setFilter(filter);
  }

  addDiscipline(discattrs) {
    this.xdsm.graph.addNode(discattrs);
    this.xdsm._draw();
    this.selectable.enable();
  }

  updateDiscipline(index, discattrs) {
    const newNode = { ...this.xdsm.graph.nodes[index], ...discattrs };
    console.log(JSON.stringify(discattrs));
    this.xdsm.graph.nodes.splice(index, 1, newNode);
    this._refresh();
  }

  removeDiscipline(index) {
    this.xdsm.graph.removeNode(index);
    this.xdsm._draw();
  }

  addConnection(connattrs) {
    connattrs.names.map((name) => this.xdsm.graph.addEdgeVar(connattrs.from, connattrs.to, name));
    this._refresh();
  }

  removeConnection(connattrs) {
    connattrs.names.map(
      (name) => this.xdsm.graph.removeEdgeVar(connattrs.from, connattrs.to, name),
    );
    this._refresh();
  }


  update(mda) {
    this.xdsm.graph = new Graph(mda, '', 'noDefaultDriver');
    this.xdsm.graph.nodes[0].name = 'Driver';
    this.xdsm.graph.nodes[0].type = 'driver';
    this._refresh();
  }

  _draw() {
    this.xdsm.draw();
    this._setLinks();
  }

  _onSelectionChange(filter) {
    const { onFilterChange } = this.props;
    onFilterChange(filter);
  }

  _refresh() {
    // eslint-disable-next-line no-undef
    $('.ellipsized').tooltip('dispose');
    // remove and redraw xdsm
    this.xdsm.refresh();
    // links
    this._setLinks();
    // reattach selection
    this.selectable.enable();
    // select current
    const { filter } = this.props;
    this.setSelection(filter);
    // reattach tooltips
    _setTooltips();
  }

  _setLinks() {
    const { mda, isEditing, api } = this.props;
    mda.nodes.forEach((node) => {
      if (node.link) {
        const edit = isEditing ? '/edit' : '';
        const link = `/analyses/${node.link.id}${edit}`;
        // eslint-disable-next-line no-undef
        const $label = $(`.id${node.id} tspan`);
        const label = $label.text();
        $label.html(`<a class='analysis-link' href="${api.url(link)}">${label}</a>`);
      }
    });
    // eslint-disable-next-line no-undef
    $('.analysis-link').on('click', (e) => e.stopPropagation());
  }

  render() {
    const { version } = this.state;
    return (<div className={version} />);
  }
}

XdsmViewer.propTypes = {
  api: PropTypes.object.isRequired,
  isEditing: PropTypes.bool.isRequired,
  mda: PropTypes.object.isRequired,
  filter: PropTypes.object.isRequired,
  onFilterChange: PropTypes.func.isRequired,
};

export default XdsmViewer;
