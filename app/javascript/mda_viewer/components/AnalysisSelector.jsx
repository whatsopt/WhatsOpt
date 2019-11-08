import React from 'react';
import PropTypes from 'prop-types';

import { AsyncTypeahead } from 'react-bootstrap-typeahead';

class AnalysisSelector extends React.Component {
  constructor(props) {
    super(props);
    const { selected } = this.props;
    this.state = {
      isLoading: false,
      defaultSelected: selected,
      options: [],
    };
    this.handleSearch = this.handleSearch.bind(this);
    this.handleChange = this.handleChange.bind(this);
  }

  // eslint-disable-next-line no-unused-vars
  handleSearch(query) {
    this.setState({ isLoading: true });
    const { onAnalysisSearch } = this.props;
    onAnalysisSearch(
      // TODO: implement analysis request using the query string
      // query,
      (options) => {
        this.setState({ isLoading: false, options });
      },
    );
  }

  handleChange(selected) {
    if (selected.length) {
      this.setState({ defaultSelected: selected });
      const { onAnalysisSelected } = this.props;
      onAnalysisSelected(selected);
    }
  }

  render() {
    const { defaultSelected, isLoading, options } = this.state;
    return (
      <AsyncTypeahead
        defaultSelected={defaultSelected}
        isLoading={isLoading}
        options={options}
        allowNew={false}
        multiple={false}
        selectHintOnEnter
        labelKey="label"
        minLength={2}
        onSearch={this.handleSearch}
        placeholder="Search for sub-analysis..."
        onChange={this.handleChange}
        ref={(ref) => { this.typeahead = ref; }}
      />
    );
  }
}

AnalysisSelector.propTypes = {
  selected: PropTypes.array.isRequired,
  onAnalysisSearch: PropTypes.func.isRequired,
  onAnalysisSelected: PropTypes.func.isRequired,
};

export default AnalysisSelector;
