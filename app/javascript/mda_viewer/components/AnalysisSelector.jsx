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
    const { message, disabled } = this.props;
    return (
      <AsyncTypeahead
        id="analysis"
        defaultSelected={defaultSelected}
        isLoading={isLoading}
        options={options}
        allowNew={false}
        multiple={false}
        labelKey="label"
        minLength={2}
        onSearch={this.handleSearch}
        placeholder={message}
        onChange={this.handleChange}
        // eslint-disable-next-line react/no-unused-class-component-methods
        ref={(ref) => { this.typeahead = ref; }}
        disabled={disabled}
      />
    );
  }
}

AnalysisSelector.propTypes = {
  message: PropTypes.string.isRequired,
  selected: PropTypes.array.isRequired,
  disabled: PropTypes.bool.isRequired,
  onAnalysisSearch: PropTypes.func.isRequired,
  onAnalysisSelected: PropTypes.func.isRequired,
};

export default AnalysisSelector;
