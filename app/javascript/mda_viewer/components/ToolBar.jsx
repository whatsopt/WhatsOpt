import React from 'react';
import axios from 'axios';
import {api, url} from '../../utils/WhatsOptApi';

class OpenMDAOLogLine extends React.Component {  
  
  constructor(props) {
    super(props);
  }
  
  render() {
    return (<div className="listing-line">{this.props.line}</div>);
  }
}

class OpenMDAO extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = { 
      loading:true,
      status_ok: false,
      log: [] 
    };
  }

  componentDidMount() {
    this.getStatus();
  }

  getStatus() {
    api.openmdao_checking(
        this.props.mda_id, 
        response => {this.setState({loading: false, status_ok: response.data.status_ok, log: response.data.log})});
  }
  
  render() {
    let lines = this.state.log.map((l, i) => {
      return ( <OpenMDAOLogLine key={i} line={l}/> );
    });
    let btnStatusClass = this.state.status_ok?"btn btn-success":"btn btn-warning";
    let btnIcon = this.state.status_ok?<i className="fa fa-check"/>:<i className="fa fa-exclamation-triangle"></i>;
    if (this.state.loading) {
      btnStatusClass = "btn btn-info";
      btnIcon = <i className="fa fa-cog fa-spin" />;
    }
    let base = "/analyses/"+this.props.mda_id+"/mda_exports/new"
    let href_om = url(base+".openmdao");
    let href_cd = url(base+".cmdows");
    return (
      <div>
        <div className="btn-toolbar" role="toolbar">   
          <div className="btn-group mr-2" role="group"> 
              <button className={btnStatusClass} type="button" data-toggle="collapse" data-target="#collapseListing" aria-expanded="false">{btnIcon}</button>
            <a className="btn btn-primary" href={href_om}>OpenMDAO Export</a>
          </div>
          <div className="btn-group mr-2" role="group">
            <a className="btn btn-primary" href={href_cd}>Cmdows Export</a>
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

export default OpenMDAO;