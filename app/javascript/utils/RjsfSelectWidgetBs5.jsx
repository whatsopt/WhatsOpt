// copy from https://github.com/rjsf-team/react-jsonschema-form/blob/914f0a1fb1f09794866ec996877e323f789dd499/packages/bootstrap-4/src/SelectWidget/SelectWidget.tsx
// Patch bsPrefix value below from 'custom-select' to 'form-select'

import React from "react";
import Form from "react-bootstrap/Form";
import {
  ariaDescribedByIds,
  FormContextType,
  enumOptionsIndexForValue,
  enumOptionsValueForIndex,
  RJSFSchema,
  StrictRJSFSchema,
  WidgetProps,
} from "@rjsf/utils";

export default function SelectWidget({
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
  const { enumOptions, enumDisabled, emptyValue: optEmptyValue } = options;

  const emptyValue = multiple ? [] : "";

  function getValue(
    event,
    multiple
  ) {
    if (multiple) {
      return [].slice
        .call(event.target.options)
        .filter((o) => o.selected)
        .map((o) => o.value);
    } else {
      return event.target.value;
    }
  }
  const selectedIndexes = enumOptionsIndexForValue(
    value,
    enumOptions,
    multiple
  );

  return (
    <Form.Control
      as="select"
      bsPrefix="form-select"
      id={id}
      name={id}
      value={
        typeof selectedIndexes === "undefined" ? emptyValue : selectedIndexes
      }
      required={required}
      multiple={multiple}
      disabled={disabled || readonly}
      autoFocus={autofocus}
      className={rawErrors.length > 0 ? "is-invalid" : ""}
      onBlur={
        onBlur &&
        ((event) => {
          const newValue = getValue(event, multiple);
          onBlur(
            id,
            enumOptionsValueForIndex(newValue, enumOptions, optEmptyValue)
          );
        })
      }
      onFocus={
        onFocus &&
        ((event) => {
          const newValue = getValue(event, multiple);
          onFocus(
            id,
            enumOptionsValueForIndex(newValue, enumOptions, optEmptyValue)
          );
        })
      }
      onChange={(event) => {
        const newValue = getValue(event, multiple);
        onChange(
          enumOptionsValueForIndex(newValue, enumOptions, optEmptyValue)
        );
      }}
      aria-describedby={ariaDescribedByIds(id)}
    >
      {!multiple && schema.default === undefined && (
        <option value="">{placeholder}</option>
      )}
      {(enumOptions).map(({ value, label }, i) => {
        const disabled =
          Array.isArray(enumDisabled) &&
          (enumDisabled).indexOf(value) != -1;
        return (
          <option key={i} id={label} value={String(i)} disabled={disabled}>
            {label}
          </option>
        );
      })}
    </Form.Control>
  );
}
