/* eslint-disable max-classes-per-file */
import React from 'react';
import PropTypes from 'prop-types';
import MonoObjOptimPlotter from 'optim_viewer/components/MonoObjOptimPlotter';
import MultiObjOptimPlotter from 'optim_viewer/components/MultiObjOptimPlotter';

class OptimViewer extends React.PureComponent {
  render() {
    const { data } = this.props;
    if (data.length === 0) {
      return (
        <div className="alert alert-primary mt-5 mb-5" role="alert">
          No data! Optimization not run yet?
        </div>
      );
    }

    let viewer = <MultiObjOptimPlotter data={data} />;
    if (data[0].config.n_obj === 1) {
      viewer = <MonoObjOptimPlotter data={data} />;
    }

    return (
      <div>
        { viewer }
      </div>
    );
  }
}

OptimViewer.propTypes = {
  data: PropTypes.array.isRequired,
};
export default OptimViewer;
