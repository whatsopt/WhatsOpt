/* eslint-disable react/require-default-props */
import React from 'react';
import PropTypes from 'prop-types';

function RadioWidget(props) {
  const {
    id,
    options,
    value,
    required,
    disabled,
    readonly,
    autofocus,
    onChange,
  } = props;
  // Generating a unique field name to identify this set of radio buttons
  const { enumOptions, inline } = options;
  // checked={checked} has been moved above name={name}, As mentioned in #349;
  // this is a temporary fix for radio button rendering bug in React, facebook/react#7630.
  return (
    <div className="field-radios" id={id}>
      {enumOptions.map((option, i) => {
        const checked = option.value === value;
        const disabledCls = disabled || readonly ? 'disabled' : '';
        const radio = (
          <input
            className="form-check-input"
            type="radio"
            checked={checked}
            id={`${id}_${i}`}
            name={id}
            required={required}
            value={option.value}
            disabled={disabled || readonly}
            // eslint-disable-next-line jsx-a11y/no-autofocus
            autoFocus={autofocus && i === 0}
            onChange={(_) => onChange(option.value)}
          />
        );

        return (
          <div
            key={i}
            className={`form-check ${
              inline ? 'form-check-inline' : ''
            } ${disabledCls}`}
          >
            {radio}
            <label className="form-check-label" htmlFor={`${id}_${i}`}>
              {option.label}
            </label>
          </div>
        );
      })}
    </div>
  );
}

RadioWidget.defaultProps = {
  autofocus: false,
};

if (process.env.NODE_ENV !== 'production') {
  RadioWidget.propTypes = {
    id: PropTypes.string.isRequired,
    options: PropTypes.shape({
      enumOptions: PropTypes.array,
      inline: PropTypes.bool,
    }).isRequired,
    value: PropTypes.any,
    required: PropTypes.bool,
    disabled: PropTypes.bool,
    readonly: PropTypes.bool,
    autofocus: PropTypes.bool,
    onChange: PropTypes.func,
  };
}
export default RadioWidget;
