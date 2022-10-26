import React from 'react';
import PropTypes from 'prop-types';

class DataConfirmModal extends React.PureComponent {
  constructor(props) {
    super(props);

    this.handleCancel = this.handleCancel.bind(this);
    this.handleConfirm = this.handleConfirm.bind(this);
  }

  handleConfirm() {
    const { onConfirm } = this.props;
    onConfirm();
  }

  handleCancel() {
    const { onCancel } = this.props;
    onCancel();
  }

  render() {
    const { id, title, text } = this.props;

    return (
      <div className="modal fade" id={`confirmModal-${id}`} tabIndex="-1" aria-labelledby="confirmModalLabel" aria-hidden="true">
        <div className="modal-dialog">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title" id="confirmModalLabel">{title }</h5>
              <button type="button" className="btn-close" data-bs-dismiss="modal" aria-label="Close" />
            </div>
            <div className="modal-body">
              {text}
            </div>
            <div className="modal-footer">
              <button type="button" className="btn btn-secondary" data-bs-dismiss="modal" onClick={this.handleCancel}>No, cancel</button>
              <button type="button" className="btn btn-danger" data-bs-dismiss="modal" onClick={this.handleConfirm}>Yes</button>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

DataConfirmModal.propTypes = {
  id: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
  onCancel: PropTypes.func.isRequired,
  onConfirm: PropTypes.func.isRequired,
};

export default DataConfirmModal;
