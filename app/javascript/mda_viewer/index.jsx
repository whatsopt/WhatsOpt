import React from 'react';
import XdsmViewer from 'mda_viewer/components/XdsmViewer'
import Connections from 'mda_viewer/components/Connections'

class MdaViewer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      filter: { fr: undefined, to: undefined },
    }
    this.handleFilterChange = this.handleFilterChange.bind(this);
  }

  handleFilterChange(filter) {
    this.setState({filter: {fr: filter.fr, to: filter.to}});
  }

  render() {
    return (
      <div>
        <h2>XDSM</h2>        
        <XdsmViewer mda={this.props.mda} onFilterChange={this.handleFilterChange}/>
        <h2>Connections</h2>
        <Connections mda={this.props.mda} filter={this.state.filter} />
      </div>
    );
  }
} 

export { MdaViewer };
    