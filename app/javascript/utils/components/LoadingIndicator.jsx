
import React from 'react';
import { usePromiseTracker } from 'react-promise-tracker';

const LoadingIndicator = () => {
  const { promiseInProgress } = usePromiseTracker();

  return (
    promiseInProgress
    && (
    <div className="d-flex justify-content-center text-success mt-2">
      <strong className="mr-2">Loading...</strong>
      <div className="spinner-border text-success" role="status">
        <span className="sr-only">Loading...</span>
      </div>
    </div>
    )
  );
};

export default LoadingIndicator;
