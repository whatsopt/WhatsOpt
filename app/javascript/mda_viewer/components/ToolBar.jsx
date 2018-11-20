import React from 'react';
import PropTypes from 'prop-types';
import saveSvgAsPng from 'save-svg-as-png';

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
    this.api = props.api;

    this.state = {
      loading: true,
      statusOk: false,
      log: [],
    };

    this.saveAsPng = this.saveAsPng.bind(this);
  }

  componentDidMount() {
    this.getStatus();
  }

  getStatus() {
    this.api.openmdaoChecking(
        this.props.mdaId,
        (response) => {this.setState({loading: false, statusOk: response.data.statusOk, log: response.data.log});});
  }

  saveAsPng() {
    const elt = d3.select('svg').node();
    const bbox = elt.getBBox();
    saveSvgAsPng.saveSvgAsPng(elt, "xdsm.png", {backgroundColor: 'white',
      width: bbox.width-100,
      height: bbox.height-20});
  }

  render() {
    const lines = this.state.log.map((l, i) => {
      return ( <OpenMDAOLogLine key={i} line={l}/> );
    });
    let btnStatusClass = this.state.statusOk?"btn btn-success":"btn btn-warning";
    let btnIcon = this.state.statusOk?<i className="fa fa-check"/>:<i className="fa fa-exclamation-triangle"></i>;
    if (this.state.loading) {
      btnStatusClass = "btn btn-info";
      btnIcon = <i className="fa fa-cog fa-spin" />;
    }
    const base = "/analyses/"+this.props.mdaId+"/exports/new";
    const hrefOm = this.api.url(base+".openmdao");
    const hrefCd = this.api.url(base+".cmdows");
    return (
      <div>
        <div className="btn-toolbar" role="toolbar">
          <div className="btn-group mr-2" role="group">
            <button className={btnStatusClass} type="button" data-toggle="collapse"
              data-target="#collapseListing" aria-expanded="false">{btnIcon}</button>
            <a className="btn btn-primary" href={hrefOm}>Export OpenMDAO</a>
          </div>
          <div className="btn-group mr-2" role="group">
            <a className="btn btn-primary" href={hrefCd}>Export Cmdows</a>
          </div>
          <div className="btn-group mr-2" role="group">
            <a className="btn btn-primary" href="#" onClick={this.saveAsPng}>Export Image</a>
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
  api: PropTypes.object.isRequired,
  mdaId: PropTypes.number.isRequired,
};

export default ToolBar;
