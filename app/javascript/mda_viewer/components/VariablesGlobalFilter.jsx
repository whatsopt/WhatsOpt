import React from 'react';
import PropTypes from 'prop-types';
import 'core-js/stable';
import 'regenerator-runtime/runtime';
import { useAsyncDebounce } from 'react-table';

function VariablesGlobalFilter({
  preGlobalFilteredRows,
  globalFilter,
  setGlobalFilter,
}) {
  const count = preGlobalFilteredRows.length;
  const [value, setValue] = React.useState(globalFilter);
  const onChange = useAsyncDebounce((val) => {
    setGlobalFilter(val || undefined);
  }, 200);

  return (
    <input
      id="filter"
      className="form-control"
      value={value || ''}
      onChange={(e) => {
        setValue(e.target.value);
        onChange(e.target.value);
      }}
      placeholder={`Filter ${count} variables...`}
      style={{ width: '100%' }}
    />
  );
}

VariablesGlobalFilter.propTypes = {
  preGlobalFilteredRows: PropTypes.array.isRequired,
  globalFilter: PropTypes.string,
  setGlobalFilter: PropTypes.func.isRequired,
};

VariablesGlobalFilter.defaultProps = {
  globalFilter: '',
};

export default VariablesGlobalFilter;
