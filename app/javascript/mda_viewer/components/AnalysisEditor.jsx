import React from 'react';
import PropTypes from 'prop-types';

class AnalysisEditor extends React.Component {
    render() {
      return (
            <div className="container-fluid">
               <form className="form" onSubmit={this.props.onAnalysisUpdate}>
                <div className="form-group">
                  <label htmlFor="name">Name</label>
                  <input type="text" value={this.props.newAnalysisName} className="form-control"
                         id="name" onChange={this.props.onAnalysisNameChange}/>
                </div>
                <div className="form-group form-check">
                  <input type="checkbox" className="form-check-input" defaultChecked={this.props.analysisPublic}
                     id="public" onChange={this.props.onAnalysisPublicChange}/>
                  <label htmlFor="public" className="form-check-label">Public</label>
                </div>
                <button type="submit" className="btn btn-primary">Update</button>
              </form>
            </div>
       );
    }
};

AnalysisEditor.propTypes = {
  newAnalysisName: PropTypes.string.isRequired,
  analysisPublic: PropTypes.bool.isRequired,
  onAnalysisUpdate: PropTypes.func.isRequired,
  onAnalysisNameChange: PropTypes.func.isRequired,
  onAnalysisPublicChange: PropTypes.func.isRequired,
};

export default AnalysisEditor;
