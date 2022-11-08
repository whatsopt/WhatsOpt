import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';
import { XDSMjs, XDSM_V2 } from 'xdsmjs';

const DEFAULT_XDSM_VERSION = XDSM_V2;

class XdsmViewer extends React.Component {
  static _setTooltips() {
    // bootstrap tooltip for connections
    // eslint-disable-next-line no-undef
    $('.ellipsized').attr('data-bs-toggle', 'tooltip');
    // eslint-disable-next-line no-undef
    $('.ellipsized').attr('data-bs-placement', 'right');
  }

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
    const xdsmMda = update(mda, {
      nodes: {
        0: {
          name: { $set: 'Driver' },
          type: { $set: 'driver' },
        },
      },
    });
    this.selectableXdsm = XDSMjs(config)
      .createSelectableXdsm(xdsmMda, this._onSelectionChange.bind(this));
    this.setSelection(filter);
    this._setLinks();
    XdsmViewer._setTooltips();
  }

  shouldComponentUpdate() {
    return false;
  }

  setSelection(filter) {
    this.selectableXdsm.setSelection(filter);
  }

  update(mda) {
    // remove bootstrap tooltip
    // eslint-disable-next-line no-undef
    // $('.ellipsized').tooltip('dispose');

    const xdsmMda = update(mda, { nodes: { 0: { name: { $set: 'Driver' }, type: { $set: 'driver' } } } });
    this.selectableXdsm.updateMdo(xdsmMda);

    // links
    this._setLinks();
    // select current
    const { filter } = this.props;
    this.setSelection(filter);
    // reattach tooltips
    XdsmViewer._setTooltips();
  }

  _onSelectionChange(filter) {
    const { onFilterChange } = this.props;
    onFilterChange(filter);
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
