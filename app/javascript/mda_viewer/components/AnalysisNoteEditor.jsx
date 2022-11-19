import React from 'react';
import PropTypes from 'prop-types';
// eslint-disable-next-line no-unused-vars
import Trix from 'trix'; // needed so note is displayed correctly

class AnalysisNoteEditor extends React.Component {
  constructor(props) {
    super(props);
    this.trixInput = React.createRef();
  }

  componentDidMount() {
    this.trixInput.current.addEventListener('trix-change', (event) => {
      const { onAnalysisNoteChange } = this.props;
      onAnalysisNoteChange(event); // calling custom event
    });
    this.trixInput.current.addEventListener('trix-file-accept', (event) => {
      event.preventDefault();
    });
  }

  render() {
    const { mdaId, note } = this.props;
    const id = `analysis_note_trix_input_analysis_${mdaId}`;

    // const dataDirectUploadUrl = this.props.api.url("rails/active_storage/direct_uploads");
    // const dataBlobUrlTemplate =
    // this.props.api.url("rails/active_storage/blobs/:signed_id/:filename");
    // const dataDirectUploadUrl = "http://endymion:3000/rails/active_storage/direct_uploads";
    // const dataBlobUrlTemplate = "http://endymion:3000/rails/active_storage/blobs/:signed_id/:filename";
    // data-direct-upload-url={dataDirectUploadUrl}
    // data-blob-url-template={dataBlobUrlTemplate}

    return (
      <div>
        <input type="hidden" name="analysis[note]" id={id} value={note} />
        {/* <textarea name="analysis[note]" id={id} defaultValue={this.props.note} /> */}
        <trix-editor id="analysis_note" input={id} className="form-control trix-content" ref={this.trixInput} />
      </div>
    );
  }
}

AnalysisNoteEditor.propTypes = {
  note: PropTypes.string.isRequired,
  mdaId: PropTypes.number.isRequired,
  onAnalysisNoteChange: PropTypes.func.isRequired,
};

export default AnalysisNoteEditor;
