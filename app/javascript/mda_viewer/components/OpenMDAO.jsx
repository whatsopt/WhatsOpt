import React from 'react';
import axios from 'axios';

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
      status_ok: false,
      log: [] 
    };
  }

  componentDidMount() {
    this.getStatus();
  }
  
  getStatus() {
    axios.post('/api/v1/openmdao_checking', {mda_id: this.props.mda_id})
    .then(response => {
      console.log(response.data)
      this.setState({status_ok: response.data.status_ok, log: response.data.log})
    })
    .catch(error => console.log(error))
  }
  
  render() {
    let lines = this.state.log.map((l, i) => {
      return ( <OpenMDAOLogLine key={i} line={l}/> );
    });
    
    let btnStatusClass = this.state.status_ok?"btn btn-success":"btn btn-warning";
    let btnIcon = this.state.status_ok?<i className="fa fa-check"/>:<i className="fa fa-exclamation-triangle"></i>;
    return (
      <div>
        <div className="btn-group" role="group">
          <a className="btn btn-primary" href="/multi_disciplinary_analyses/5/openmdao_generation/new">OpenMDAO Export</a>
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