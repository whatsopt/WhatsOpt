import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';
// disable actioncable: import actionCable from 'actioncable'


class LogLine extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (<div className="listing-line">{this.props.line}</div>);
  }
}

class Runner extends React.Component {
  constructor(props) {
    super(props);
    this.cableApp = {};
    this.api = this.props.api
    
    let status = (this.props.ope.job && this.props.ope.job.status) || 'DONE'
    let log = (this.props.ope.job && this.props.ope.job.log) || ''
    
    this.state = {host: this.props.ope.host, 
                  name: this.props.ope.name, 
                  driver: this.props.ope.driver, 
                  cases: this.props.ope.cases,
                  status: status,
                  log: log};
    
    this.handleHostChange = this.handleHostChange.bind(this); 
    this.handleNameChange = this.handleNameChange.bind(this); 
    this.handleRun = this.handleRun.bind(this); 
    this.handleDriverChange = this.handleDriverChange.bind(this);
    this.handleOperationUpdate = this.handleOperationUpdate.bind(this);
  }

  handleHostChange(event) {
    let newState = update(this.state, {host:{$set: event.target.value}});
    if (this.state.name === 'Pending') {
      newState.name = event.target.value.toUpperCase();  
    }
    this.setState(newState);
  }

  handleNameChange(event) {
    let newState = update(this.state, {name:{$set: event.target.value}});
    this.setState(newState);
  }
  
  handleDriverChange(event) {
    let newState = update(this.state, {driver:{$set: event.target.value}});
    if (this.state.name === 'Unnamed') {
      newState.name = event.target.value.toUpperCase();  
    }
    this.setState(newState);
  }
  
  handleRun(event) {
    event.preventDefault()
    let ope_attrs = { host: this.state.host, driver: this.state.driver, name: this.state.name };
    this.api.updateOperation(this.props.ope.id, ope_attrs, 
        (response) => { this.api.pollOperation(this.props.ope.id,
                            (respData) => { return (respData.job.status === 'DONE'|| respData.job.status === 'FAILED')},
                            (response) => { console.log(response.data); 
                              this.handleOperationUpdate(response.data);
                            },
                            (error) => { console.log(error); });
        },
        (error) => { console.log(error); });
  }

  handleOperationUpdate(ope) {
    let newState = update(this.state, {status: {$set: ope.job.status}, 
                                       log: {$set: ope.job.log},
                                       cases: {$set: ope.cases}
    });
    this.setState(newState);  
  }
  
  render() {
    let lines = this.state.log.split('\n').map((l, i) => {
      return ( <LogLine key={i} line={l}/> );
    });

    let btnStatusClass = this.state.status === "DONE"?"btn btn-success":"btn btn-danger";
    let btnIcon = this.state.status === "DONE"?<i className="fa fa-check"/>:<i className="fa fa-exclamation-triangle" />;
    if (this.state.status === "RUNNING") {
      btnStatusClass = "btn btn-info";
      btnIcon = <i className="fa fa-cog fa-spin"/>;
    }
    if (this.state.status === "PENDING") {
      btnStatusClass = "btn btn-info";
      btnIcon = <i className="fa fa-question"/>;
    }    

    let showEnabled=false;
    if (this.state.status === "DONE" && this.state.driver!=="runonce") {
      showEnabled=true;
    } 
    let showClass="btn btn-light";
    showClass+=showEnabled?"":" disabled"; 
    
    let urlOnClose = `/analyses/${this.props.mda.id}`;
    if (this.state.cases.length > 0) {
      urlOnClose = `/operations/${this.props.ope.id}`;  
    }
    
    return (   
      <div>
      <form className="button_to" method="get" action={this.api.url(urlOnClose)}>
        <button className="btn float-right" type="submit">
          <i className="fa fa-times-circle" /> Close
        </button>
      </form>

      <h1>Operation on {this.props.mda.name}</h1>

      <div className="editor-section">   
        <div className="btn-toolbar" role="toolbar">
          <div className="btn-group mr-2" role="group">
            <button className={btnStatusClass + " btn-primary"} style={{width: "120px"}} type="button" data-toggle="collapse"
                    data-target="#collapseListing" aria-expanded="false">
              {btnIcon}<span className="ml-1">{this.state.status}</span>
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
      <div className="editor-section">
        <form className="form" onSubmit={this.handleRun}>
          <div className="form-group col-3">
            <label htmlFor="name">Operation Name</label>
            <input type="text" value={this.state.name} className="form-control"
                   id="name" onChange={this.handleNameChange}/>
          </div>
          <div className="form-group col-3">
            <label htmlFor="host">Analysis Server</label>
            <input type="text" value={this.state.host} className="form-control"
                   id="host" onChange={this.handleHostChange}/>
          </div>
          <div className="form-group col-3">
            <label htmlFor="driver">Driver</label>
            <select value={this.state.driver} onChange={this.handleDriverChange} className="form-control">
              <optgroup label="Analysis">
                <option value="runonce">RunOnce</option> 
              </optgroup>
              <optgroup label="Design of Experiment">
                <option value="lhs">LHS</option>
                <option value="morris">Morris</option>
              </optgroup>
              <optgroup label="Optimization">
                <option value="slsqp">SLSQP</option>
              </optgroup>
            </select>
          </div>
          <div className="form-group col-3">
            <button type="submit" className="btn btn-primary">Run</button>
          </div>
        </form>
      </div>
      </div>
    );
  } 
}

Runner.propTypes = {
  mda: PropTypes.shape({
    name: PropTypes.string,
  }),
};

export default Runner;
