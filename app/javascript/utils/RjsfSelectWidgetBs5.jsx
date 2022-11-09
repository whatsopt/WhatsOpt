// copy from https://github.com/rjsf-team/react-jsonschema-form/blob/914f0a1fb1f09794866ec996877e323f789dd499/packages/bootstrap-4/src/SelectWidget/SelectWidget.tsx
// Patch bsPrefix value below from 'custom-select' to 'form-select'

import React from 'react';

import Form from 'react-bootstrap/Form';

import { processSelectValue, WidgetProps } from '@rjsf/utils';

function SelectWidget({
  schema,
  id,
  options,
  required,
  disabled,
  readonly,
  value,
  multiple,
  autofocus,
  onChange,
  onBlur,
  onFocus,
  placeholder,
  rawErrors = [],
}) {
  console.log(value);
  console.log(options);
  const { enumOptions, enumDisabled } = options;

  const emptyValue = multiple ? [] : '';

  function getValue(
    event,
    mult,
  ) {
    if (mult) {
      return [].slice
        .call(event.target.options)
        .filter((o) => o.selected)
        .map((o) => o.value);
    }
    return event.target.value;
  }

  return (
    <Form.Control
      as="select"
      bsPrefix="form-select"
      id={id}
      name={id}
      value={typeof value === 'undefined' ? emptyValue : value}
      required={required}
      multiple={multiple}
      disabled={disabled || readonly}
      autoFocus={autofocus}
      className={rawErrors.length > 0 ? 'is-invalid' : ''}
      onBlur={
                onBlur
                && ((event) => {
                  const newValue = getValue(event, multiple);
                  onBlur(id, processSelectValue(schema, newValue, options));
                })
            }
      onFocus={
                onFocus
                && ((event) => {
                  const newValue = getValue(event, multiple);
                  onFocus(id, processSelectValue(schema, newValue, options));
                })
            }
      onChange={(event) => {
        const newValue = getValue(event, multiple);
        onChange(processSelectValue(schema, newValue, options));
      }}
    >
      {!multiple && schema.default === undefined && (
        <option value="">{placeholder}</option>
      )}
      {(enumOptions).map(({ value: val, label }, i) => {
        const disabl = Array.isArray(enumDisabled)
          && (enumDisabled).indexOf(val) !== -1;
        return (
          // eslint-disable-next-line react/no-array-index-key
          <option key={i} id={label} value={val} disabled={disabl}>
            {label}
          </option>
        );
      })}
    </Form.Control>
  );
}

SelectWidget.propTypes = WidgetProps;

export default SelectWidget;
