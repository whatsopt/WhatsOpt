import React from 'react';
import PropTypes from 'prop-types';

class Error extends React.Component {
  render() {
    return (<div className="alert alert-warning" role="alert">
              <button type="button" className="close" href="#" onClick={this.props.onClose}>×</button>
              {this.props.msg}
            </div>);
  }
}

Error.propTypes = {
  msg: PropTypes.string.isRequired,
};

export default Error;
