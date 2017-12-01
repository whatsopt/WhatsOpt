import React from 'react';
import axios from 'axios';

let token = document.getElementsByName('csrf-token')[0].getAttribute('content')
axios.defaults.headers.common['X-CSRF-Token'] = token
axios.defaults.headers.common['Accept'] = 'application/json'
axios.defaults.headers.common['Authorization'] = 'Token '+API_KEY
let relative_url_root = document.getElementsByName('relative-url-root')[0].getAttribute('content')
//axios.defaults.baseURL = 'http://endymion:3000'

class OpenMDAOLogLine extends React.Component {  
  
  constructor(props) {
    super(props);
  }
  
  render() {
    return (<div className="listing-line">{this.props.line}</div>);
  }
}


//prepend relative_url_root
var url = function (path) {
    return relative_url_root+path;
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
    axios.post(url('/api/v1/openmdao_checking'), {mda_id: this.props.mda_id})
    .then(response => {
      this.setState({loading: false, status_ok: response.data.status_ok, log: response.data.log})
    })
    .catch(error => console.log(error))
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
    let href = url("/multi_disciplinary_analyses/"+this.props.mda_id+"/openmdao_generation/new");
    return (
      <div>
        <div className="btn-group" role="group">
          <a className="btn btn-primary" href={href}>OpenMDAO Export</a>
          <button className={btnStatusClass} type="button" data-toggle="collapse" data-target="#collapseListing" aria-expanded="false">{btnIcon}</button>
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