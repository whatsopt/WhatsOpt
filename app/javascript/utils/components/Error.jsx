import React from 'react';
import PropTypes from 'prop-types';

class Error extends React.PureComponent {
  render() {
    const { msg, onClose } = this.props;
    return (
      <div className="alert alert-warning" role="alert">
        <button type="button" className="btn-close" href="#" onClick={onClose} />
        {msg}
      </div>
    );
  }
}

Error.propTypes = {
  onClose: PropTypes.func.isRequired,
  msg: PropTypes.string.isRequired,
};

export default Error;
