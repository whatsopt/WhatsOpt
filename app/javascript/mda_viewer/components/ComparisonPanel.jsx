import React from 'react';
import PropTypes from 'prop-types';
import { Diff2HtmlUI } from 'diff2html/lib/ui/js/diff2html-ui';
import AnalysisSelector from './AnalysisSelector';

class ComparisonDisplay extends React.PureComponent {
  componentDidMount() {
    const { diff } = this.props;
    this.updateDiff(diff);
  }

  componentDidUpdate(prevProps) {
    const { diff } = this.props;
    if (prevProps.diff !== diff) {
      this.updateDiff(diff);
    }
  }

  updateDiff(diff) {
    const targetElement = this.el;
    const configuration = {
      drawFileList: false,
      fileListStartVisible: false,
      matching: 'lines',
      highlight: true,
      outputFormat: 'side-by-side',
    };
    const diff2htmlUi = new Diff2HtmlUI(targetElement, diff, configuration);
    diff2htmlUi.draw();
    diff2htmlUi.highlightCode();
  }

  render() {
    return (<div id="myDiffElement" ref={(el) => this.el = el} />);
  }
}

ComparisonDisplay.propTypes = {
  diff: PropTypes.string.isRequired,
};

class ComparisonPanel extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: [],
      diff: '',
    };
    const { api, mdaId } = this.props;
    this.api = api;
    this.mdaId = mdaId;
    this.handleAnalysisSearch = this.handleAnalysisSearch.bind(this);
    this.handleAnalysisSelected = this.handleAnalysisSelected.bind(this);
  }

  handleAnalysisSearch(callback) {
    this.api.getAnalysisCandidates(
      (response) => {
        const options = response.data
          .filter((analysis) => analysis.id !== this.mdaId)
          .map((analysis) => ({ id: analysis.id, label: `#${analysis.id} ${analysis.name}` }));
        callback(options);
      }, 'all',
    );
  }

  handleAnalysisSelected(selected) {
    const [selection] = selected;
    const { mdaId } = this.props;
    this.api.compareAnalyses(mdaId, selection.id,
      (response) => {
        const diff = response.data;
        this.setState({ diff });
      },
      (error) => {
        console.log(error);
      });
  }

  render() {
    const { selected, diff } = this.state;
    return (
      <div className="container-fluid">
        <div className="row">
          <div className="editor-section col-4">
            <AnalysisSelector
              message="Search an analysis to compare to..."
              selected={selected}
              onAnalysisSearch={this.handleAnalysisSearch}
              onAnalysisSelected={this.handleAnalysisSelected}
            />
          </div>
          <div className="editor-section col-12">
            <ComparisonDisplay diff={diff} />
          </div>
        </div>
      </div>
    );
  }
}

ComparisonPanel.propTypes = {
  api: PropTypes.object.isRequired,
  mdaId: PropTypes.number.isRequired,
};

export default ComparisonPanel;
