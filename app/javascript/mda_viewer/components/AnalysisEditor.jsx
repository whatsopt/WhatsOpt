import React from 'react';
import PropTypes from 'prop-types';

class AnalysisEditor extends React.Component {
    render() {
      return (
            <div className="container-fluid editor-section">
              <label className="editor-header">Name</label>
              <form className="form-inline" onSubmit={this.props.onAnalysisUpdate}>
                <div className="form-group">
                  <label htmlFor="name" className="sr-only">Name</label>
                  <input type="text" value={this.props.newAnalysisName} className="form-control"
                         id="name" onChange={this.props.onAnalysisNameChange}/>
                </div>
                <button type="submit" className="btn btn-primary ml-3">Update</button>
              </form>
            </div>
       );
    }
};

AnalysisEditor.propTypes = {
  onAnalysisUpdate: PropTypes.func.isRequired,
  newAnalysisName: PropTypes.string.isRequired,
  onAnalysisNameChange: PropTypes.func.isRequired,
};

export default AnalysisEditor;
