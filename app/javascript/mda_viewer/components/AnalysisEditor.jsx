/* eslint-disable max-classes-per-file */
import React from 'react';
import PropTypes from 'prop-types';
import UserSelector from './UserSelector';
import ProjectSelector from './ProjectSelector';
import AnalysisNoteEditor from './AnalysisNoteEditor';

class UserList extends React.PureComponent {
  render() {
    const {
      users, userRole, onUserDelete, editEnabled,
    } = this.props;
    const logins = users.map((user) => user.login);

    const userItems = logins.map((login, i) => (
      <span key={users[i].id} className="btn-group m-1" role="group">
        <button type="button" className="btn">{login}</button>
        <button type="button" className="btn text-danger" disabled={!editEnabled} onClick={() => onUserDelete(users[i], userRole)}>
          <i className="fa fa-times" />
        </button>
      </span>
    ));

    return (<span className="mb-3">{userItems}</span>);
  }
}

UserList.propTypes = {
  users: PropTypes.array.isRequired,
  userRole: PropTypes.string.isRequired,
  onUserDelete: PropTypes.func.isRequired,
  editEnabled: PropTypes.bool.isRequired,
};

class TeamSelector extends React.PureComponent {
  render() {
    const {
      users, userRole, onUserSearch, onUserSelected, onUserDelete, editEnabled,
    } = this.props;
    let title = 'Users';
    if (userRole === 'member') {
      title = 'Members';
    }
    if (userRole === 'co_owner') {
      title = 'Co-Owners';
    }
    let userSelector;
    if (editEnabled) {
      userSelector = (
        <UserSelector
          userRole={userRole}
          onUserSearch={onUserSearch}
          onUserSelected={onUserSelected}
        />
      );
    }
    return (
      <>
        <div className="editor-section">
          <span className="d-flex flex-row align-items-center flex-wrap">
            <div>
              { title }
              <span className="ms-1 me-3 badge bg-info">
                {users.length}
              </span>
            </div>
            {userSelector}
          </span>
        </div>
        <div className="editor-section">
          <UserList
            userRole={userRole}
            users={users}
            onUserDelete={onUserDelete}
            editEnabled={editEnabled}
          />
        </div>
      </>
    );
  }
}

TeamSelector.propTypes = {
  users: PropTypes.array.isRequired,
  userRole: PropTypes.string.isRequired,
  onUserSearch: PropTypes.func.isRequired,
  onUserSelected: PropTypes.func.isRequired,
  onUserDelete: PropTypes.func.isRequired,
  editEnabled: PropTypes.bool.isRequired,
};

class AnalysisEditor extends React.PureComponent {
  render() {
    let teamMembers = null;
    const {
      analysisPublic, analysisMembers, analysisCoOwners,
      analysisPermissionsEditable, onAnalysisUserSearch, onAnalysisUserSelected,
      onAnalysisUserDelete, onAnalysisUpdate, newAnalysisName,
      onAnalysisNameChange, onAnalysisNoteChange, onAnalysisPublicChange,
      mdaId, note, onProjectSearch, onProjectSelected, mdaProject,
    } = this.props;
    if (!analysisPublic) {
      teamMembers = (
        <TeamSelector
          users={analysisMembers}
          userRole="member"
          onUserSearch={onAnalysisUserSearch}
          onUserSelected={onAnalysisUserSelected}
          onUserDelete={onAnalysisUserDelete}
          editEnabled={analysisPermissionsEditable}
        />
      );
    }

    const coOwners = (
      <TeamSelector
        users={analysisCoOwners}
        userRole="co_owner"
        onUserSearch={onAnalysisUserSearch}
        onUserSelected={onAnalysisUserSelected}
        onUserDelete={onAnalysisUserDelete}
        editEnabled={analysisPermissionsEditable}
      />
    );

    return (
      <div className="container-fluid">
        <div className="editor-section">
          <div className="editor-section-label">
            <i className="fas fa-info-circle" title="Analysis general informations" />
            {' '}
            General Information
          </div>
          <form onSubmit={onAnalysisUpdate}>
            <div className="mb-3 col-4">
              <div className="editor-section-label">
                Name
              </div>
              <input
                type="text"
                value={newAnalysisName}
                className="form-control"
                id="name"
                onChange={onAnalysisNameChange}
              />
            </div>
            <div className="mb-3 col-4">
              <div className="editor-section-label">
                Design Project
              </div>
              <ProjectSelector
                selected={mdaProject}
                onProjectSearch={onProjectSearch}
                onProjectSelected={onProjectSelected}
              />
            </div>
            <div className="mb-3">
              <div className="editor-section-label">
                Notes
              </div>
              <div className="editor-section-label col-9">
                <AnalysisNoteEditor
                  mdaId={mdaId}
                  note={note}
                  onAnalysisNoteChange={onAnalysisNoteChange}
                />
              </div>
            </div>
            <button type="submit" className="btn btn-primary ms-3">Save</button>
          </form>
        </div>
        <hr />
        <div className="editor-section">
          <div className="editor-section-label">
            <i className="fas fa-users-cog" title="Analysis has co-owners" />
            {' '}
            Collaboration
            {' '}
            <small>(allow edit access to the users listed below)</small>
          </div>
        </div>
        {coOwners}
        <hr />
        <div className="editor-section">
          <div className="editor-section-label">
            <i className="fas fa-user-secret" title="Analysis with restricted access" />
            {' '}
            Privacy
            {' '}
            <small>(when restricted, allow read only access to the users listed below)</small>
          </div>
          <form className="form" onSubmit={onAnalysisUpdate}>
            <div className="mb-3 form-check">
              <label htmlFor="public" className="form-check-label">
                <input
                  type="checkbox"
                  className="form-check-input"
                  defaultChecked={!analysisPublic}
                  id="public"
                  onChange={onAnalysisPublicChange}
                  disabled={!analysisPermissionsEditable}
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
  mdaProject: PropTypes.object.isRequired,
  newAnalysisName: PropTypes.string.isRequired,
  analysisPublic: PropTypes.bool.isRequired,
  analysisPermissionsEditable: PropTypes.bool.isRequired,
  analysisMembers: PropTypes.array.isRequired,
  analysisCoOwners: PropTypes.array.isRequired,
  onAnalysisUpdate: PropTypes.func.isRequired,
  onAnalysisNameChange: PropTypes.func.isRequired,
  onAnalysisNoteChange: PropTypes.func.isRequired,
  onAnalysisPublicChange: PropTypes.func.isRequired,
  onAnalysisUserSearch: PropTypes.func.isRequired,
  onAnalysisUserSelected: PropTypes.func.isRequired,
  onAnalysisUserDelete: PropTypes.func.isRequired,
  onProjectSearch: PropTypes.func.isRequired,
  onProjectSelected: PropTypes.func.isRequired,
};

export default AnalysisEditor;
