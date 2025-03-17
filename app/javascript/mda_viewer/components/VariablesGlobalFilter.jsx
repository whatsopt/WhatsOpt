import React from 'react';
import PropTypes from 'prop-types';

// Bug related to https://github.com/TanStack/table/issues/3962
// This line is commented replaced by following code copied from react-table
// import { useAsyncDebounce } from 'react-table';

// cf.https://github.com/TanStack/table/issues/3297#issuecomment-935692094
function useGetLatest(obj) {
  const ref = React.useRef();
  ref.current = obj;

  return React.useCallback(() => ref.current, []);
}

export function useAsyncDebounce(defaultFn, defaultWait = 0) {
  const debounceRef = React.useRef({});

  const getDefaultFn = useGetLatest(defaultFn);
  const getDefaultWait = useGetLatest(defaultWait);

  return React.useCallback(
    async (...args) => {
      if (!debounceRef.current.promise) {
        debounceRef.current.promise = new Promise((resolve, reject) => {
          debounceRef.current.resolve = resolve;
          debounceRef.current.reject = reject;
        });
      }

      if (debounceRef.current.timeout) {
        clearTimeout(debounceRef.current.timeout);
      }

      debounceRef.current.timeout = setTimeout(async () => {
        delete debounceRef.current.timeout;
        try {
          debounceRef.current.resolve(await getDefaultFn()(...args));
        } catch (err) {
          debounceRef.current.reject(err);
        } finally {
          delete debounceRef.current.promise;
        }
      }, getDefaultWait());

      return debounceRef.current.promise;
    },
    [getDefaultFn, getDefaultWait],
  );
}

function VariablesGlobalFilter({
  globalFilteredRows,
  globalFilter,
  setGlobalFilter,
}) {
  const matchCount = globalFilteredRows.length;
  const [value, setValue] = React.useState(globalFilter);
  const onChange = useAsyncDebounce((val) => {
    setGlobalFilter(val || undefined);
  }, 200);

  const active = (value !== '');
  return (
    <div className="input-group mb-3">
      <input
        id="filter"
        type="search"
        className="form-control"
        value={value || ''}
        onChange={(e) => {
          setValue(e.target.value);
          onChange(e.target.value);
        }}
        placeholder="Filter..."
      />
      <span className="input-group-text">
        {matchCount}
        {' '}
        Variables
      </span>
    </div>
  );
}

VariablesGlobalFilter.propTypes = {
  globalFilteredRows: PropTypes.array.isRequired,
  globalFilter: PropTypes.string,
  setGlobalFilter: PropTypes.func.isRequired,
};

VariablesGlobalFilter.defaultProps = {
  globalFilter: '',
};

export default VariablesGlobalFilter;
