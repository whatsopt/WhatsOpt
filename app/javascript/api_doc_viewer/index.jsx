import React from 'react';
import PropTypes from 'prop-types';
import SwaggerUI from 'swagger-ui-react'

class SwaggerApiDoc extends React.Component {

  render() {
    return (<SwaggerUI url={this.props.api.apiUrl("/api_doc")} />);
  }
}

SwaggerApiDoc.propTypes = {
  api: PropTypes.object.isRequired,
};

export default SwaggerApiDoc;