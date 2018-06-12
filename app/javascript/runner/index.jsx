import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';

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
    this.state = {hostNameOrIp: "", log:[]};
    
    this.handleHostChange = this.handleHostChange.bind(this); 
    this.handleRun = this.handleRun.bind(this); 
  }

  handleHostChange(event) {
    let newState = update(this.state, {hostNameOrIp:{$set: event.target.value}});
    this.setState(newState);
  }
  
  handleRun(event) {
    event.preventDefault();
    console.log(`run on ${this.state.hostNameOrIp}`);
  }
  
  render() {
    let lines = this.state.log.map((l, i) => {
      return ( <OpenMDAOLogLine key={i} line={l}/> );
    });
    
    return (
      <div className="container-fluid editor-section">
        <form className="form col-3" onSubmit={this.handleRun}>
          <div className="form-group">
            <label className="editor-header">Hostname or Ip</label>
            <input type="text" value={this.state.hostNameOrIp} className="form-control"
                   id="name" onChange={this.handleHostChange}/>
          </div>
          <button type="submit" className="btn btn-primary">Run</button>
        </form>
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

Runner.propTypes = {
  mda: PropTypes.shape({
    name: PropTypes.string,
  }),
};

export {Runner};
