import React from 'react';
import PropTypes from 'prop-types';

import { Typeahead } from 'react-bootstrap-typeahead';

class VariableSelector extends React.Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(selected) {
    if (selected.length) {
      const { onVariableSelected } = this.props;
      onVariableSelected(selected);
    }
  }

  render() {
    const {
      message, selected, disabled, vars: options,
    } = this.props;
    return (
      <Typeahead
        id="varsearch"
        defaultSelected={selected}
        clearButton
        options={options}
        allowNew={false}
        multiple={false}
        labelKey="name"
        minLength={1}
        placeholder={message}
        onChange={this.handleChange}
        disabled={disabled}
      />
    );
  }
}

VariableSelector.propTypes = {
  vars: PropTypes.array.isRequired,
  message: PropTypes.string.isRequired,
  selected: PropTypes.array.isRequired,
  disabled: PropTypes.bool.isRequired,
  onVariableSelected: PropTypes.func.isRequired,
};

export default VariableSelector;
