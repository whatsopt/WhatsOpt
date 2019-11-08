/* eslint-disable max-classes-per-file */
import React from 'react';
import PropTypes from 'prop-types';
import UserSelector from './UserSelector';
import AnalysisNoteEditor from './AnalysisNoteEditor';

class MemberList extends React.PureComponent {
  render() {
    const { members, onAnalysisMemberDelete } = this.props;
    const logins = members.map((member) => member.login);
    const memberItems = logins.map((login, i) => (
      <span key={members[i].id} className="btn-group m-1" role="group">
        <button type="button" className="btn">{login}</button>
        <button type="button" className="btn text-danger" onClick={() => onAnalysisMemberDelete(members[i])}>
          <i className="fa fa-times" />
        </button>
      </span>
    ));

    return (<span className="mb-3">{memberItems}</span>);
  }
}

MemberList.propTypes = {
  members: PropTypes.array.isRequired,
  onAnalysisMemberDelete: PropTypes.func.isRequired,
};

class AnalysisEditor extends React.PureComponent {
  render() {
    let teamMembers = null;
    const {
      analysisPublic, analysisMembers,
      onAnalysisMemberSearch, onAnalysisMemberSelected, onAnalysisMemberDelete, onAnalysisUpdate,
      newAnalysisName, onAnalysisNameChange, onAnalysisNoteChange, onAnalysisPublicChange,
      mdaId, note,
    } = this.props;
    if (!analysisPublic) {
      teamMembers = (
        <>
          <div className="editor-section">
            <span className="form-inline">
              <div>
                Team Members
                <span className="ml-1 mr-3 badge badge-info">
                  {analysisMembers.length}
                </span>
              </div>
              <UserSelector
                onMemberSearch={onAnalysisMemberSearch}
                onMemberSelected={onAnalysisMemberSelected}
              />
            </span>
          </div>
          <div className="editor-section">
            <MemberList
              members={analysisMembers}
              onAnalysisMemberDelete={onAnalysisMemberDelete}
            />
          </div>
        </>
      );
    }

    return (
      <div className="container-fluid">
        <div className="editor-section">
          <div>Information</div>
          <form className="col-6" onSubmit={onAnalysisUpdate}>
            <div className="form-group">
              <label htmlFor="name">
                Name
                <input
                  type="text"
                  value={newAnalysisName}
                  className="form-control"
                  id="name"
                  onChange={onAnalysisNameChange}
                />
              </label>
            </div>
            <div className="form-group">
              <AnalysisNoteEditor
                mdaId={mdaId}
                note={note}
                onAnalysisNoteChange={onAnalysisNoteChange}
              />
            </div>
            <button type="submit" className="btn btn-primary ml-3">Save</button>
          </form>
        </div>
        <div className="editor-section">
          <div>Privacy</div>
          <form className="form" onSubmit={onAnalysisUpdate}>
            <div className="form-group form-check">
              <label htmlFor="public" className="form-check-label">
                <input
                  type="checkbox"
                  className="form-check-input"
                  defaultChecked={!analysisPublic}
                  id="public"
                  onChange={onAnalysisPublicChange}
                />
                Restricted Access
              </label>
            </div>
          </form>
        </div>
        {teamMembers}
      </div>
    );
  }
}

AnalysisEditor.propTypes = {
  note: PropTypes.string.isRequired,
  mdaId: PropTypes.number.isRequired,
  newAnalysisName: PropTypes.string.isRequired,
  analysisPublic: PropTypes.bool.isRequired,
  analysisMembers: PropTypes.array.isRequired,
  onAnalysisUpdate: PropTypes.func.isRequired,
  onAnalysisNameChange: PropTypes.func.isRequired,
  onAnalysisNoteChange: PropTypes.func.isRequired,
  onAnalysisPublicChange: PropTypes.func.isRequired,
  onAnalysisMemberSearch: PropTypes.func.isRequired,
  onAnalysisMemberSelected: PropTypes.func.isRequired,
  onAnalysisMemberDelete: PropTypes.func.isRequired,
};

export default AnalysisEditor;
