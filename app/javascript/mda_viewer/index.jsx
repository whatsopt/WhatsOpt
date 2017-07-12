import React from 'react';
import XdsmViewer from 'mda_viewer/components/XdsmViewer'
import Connections from 'mda_viewer/components/Connections'

class Mda extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props.mda;
  }

  render() {
    return (
      <div>
        <h2>XDSM</h2>        
        <XdsmViewer mda={this.state}/>
        <h2>Connections</h2>
        <Connections mda={this.state}/>
      </div>
    );
  }
} 

export { Mda };
    