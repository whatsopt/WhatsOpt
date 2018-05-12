import React from 'react';
import PropTypes from 'prop-types';
import {api, url} from '../../utils/WhatsOptApi';

class OpenMDAOLogLine extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (<div className="listing-line">{this.props.line}</div>);
  }
}

OpenMDAOLogLine.propTypes= {
  line: PropTypes.string.isRequired,
};


class ToolBar extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      loading: true,
      statusOk: false,
      log: [],
    };
  }

  componentDidMount() {
    this.getStatus();
  }

  getStatus() {
    api.openmdaoChecking(
        this.props.mdaId,
        (response) => {this.setState({loading: false, statusOk: response.data.statusOk, log: response.data.log});});
  }

  render() {
    let lines = this.state.log.map((l, i) => {
      return ( <OpenMDAOLogLine key={i} line={l}/> );
    });
    let btnStatusClass = this.state.statusOk?"btn btn-success":"btn btn-warning";
    let btnIcon = this.state.statusOk?<i className="fa fa-check"/>:<i className="fa fa-exclamation-triangle"></i>;
    if (this.state.loading) {
      btnStatusClass = "btn btn-info";
      btnIcon = <i className="fa fa-cog fa-spin" />;
    }
    let base = "/analyses/"+this.props.mdaId+"/exports/new";
    let hrefOm = url(base+".openmdao");
    let hrefCd = url(base+".cmdows");
    return (
      <div>
        <div className="btn-toolbar" role="toolbar">
          <div className="btn-group mr-2" role="group">
            <button className={btnStatusClass} type="button" data-toggle="collapse"
                    data-target="#collapseListing" aria-expanded="false">{btnIcon}</button>
            <a className="btn btn-primary" href={hrefOm}>OpenMDAO Export</a>
          </div>
          <div className="btn-group mr-2" role="group">
            <a className="btn btn-primary" href={hrefCd}>Cmdows Export</a>
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

ToolBar.propTypes= {
  mdaId: PropTypes.number.isRequired,
};

export default ToolBar;
