import React from 'react';
import PropTypes from 'prop-types';
import ToolBar from './ToolBar';
import AnalysisSelector from './AnalysisSelector';

class ExportPanel extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: [],
    };
    const { api, db } = this.props;
    this.api = api;
    this.db = db;
    this.handleAnalysisSearch = this.handleAnalysisSearch.bind(this);
    this.handleAnalysisSelected = this.handleAnalysisSelected.bind(this);
  }

  handleAnalysisSearch(callback) {
    this.api.getAnalysisToExportTo(
      (response) => {
        const options = response.data
          .filter((analysis) => analysis.id !== this.db.getAnalysisId())
          .map((analysis) => ({ id: analysis.id, label: `#${analysis.id} ${analysis.name}` }));
        callback(options);
      },
    );
  }

  handleAnalysisSelected(selected) {
    console.log(`Select ${JSON.stringify(selected)}`);
    this.setState({ selected });
  }

  handleExport(discId) {
    const { selected } = this.state;
    const [selection] = selected;
    this.api.importDiscipline(this.db.getAnalysisId(), discId, selection.id);
  }

  render() {
    const mdaId = this.db.getAnalysisId();

    let disciplineExports = [];
    console.log(this.db.getDisciplines());
    disciplineExports = this.db.getDisciplines().map((disc) => {
      const label = `Export ${disc.name}`;
      return (
        <div key={disc.id} className="btn-group mr-2" role="group">
          <button
            className="btn btn-primary"
            type="button"
            onClick={() => this.handleExport(disc.id)}
          >
            {label}
          </button>
        </div>
      );
    });

    const { selected } = this.state;

    return (
      <div className="container-fluid">
        <div className="editor-section">
          <div>Analysis</div>
          <ToolBar mdaId={mdaId} api={this.api} db={this.db} />
        </div>
        <div className="editor-section">
          <div>Disciplines</div>
          <AnalysisSelector
            message="Search analysis to export to..."
            selected={selected}
            onAnalysisSearch={this.handleAnalysisSearch}
            onAnalysisSelected={this.handleAnalysisSelected}
          />
          <div className="btn-toolbar" role="toolbar">
            {disciplineExports}
          </div>
        </div>
      </div>
    );
  }
}

ExportPanel.propTypes = {
  api: PropTypes.object.isRequired,
  db: PropTypes.object.isRequired,
};

export default ExportPanel;
