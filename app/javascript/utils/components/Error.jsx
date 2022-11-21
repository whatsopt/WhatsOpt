import React from 'react';
import PropTypes from 'prop-types';

class Error extends React.PureComponent {
  render() {
    const { msg, onClose } = this.props;
    return (
      <div className="alert alert-warning alert-dismissible fade show" role="alert">
        {msg}
        <button type="button" className="btn-close" data-bs-dismiss="alert" aria-label="Close" onClick={onClose} />
      </div>
    );
  }
}

Error.propTypes = {
  onClose: PropTypes.func.isRequired,
  msg: PropTypes.string.isRequired,
};

export default Error;
