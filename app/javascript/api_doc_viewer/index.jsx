import React from 'react';
import PropTypes from 'prop-types';
import SwaggerUI from 'swagger-ui-react';
import 'swagger-ui-react/swagger-ui.css';

function MySwaggerUI(props) {
  const { url, preAuthorize } = props;
  return (
    <SwaggerUI
      url={url}
      onComplete={preAuthorize}
      docExpansion="list"
    />
  );
}

MySwaggerUI.propTypes = {
  url: PropTypes.string.isRequired,
  preAuthorize: PropTypes.func.isRequired,
};

function SwaggerApiDoc({ api }) {
  function preAuthorize(sui) {
    if (api.apiKey) {
      sui.getSystem().preauthorizeApiKey('Token', `Token ${api.apiKey}`);
    }
  }

  return (
    <MySwaggerUI
      url={api.docUrl()}
      preAuthorize={(sui) => preAuthorize(sui)}
    />
  );
}

SwaggerApiDoc.propTypes = {
  api: PropTypes.object.isRequired,
};

export default SwaggerApiDoc;
