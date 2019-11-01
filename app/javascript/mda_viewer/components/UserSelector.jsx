import React from 'react';
import PropTypes from 'prop-types';

import { AsyncTypeahead } from 'react-bootstrap-typeahead';

class UserSelector extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      allowNew: false,
      isLoading: false,
      multiple: false,
      selectHintOnEnter: true,
      options: [],
    };
    this.typeaheadRef = React.createRef();
    this.handleSearch = this.handleSearch.bind(this);
    this.handleChange = this.handleChange.bind(this);
  }

  render() {
    return (
      <AsyncTypeahead
        {...this.state}
        id="typeahead-users"
        labelKey="login"
        minLength={1}
        onSearch={this.handleSearch}
        placeholder="Search for user..."
        onChange={this.handleChange}
        ref={this.typeaheadRef}
      />
    );
  }

  handleSearch(query) {
    this.setState({ isLoading: true });
    this.props.onMemberSearch(query,
      (options) => {
        // const opts = options.map((login, i) => { return { id: i, login: login }; });
        this.setState({ isLoading: false, options: options });
      });
  }

  handleChange(selected) {
    if (selected.length) {
      this.props.onMemberSelected(selected);
      this.typeaheadRef.current.getInstance().clear();
    }
  }
}

UserSelector.propTypes = {
  onMemberSearch: PropTypes.func.isRequired,
  onMemberSelected: PropTypes.func.isRequired,
};

export default UserSelector;
