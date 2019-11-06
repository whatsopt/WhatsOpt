import React from 'react';
import PropTypes from 'prop-types';
import SwaggerUI from 'swagger-ui-react';

class SwaggerApiDoc extends React.Component {
  constructor(props) {
    super(props);

    this.preAuthorize = this.preAuthorize.bind(this);
    this.ref = React.createRef();
  }

  preAuthorize() {
    if (this.props.api.apiKey) {
      this.ref.current.system.preauthorizeApiKey('Token', `Token ${this.props.api.apiKey}`);
    }
  }

  render() {
    return (
      <SwaggerUI
        ref={this.ref}
        url={this.props.api.apiUrl('/api_doc')}
        onComplete={this.preAuthorize}
      />
    );
  }
}

SwaggerApiDoc.propTypes = {
  api: PropTypes.object.isRequired,
};

export default SwaggerApiDoc;
