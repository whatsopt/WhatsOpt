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
    this.api.getAnalysisCandidates(
      (response) => {
        const options = response.data
          .filter((analysis) => analysis.id !== this.db.getAnalysisId())
          .map((analysis) => ({ id: analysis.id, label: `#${analysis.id} ${analysis.name}` }));
        callback(options);
      },
    );
  }

  handleAnalysisSelected(selected) {
    this.setState({ selected });
  }

  handleExport(disc) {
    const { selected } = this.state;
    const [selection] = selected;

    this.api.importDiscipline(this.db.getAnalysisId(), disc.id, selection.id,
      () => {
        /* global dataConfirmModal */
        dataConfirmModal.confirm({
          title: 'Export done!',
          text: `Discipline ${disc.name} exported to ${selection.label}`,
          commit: `Go to ${selection.label}`,
          commitClass: 'btn-primary',
          cancel: 'Continue',
          cancelClass: 'btn-info',
          onConfirm: () => { window.location.href = this.api.url(`/analyses/${selection.id}`); },
          onCancel: () => { },
        });
      },
      (error) => {
        console.log(error);
        dataConfirmModal.confirm({
          title: 'Oups!',
          text: 'Sorry something went wrong!',
          commit: 'Ok',
          commitClass: 'btn-primary',
          cancelClass: 'd-none',
          onConfirm: () => { },
        });
      });
  }

  render() {
    const mdaId = this.db.getAnalysisId();
    const { selected } = this.state;
    const disabled = (selected.length === 0);

    let disciplineExports = [];
    disciplineExports = this.db.getDisciplines().map((disc) => {
      const label = `Export ${disc.name}`;
      return (
        <div key={disc.id} className="btn-group mr-2" role="group">
          <button
            className="btn btn-primary"
            type="button"
            onClick={() => this.handleExport(disc)}
            disabled={disabled}
          >
            {label}
          </button>
        </div>
      );
    });

    return (
      <div className="container-fluid">
        <div className="editor-section">
          <div className="editor-section-label">Analysis export</div>
          <ToolBar mdaId={mdaId} api={this.api} db={this.db} />
        </div>
        <div className="editor-section">
          <div className="editor-section-label">Discipline export</div>
          <div className="row">
            <div className="col-4">
              <AnalysisSelector
                message="Search an analysis among yours to export to..."
                selected={selected}
                onAnalysisSearch={this.handleAnalysisSearch}
                onAnalysisSelected={this.handleAnalysisSelected}
              />
            </div>
          </div>
          <div className="btn-toolbar mt-2" role="toolbar">
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
