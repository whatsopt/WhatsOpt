import React from 'react';
import PropTypes from 'prop-types';

import { AsyncTypeahead } from 'react-bootstrap-typeahead';

class ProjectSelector extends React.Component {
  constructor(props) {
    super(props);
    const { selected } = this.props;
    this.state = {
      isLoading: false,
      options: [selected],
    };
    this.typeaheadRef = React.createRef();
    this.handleSearch = this.handleSearch.bind(this);
    this.handleChange = this.handleChange.bind(this);
  }

  handleSearch() {
    this.setState({ isLoading: true });
    const { onProjectSearch } = this.props;
    onProjectSearch((options) => {
      this.setState({ isLoading: false, options });
    });
  }

  handleChange(selected) {
    const { onProjectSelected } = this.props;
    onProjectSelected(selected);
  }

  render() {
    const { selected } = this.props;
    const { isLoading, options } = this.state;
    return (
      <AsyncTypeahead
        clearButton
        defaultSelected={[selected]}
        isLoading={isLoading}
        multiple={false}
        options={options}
        id="typeahead-projects"
        labelKey="name"
        minLength={1}
        onSearch={this.handleSearch}
        placeholder="Search for design project, otherwise none is fine."
        onChange={this.handleChange}
      />
    );
  }
}

ProjectSelector.propTypes = {
  selected: PropTypes.object.isRequired,
  onProjectSearch: PropTypes.func.isRequired,
  onProjectSelected: PropTypes.func.isRequired,
};

export default ProjectSelector;
