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
    const { onMemberSearch } = this.props;
    onMemberSearch(query, (options) => {
      // const opts = options.map((login, i) => { return { id: i, login: login }; });
      this.setState({ isLoading: false, options });
    });
  }

  handleChange(selected) {
    if (selected.length) {
      const { onMemberSelected } = this.props;
      onMemberSelected(selected);
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
  onMemberSearch: PropTypes.func.isRequired,
  onMemberSelected: PropTypes.func.isRequired,
};

export default UserSelector;
