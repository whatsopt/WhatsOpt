import React from 'react';
import PropTypes from 'prop-types';

import {AsyncTypeahead} from 'react-bootstrap-typeahead';

class AnalysisSelector extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      defaultSelected: this.props.selected,
      allowNew: false,
      isLoading: false,
      multiple: false,
      selectHintOnEnter: true,
      options: [],
    };
    this.handleSearch = this.handleSearch.bind(this);
    this.handleChange = this.handleChange.bind(this);
  }

  render() {
    return (
      <AsyncTypeahead
        {...this.state}
        labelKey="label"
        minLength={2}
        onSearch={this.handleSearch}
        placeholder="Search for sub-analysis..."
        onChange={this.handleChange}
        ref={(ref) => this.typeahead = ref}
      />
    );
  }

  handleSearch(query) {
    this.setState({isLoading: true});
    this.props.onAnalysisSearch(
        // TODO: implement analysis request using the query string
        // query,
        (options) => {
          this.setState({isLoading: false, options: options});
        });
  }

  handleChange(selected) {
    if (selected.length) {
      this.setState({selected, defaultSelected: selected});
      this.props.onAnalysisSelected(selected);
      // this.typeahead.getInstance().clear();
    }
  }
}

AnalysisSelector.propTypes = {
  selected: PropTypes.array,
  onAnalysisSearch: PropTypes.func.isRequired,
  onAnalysisSelected: PropTypes.func.isRequired,
};

export default AnalysisSelector;
