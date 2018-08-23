import React, {Fragment} from 'react';
import PropTypes from 'prop-types';

import {AsyncTypeahead} from 'react-bootstrap-typeahead';

class UserSelector extends React.Component {
    
  constructor(props) {
    super(props);
    this.state = { allowNew: false,
                   isLoading: false,
                   multiple: false,
                   selectHintOnEnter: false,
                   options: [],
                 };
    this.handleSearch = this.handleSearch.bind(this);
    this.handleChange = this.handleChange.bind(this);
  }
  
  render() {
    return (
        <div className="form-inline">
        <AsyncTypeahead
            {...this.state}
            labelKey="login"
            minLength={3}
            onSearch={this.handleSearch}
            placeholder="Search for user..."
            onChange={this.props.onMemberSelected}
         />
        </div>
    );
  }
  
  handleSearch(query) {
    this.setState({isLoading: true});
    this.props.onMemberSearch(query, 
      (options) => {
         console.log(JSON.stringify(options));
         this.setState({isLoading: false, options: options, });
      })
  }
  
  handleChange(selected) {
    if (selected.length) {
      this.props.onMemberSelected(selected);  
      this.typeahead.getInstance().clear();
    }
  }
}

UserSelector.propTypes = {
  onMemberSearch: PropTypes.func.isRequired,
  onMemberSelected: PropTypes.func.isRequired,
};

export default UserSelector;