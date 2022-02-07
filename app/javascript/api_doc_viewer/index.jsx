import React from 'react';
import PropTypes from 'prop-types';
import SwaggerUI from 'swagger-ui-react';
import 'swagger-ui-react/swagger-ui.css';

class SwaggerApiDoc extends React.Component {
  constructor(props) {
    super(props);

    this.preAuthorize = this.preAuthorize.bind(this);
    this.ref = React.createRef();
  }

  preAuthorize() {
    const { api } = this.props;
    if (api.apiKey) {
      this.ref.current.system.preauthorizeApiKey('Token', `Token ${api.apiKey}`);
    }
  }

  render() {
    const { api } = this.props;
    return (
      <SwaggerUI
        ref={this.ref}
        url={api.docUrl()}
        onComplete={this.preAuthorize}
        docExpansion="list"
      />
    );
  }
}

SwaggerApiDoc.propTypes = {
  api: PropTypes.object.isRequired,
};

export default SwaggerApiDoc;
