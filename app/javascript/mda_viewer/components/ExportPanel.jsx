import React from 'react';
import PropTypes from 'prop-types';
import ToolBar from 'mda_viewer/components/ToolBar';

class ExportPanel extends React.PureComponent {
  render() {
    const { mdaId, api, db } = this.props;
    return (
      <div className="container-fluid">
        <div className="editor-section">
          <div>Analysis</div>
          <ToolBar mdaId={mdaId} api={api} db={db} />
        </div>
        <div className="editor-section">
          <div>Disciplines</div>
        </div>
      </div>
      );
  }
} 

ExportPanel.propTypes = {
  mdaId: PropTypes.number.isRequired,
  api: PropTypes.object.isRequired,
  db: PropTypes.object.isRequired
};

export default ExportPanel;