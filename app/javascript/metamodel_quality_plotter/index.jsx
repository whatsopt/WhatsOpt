import React from 'react';
import PropTypes from 'prop-types';
import MetaModelQualification from '../utils/components/MetaModelQualification';
import LoadingIndicator from '../utils/components/LoadingIndicator';

class MetaModelQualityPlotter extends React.Component {
  constructor(props) {
    super(props);

    this.state = { quality: [] };
  }

  componentDidMount() {
    const { metaModelId, api } = this.props;

    api.getMetaModelPredictionQuality(metaModelId,
      ({ data }) => {
        this.setState({ quality: data });
      },
      (error) => console.log(error));
  }

  render() {
    const { mdaName } = this.props;
    const { quality } = this.state;
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
        <LoadingIndicator />
      </div>
    );
  }
}

MetaModelQualityPlotter.propTypes = {
  api: PropTypes.object.isRequired,
  mdaName: PropTypes.string.isRequired,
  metaModelId: PropTypes.number.isRequired,
};

export default MetaModelQualityPlotter;
