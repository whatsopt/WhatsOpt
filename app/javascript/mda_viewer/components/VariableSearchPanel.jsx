import React from 'react';
import PropTypes from 'prop-types';
import VariableSelector from './VariableSelector';

class VariableDisplay extends React.PureComponent {
  render() {
    return (<div />);
  }
}

VariableDisplay.propTypes = {

};

class VariableSearchPanel extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: [],
      vars: [],
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
    const { mdaId } = this.props;

    console.log('Trigger variable search API call');
    // this.api.compareAnalyses(
    //   mdaId,
    //   selection.id,
    //   (response) => {
    //     const diff = response.data;
    //     this.setState({ diff });
    //   },
    //   (error) => {
    //     console.log(error);
    //   },
    // );
  }

  render() {
    const { selected, vars } = this.state;
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
            <VariableDisplay />
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
