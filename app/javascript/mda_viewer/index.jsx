import React from 'react';
import XdsmViewer from 'mda_viewer/components/XdsmViewer'
import Connections from 'mda_viewer/components/Connections'
import ToolBar from 'mda_viewer/components/ToolBar'

class MdaViewer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      filter: { fr: undefined, to: undefined },
      openmdao_check: null,
    }
    this.handleFilterChange = this.handleFilterChange.bind(this);
  }

  handleFilterChange(filter) {
    this.setState({filter: {fr: filter.fr, to: filter.to}});
  }

  render() {
    return (
      <div>
      <div className="mda-section">
        <ToolBar mda_id={this.props.mda.id} />
      </div>
      <div className="mda-section">
        <h2>XDSM</h2>        
        <XdsmViewer mda={this.props.mda} onFilterChange={this.handleFilterChange}/>
      </div>
      <div className="mda-section">
        <h2>Connections</h2>
        <Connections mda={this.props.mda} filter={this.state.filter} />
      </div>
      </div>
    );
  }
} 

export { MdaViewer };
    