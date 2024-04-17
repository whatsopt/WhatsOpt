import React from 'react';
import PropTypes from 'prop-types';
import VariableSelector from './VariableSelector';

function getDiscButtons(api, discs) {
  const buttons = discs.map((disc) => {
    const { name, analysis_id } = disc;
    const label = name === '__DRIVER__' ? 'Driver' : `${disc.name}`;
    return (
      <div key={disc.id} className="btn-group me-2 mt-2" role="group">
        <a href={api.url(`/analyses/${analysis_id}`)} className="btn btn-info" role="button">{label}</a>
      </div>
    );
  });
  return buttons;
}

class VariableDisplay extends React.PureComponent {
  render() {
    const { api, varinfo } = this.props;
    const disciplineFrom = getDiscButtons(api, varinfo.from);
    const disciplineTo = getDiscButtons(api, varinfo.to);

    return (
      <div>
        From:
        <div className="mb-2">
          { disciplineFrom }
        </div>
        To:
        <div className="mb-2">
          { disciplineTo }
        </div>
      </div>
    );
  }
}

VariableDisplay.propTypes = {
  api: PropTypes.object.isRequired,
  varinfo: PropTypes.object.isRequired,
};

class VariableSearchPanel extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: [],
      vars: [],
      varinfo: { from: [], to: [] },
    };
    this.handleVariableSelected = this.handleVariableSelected.bind(this);
  }

  componentDidMount() {
    const { mdaId, api } = this.props;
    api.getVariables(mdaId, (response) => {
      const vars = response.data;
      this.setState({ vars });
    });
  }

  handleVariableSelected(selected) {
    const [selection] = selected;
    const { mdaId, api } = this.props;

    api.getVariableInformation(
      mdaId,
      selection.id,
      (response) => {
        const varinfo = { from: [response.data.from], to: response.data.to };
        this.setState({ varinfo });
      },
      (error) => {
        console.log(error);
      },
    );
  }

  render() {
    const { selected, vars, varinfo } = this.state;
    const { api } = this.props;
    return (
      <div className="container-fluid">
        <div className="row">
          <div className="editor-section col-4">
            <VariableSelector
              vars={vars}
              message="Search variable name..."
              selected={selected}
              onVariableSelected={this.handleVariableSelected}
              disabled={false}
            />
          </div>
          <div className="editor-section col-12">
            <VariableDisplay api={api} varinfo={varinfo} />
          </div>
        </div>
      </div>
    );
  }
}

VariableSearchPanel.propTypes = {
  api: PropTypes.object.isRequired,
  mdaId: PropTypes.number.isRequired,
};

export default VariableSearchPanel;
