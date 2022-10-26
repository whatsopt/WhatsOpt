import React from 'react';
import PropTypes from 'prop-types';
import AnalysisSelector from './AnalysisSelector';

class ImportSection extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: [],
      disciplines: [],
    };
    const { api, mdaId } = this.props;
    this.api = api;
    this.mdaId = mdaId;
    this.handleAnalysisSearch = this.handleAnalysisSearch.bind(this);
    this.handleAnalysisSelected = this.handleAnalysisSelected.bind(this);
    this.handleImport = this.handleImport.bind(this);
  }

  handleAnalysisSearch(callback) {
    this.api.getAnalysisCandidates(
      (response) => {
        const options = response.data
          .filter((analysis) => analysis.id !== this.mdaId)
          .map((analysis) => ({ id: analysis.id, label: `#${analysis.id} ${analysis.name}` }));
        callback(options);
      },
      'all', // search all analyses not only mine
    );
  }

  handleAnalysisSelected(selected) {
    const [selection] = selected;
    this.api.getDisciplines(selection.id,
      (response) => {
        console.log(response.data);
        const disciplines = response.data;
        this.setState({ selected, disciplines });
      });
  }

  handleImport(discId) {
    const { onDisciplineImport, mdaId } = this.props;
    const { selected } = this.state;
    const [selection] = selected;
    onDisciplineImport(selection.id, discId, mdaId);
  }

  render() {
    const { selected, disciplines } = this.state;

    const disciplineImports = disciplines.map((disc) => {
      const label = `Import ${disc.name}`;
      return (
        <div key={disc.id} className="btn-group me-2" role="group">
          <button
            className="btn btn-primary"
            type="button"
            onClick={() => this.handleImport(disc.id)}
          >
            {label}
          </button>
        </div>
      );
    });

    return (
      <div className="editor-section">
        <div className="editor-section-label">Import discipline from another analysis</div>
        <div className="row">
          <div className="col-4">
            <AnalysisSelector
              message="Search an analysis to import from..."
              selected={selected}
              onAnalysisSearch={this.handleAnalysisSearch}
              onAnalysisSelected={this.handleAnalysisSelected}
            />
          </div>
        </div>
        <div className="btn-toolbar mt-2" role="toolbar">
          {disciplineImports}
        </div>
      </div>
    );
  }
}

ImportSection.propTypes = {
  api: PropTypes.object.isRequired,
  mdaId: PropTypes.number.isRequired,
  onDisciplineImport: PropTypes.func.isRequired,
};

export default ImportSection;
