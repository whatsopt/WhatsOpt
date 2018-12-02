import React, {Fragment} from 'react';
import PropTypes from 'prop-types';
import UserSelector from './UserSelector';

class MemberList extends React.Component {
  render() {
    const logins = this.props.members.map((member) => member.login);
    const mbrs = this.props.members;
    const members = logins.map((login, i) => {
      return (<span key={mbrs[i].id} className="btn-group m-1" role="group">
        <button className="btn">{login}</button>
        <button className="btn text-danger" onClick={(e) => this.props.onAnalysisMemberDelete(mbrs[i])}>
          <i className="fa fa-close" />
        </button>
      </span>);
    });

    return (<span className="mb-3">{members}</span> );
  }
}

MemberList.propTypes = {
  members: PropTypes.array.isRequired,
  onAnalysisMemberDelete: PropTypes.func.isRequired,
};

class AnalysisEditor extends React.Component {
  render() {
    let teamMembers = null;
    if (!this.props.analysisPublic) {
      teamMembers = (
        <Fragment>
          <div className="editor-section">
            <span className="form-inline">
              <label>Team Members
                <span className="ml-1 mr-3 badge badge-info">
                  {this.props.analysisMembers.length}
                </span>
              </label>
              <UserSelector
                onMemberSearch={this.props.onAnalysisMemberSearch}
                onMemberSelected={this.props.onAnalysisMemberSelected}
              />
            </span>
          </div>
          <div className="editor-section">
            <MemberList members={this.props.analysisMembers}
              onAnalysisMemberDelete={this.props.onAnalysisMemberDelete} />
          </div>
        </Fragment>);
    }
    return (<div className="container-fluid">
      <div className="editor-section">
        <label htmlFor="name">Name</label>
        <form className="form-inline" onSubmit={this.props.onAnalysisUpdate}>
          <div className="form-group">
            <input type="text" value={this.props.newAnalysisName} className="form-control"
              id="name" onChange={this.props.onAnalysisNameChange}/>
          </div>
          <button type="submit" className="btn btn-primary ml-3">Update</button>
        </form>
      </div>
      <div className="editor-section">
        <form className="form" onSubmit={this.props.onAnalysisUpdate}>
          <div className="form-group form-check">
            <input type="checkbox" className="form-check-input" defaultChecked={!this.props.analysisPublic}
              id="public" onChange={this.props.onAnalysisPublicChange}/>
            <label htmlFor="public" className="form-check-label">Restricted Access</label>
          </div>
        </form>
      </div>
      {teamMembers}
    </div>
    );
  }
};

AnalysisEditor.propTypes = {
  newAnalysisName: PropTypes.string.isRequired,
  analysisPublic: PropTypes.bool.isRequired,
  analysisMembers: PropTypes.array.isRequired,
  onAnalysisUpdate: PropTypes.func.isRequired,
  onAnalysisNameChange: PropTypes.func.isRequired,
  onAnalysisPublicChange: PropTypes.func.isRequired,
  onAnalysisMemberSearch: PropTypes.func.isRequired,
  onAnalysisMemberSelected: PropTypes.func.isRequired,
  onAnalysisMemberDelete: PropTypes.func.isRequired,
};

export default AnalysisEditor;
