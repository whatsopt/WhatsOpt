import React from 'react';
import PropTypes from 'prop-types';
import saveSvgAsPng from 'save-svg-as-png';
import { select } from 'd3-selection';

class OpenMDAOLogLine extends React.PureComponent {
  render() {
    const { line } = this.props;
    return (<div className="listing-line">{line}</div>);
  }
}

OpenMDAOLogLine.propTypes = {
  line: PropTypes.string.isRequired,
};

function saveAsPng() {
  const elt = select('svg').node();
  const bbox = elt.getBBox();
  saveSvgAsPng.saveSvgAsPng(elt, 'xdsm.png', {
    backgroundColor: 'white',
    width: bbox.width - 100,
    height: bbox.height - 20,
  });
}

function _convertVariablesToCsv(connections) {
  const headers = ['Active', 'From', 'To', 'Name', 'Description', 'Role',
    'Type', 'Shape', 'Units', 'Init', 'Lower', 'Upper'];
  const rows = [];
  connections.forEach((conn) => {
    const row = [];
    row.push(conn.active, conn.from, conn.to, conn.name,
      conn.desc, conn.role, conn.type, conn.shape);
    row.push(conn.units, conn.init, conn.lower, conn.upper);
    rows.push(row.join(';'));
  });
  const csv = `${headers.join(';')}\n${rows.join('\n')}\n`;
  return csv;
}

function _exportCsvVariables(connections) {
  const csv = _convertVariablesToCsv(connections);
  const filename = 'analysis.csv';
  const data = `data:application/csv;charset=utf-8,${encodeURIComponent(csv)}`;

  const link = document.createElement('a');
  link.setAttribute('href', data);
  link.setAttribute('download', filename);
  link.style.visibility = 'hidden';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}


class ToolBar extends React.Component {
  constructor(props) {
    super(props);
    this.api = props.api;

    this.state = {
      loading: true,
      statusOk: false,
      log: [],
    };

    this.saveAsPng = saveAsPng.bind(this);
    this.exportCsv = this.exportCsv.bind(this);
  }

  componentDidMount() {
    this.getStatus();
  }

  getStatus() {
    const { mdaId } = this.props;
    this.api.openmdaoChecking(
      mdaId,
      (response) => {
        this.setState({
          loading: false,
          statusOk: response.data.statusOk,
          log: response.data.log,
        });
      },
    );
  }

  exportCsv() {
    const { db } = this.props;
    const connections = db.computeConnections();
    _exportCsvVariables(connections);
  }

  render() {
    const { mdaId } = this.props;
    const { log, statusOk, loading } = this.state;

    // eslint-disable-next-line react/no-array-index-key
    const lines = log.map((l, i) => (<OpenMDAOLogLine key={i} line={l} />));
    let btnStatusClass = statusOk ? 'btn btn-success' : 'btn btn-warning';
    let btnIcon = statusOk ? <i className="fa fa-check" /> : <i className="fa fa-exclamation-triangle" />;
    if (loading) {
      btnStatusClass = 'btn btn-info';
      btnIcon = <i className="fa fa-cog fa-spin" />;
    }
    const base = `/analyses/${mdaId}/exports/new`;
    const hrefOm = this.api.url(`${base}.openmdao`);
    const hrefCd = this.api.url(`${base}.cmdows`);
    return (
      <div>
        <div className="btn-toolbar" role="toolbar">
          <div className="btn-group mr-2" role="group">
            <button
              className={btnStatusClass}
              type="button"
              data-toggle="collapse"
              data-target="#collapseListing"
              aria-expanded="false"
            >
              {btnIcon}
            </button>
            <a className="btn btn-primary" href={hrefOm}>Export OpenMDAO</a>
          </div>
          <div className="btn-group mr-2" role="group">
            <a className="btn btn-primary" href={hrefCd}>Export Cmdows</a>
          </div>
          <div className="btn-group mr-2" role="group">
            <button
              type="button"
              className="btn btn-primary"
              href="#"
              onClick={this.exportCsv}
            >
              Export Csv
            </button>
          </div>
          <div className="btn-group mr-2" role="group">
            <button
              type="button"
              className="btn btn-primary"
              onClick={this.saveAsPng}
            >
              Export Image
            </button>
          </div>
        </div>
        <div className="collapse" id="collapseListing">
          <div className="card card-block">
            <div className="listing">
              {lines}
            </div>
          </div>
        </div>
      </div>
    );
  }
}

ToolBar.propTypes = {
  api: PropTypes.object.isRequired,
  db: PropTypes.object.isRequired,
  mdaId: PropTypes.number.isRequired,
};

export default ToolBar;
