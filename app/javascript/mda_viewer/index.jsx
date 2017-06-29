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
        <XdsmViewer mda={this.state}/>
        <Connections mda={this.state}/>
      </div>
    );
  }
} 

export { Mda };
    