import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';
import {api, url} from '../utils/WhatsOptApi';
import actionCable from 'actioncable'


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
    this.state = {hostNameOrIp: "", status: "UNKNOWN" ,log:[]};
    
    this.handleHostChange = this.handleHostChange.bind(this); 
    this.handleRun = this.handleRun.bind(this); 
  }

  handleHostChange(event) {
    let newState = update(this.state, {hostNameOrIp:{$set: event.target.value}});
    this.setState(newState);
  }
  
  handleRun() {
    let ope_attrs={};
    api.updateOperation(this.props.ope.id, ope_attrs, 
            (response) => console.log(response));
  }
  
  componentDidMount() {
    //Action Cable setup
    const cableApp = {};
    //cableApp.cable = actionCable.createConsumer(`ws://endymion:3000/cable`);
    cableApp.cable = actionCable.createConsumer(`ws://192.168.99.100:3000/cable`);

    console.log("Create OperationRunChannel "+this.props.ope.id);
    cableApp.cable.subscriptions.create(
      {channel: "OperationRunChannel", ope_id: this.props.ope.id},
      {connected: () => {
         // Called when the subscription is ready for use on the server
         console.log("connected");
         this.handleRun()
       },
       disconnected: function() {
         // Called when the subscription has been terminated by the server
         console.log("disconnected");
       },
       received: (data) => {
         let newState = update(this.state, {status: {$set: data.status},
                                            log: {$set: data.log}});
         this.setState(newState);
         // Called when there's incoming data on the websocket for this channel
         console.log("receive "+JSON.stringify(data));  
       }
     });
   }

  render() {
    let lines = this.state.log.map((l, i) => {
      return ( <LogLine key={i} line={l}/> );
    });

    let btnStatusClass = this.state.status === "DONE"?"btn btn-success":"btn btn-danger";
    let btnIcon = this.state.status === "DONE"?<i className="fa fa-check"/>:<i className="fa fa-exclamation-triangle" />;
    if (this.state.status === "RUNNING") {
      btnStatusClass = "btn btn-info";
      btnIcon = <i className="fa fa-cog fa-spin" />;
    }
    if (this.state.status === "UNKNOWN") {
      btnStatusClass = "btn btn-info";
      btnIcon = <i className="fa fa-question" />;
    }    

    let saveEnabled=false;
    let runEnabled=false;
    if (this.state.status === "DONE") {
      saveEnabled=true;
      runEnabled=true;
    } 
    if (this.state.status === "FAILED") {
      runEnabled=true;      
    }     
    return (        
      <div className="container-fluid editor-section">   
        <div className="btn-toolbar" role="toolbar">
          <div className="btn-group mr-4" role="group">
            <button className={btnStatusClass + " btn-primary"} style={{width: "120px"}} type="button" data-toggle="collapse"
                    data-target="#collapseListing" aria-expanded="true">
              {btnIcon}<span className="ml-1">{this.state.status}</span>
            </button>
          </div>
          <div className="btn-group mr-2" role="group">
            <button className="btn btn-primary" onClick={this.handleRun} disabled={!runEnabled}>Re-run</button>
          </div>
          <div className="btn-group mr-2" role="group">
            <button className="btn btn-primary" disabled={!saveEnabled}>Save</button>
          </div>
        </div>
        <div className="collapse show" id="collapseListing">
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
