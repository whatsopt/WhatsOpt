import React from 'react';
import PropTypes from 'prop-types';

class Error extends React.Component {
  render() {
    return (<div className="alert alert-warning" role="alert">
              <a href="#" data-dismiss="alert" className="close">×</a>
              {this.props.msg}
            </div>);
  }
}

Error.propTypes = {
  msg: PropTypes.string.isRequired,
};

export default Error;
