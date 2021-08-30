import React from 'react';
import PropTypes from 'prop-types';

import { AsyncTypeahead } from 'react-bootstrap-typeahead';

class UserSelector extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      isLoading: false,
      options: [],
    };
    this.typeaheadRef = React.createRef();
    this.handleSearch = this.handleSearch.bind(this);
    this.handleChange = this.handleChange.bind(this);
  }

  handleSearch(query) {
    this.setState({ isLoading: true });
    const { onUserSearch, userRole } = this.props;
    onUserSearch(query, userRole, (options) => {
      // const opts = options.map((login, i) => { return { id: i, login: login }; });
      this.setState({ isLoading: false, options });
    });
  }

  handleChange(selected) {
    if (selected.length) {
      const { onUserSelected, userRole } = this.props;
      onUserSelected(selected, userRole);
      this.typeaheadRef.current.clear();
    }
  }

  render() {
    const { isLoading, options } = this.state;
    return (
      <AsyncTypeahead
        allowNew={false}
        isLoading={isLoading}
        multiple={false}
        options={options}
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
}

UserSelector.propTypes = {
  userRole: PropTypes.string.isRequired,
  onUserSearch: PropTypes.func.isRequired,
  onUserSelected: PropTypes.func.isRequired,
};

export default UserSelector;
