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
  
  handleRun(event) {
    event.preventDefault();
    api.createOperation(this.props.mda.id, 
            (response) => console.log(response),
            (error) => console.log(error));
  }
  
  componentDidMount() {
    //Action Cable setup
    const cableApp = {};
    cableApp.cable = actionCable.createConsumer(`ws://endymion:3000/cable`);

    console.log("Create OperationRunChannel "+this.props.ope.id);
    cableApp.cable.subscriptions.create({channel: "OperationRunChannel", 
                                         ope_id: this.props.ope.id},
      {
        connected: () => {
          // Called when the subscription is ready for use on the server
          console.log("connected");
          api.updateOperation(this.props.ope.id, "endymion", 
                  (response) => console.log(response)
                  );
        },

        disconnected: function() {
          // Called when the subscription has been terminated by the server
          console.log("disconnected");
        },

        received: (data) => {
          let newState = update(this.state, { status: {$set: data.status},
                                              log: {$set: data.log}
                                            });
          this.setState(newState);
          // Called when there's incoming data on the websocket for this channel
          console.log("receive "+JSON.stringify(data));  
        }});
    
   }
  
  render() {
    let lines = this.state.log.map((l, i) => {
      return ( <LogLine key={i} line={l}/> );
    });
    
    return (
      <div className="container-fluid editor-section">   
        <div className="listing-line">Status: {this.state.status}</div>
        {lines}
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
