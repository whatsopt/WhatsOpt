import React from 'react';
import PropTypes from 'prop-types';

import { Typeahead } from 'react-bootstrap-typeahead';

class VariableSelector extends React.Component {
  constructor(props) {
    super(props);
    const { selected } = this.props;
    this.state = {
      defaultSelected: selected,
    };
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(selected) {
    if (selected.length) {
      this.setState({ defaultSelected: selected });
      const { onVariableSelected } = this.props;
      onVariableSelected(selected);
    }
  }

  render() {
    const { defaultSelected } = this.state;
    const { message, disabled, vars: options } = this.props;
    return (
      <Typeahead
        id="varsearch"
        defaultSelected={defaultSelected}
        options={options}
        allowNew={false}
        multiple={false}
        labelKey="name"
        minLength={1}
        placeholder={message}
        onChange={this.handleChange}
        // eslint-disable-next-line react/no-unused-class-component-methods
        ref={(ref) => { this.typeahead = ref; }}
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
