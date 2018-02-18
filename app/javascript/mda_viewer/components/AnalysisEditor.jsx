import React from 'react';

class AnalysisEditor extends React.Component {

    render() {
      return (
            <div className="container-fluid editor-section">
              <label className="editor-header">Name</label>
              <form className="form-inline" onSubmit={this.props.onAnalysisUpdate}>
                <div className="form-group">
                  <label htmlFor="name" className="sr-only">Name</label>
                  <input type="text" value={this.props.newAnalysisName} className="form-control" id="name" onChange={this.props.onAnalysisNameChange}/>
                </div>
                <button type="submit" className="btn btn-primary ml-3">Update</button>
              </form>
            </div>
       );
    }
}

export default AnalysisEditor;