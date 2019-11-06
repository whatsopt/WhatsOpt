import React from 'react';
import PropTypes from 'prop-types';

function CheckboxWidget(props) {
  const {
    id,
    value,
    required,
    disabled,
    readonly,
    label,
    autofocus,
    onChange,
    rawErrors,
  } = props;

  const classes = ['form-check-input'];
  if (rawErrors && rawErrors.length > 0) {
    classes.push('is-invalid');
  }

  if (disabled || readonly) {
    classes.push('disabled');
  }

  const newLabel = props.schema.title ? props.schema.title : label;

  return (
    <div className="form-check">
      <input
        className={classes.join(' ')}
        type="checkbox"
        id={id}
        checked={typeof value === 'undefined' ? false : value}
        required={required}
        disabled={disabled || readonly}
        // eslint-disable-next-line jsx-a11y/no-autofocus
        autoFocus={autofocus}
        onChange={(event) => onChange(event.target.checked)}
      />
      <label className="form-check-label" htmlFor={id}>
        {newLabel}
      </label>
    </div>
  );
}

CheckboxWidget.defaultProps = {
  autofocus: false,
  rawErrors: [],
};

CheckboxWidget.propTypes = {
  schema: PropTypes.object.isRequired,
  id: PropTypes.string.isRequired,
  value: PropTypes.bool.isRequired,
  required: PropTypes.bool.isRequired,
  disabled: PropTypes.bool.isRequired,
  label: PropTypes.string.isRequired,
  rawErrors: PropTypes.arrayOf(PropTypes.string),
  readonly: PropTypes.bool.isRequired,
  autofocus: PropTypes.bool,
  onChange: PropTypes.func.isRequired,
};

export default CheckboxWidget;
