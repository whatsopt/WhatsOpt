
import React from 'react';
import { usePromiseTracker } from 'react-promise-tracker';

const LoadingIndicator = () => {
  const { promiseInProgress } = usePromiseTracker();

  return (
    promiseInProgress
    && <h1>Hey some async call in progress ! </h1>
  );
};

export default LoadingIndicator;
