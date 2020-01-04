import React from 'react';
import PropTypes from 'prop-types';
import MetaModelQualification from '../utils/components/MetaModelQualification';

class MetaModelQualityPlotter extends React.PureComponent {
  render() {
    const { mdaName, quality } = this.props;
    return (
      <div>
        <h1>
          Quality of surrogates of
          {' '}
          {mdaName}
          {' '}
          analysis
        </h1>
        <MetaModelQualification quality={quality} />
      </div>
    );
  }
}

MetaModelQualityPlotter.propTypes = {
  mdaName: PropTypes.string.isRequired,
  quality: PropTypes.array.isRequired,
};

export default MetaModelQualityPlotter;
