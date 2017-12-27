import React from 'react';
import XdsmViewer from 'mda_viewer/components/XdsmViewer'
import Connections from 'mda_viewer/components/Connections'
import ToolBar from 'mda_viewer/components/ToolBar'
import EditionToolBar from 'mda_viewer/components/EditionToolBar'

class MdaViewer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      filter: { fr: undefined, to: undefined },
      isEditing: true,
    }
    this.handleFilterChange = this.handleFilterChange.bind(this);
  }

  handleFilterChange(filter) { 
    this.setState({filter: {fr: filter.fr, to: filter.to}});
  }

  render() {
    if (this.state.isEditing) {
      return(
      <div>
        <div className="mda-section">     
          <XdsmViewer mda={this.props.mda} onFilterChange={this.handleFilterChange}/>
        </div>
        <ul className="nav nav-tabs" id="myTab" role="tablist">
          <li className="nav-item">
            <a className="nav-link active" id="disciplines-tab" data-toggle="tab" href="#disciplines" role="tab" aria-controls="disciplines" aria-selected="true">Disciplines</a>
          </li>
          <li className="nav-item">
            <a className="nav-link" id="connection-tab" data-toggle="tab" href="#connections" role="tab" aria-controls="connections" aria-selected="false">Connections</a>
          </li>
        </ul>
        <div className="tab-content" id="myTabContent">
          <div className="tab-pane fade show active" id="disciplines" role="tabpanel" aria-labelledby="disciplines-tab">...</div>
          <div className="tab-pane fade" id="connections" role="tabpanel" aria-labelledby="connections-tab">...</div>
        </div>
      </div>);      
    };
    return (
      <div>
        <div className="mda-section">
          <ToolBar mda_id={this.props.mda.id} isEditing={this.props.isEditing}/>
        </div>
        <div className="mda-section">      
          <XdsmViewer mda={this.props.mda} onFilterChange={this.handleFilterChange}/>
        </div>
        <div className="mda-section">
          <Connections mda={this.props.mda} filter={this.state.filter} />
        </div>
      </div>
    );
  }
} 

export { MdaViewer };
    