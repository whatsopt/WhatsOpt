import React from 'react';
import PropTypes from 'prop-types';
import Trix from 'trix';

class AnalysisNoteEditor extends React.Component {
  constructor(props) {
    super(props);
    this.trixInput = React.createRef();
  } 

  componentDidMount() {
    this.trixInput.current.addEventListener("trix-change", event => {
      this.props.onAnalysisNoteChange(event); //calling custom event
    });
    this.trixInput.current.addEventListener("trix-file-accept", event => {
      event.preventDefault();
    });
  }

  render() {
    const id = `analysis_note_trix_input_analysis_${this.props.mdaId}`;

    // const dataDirectUploadUrl = this.props.api.url("rails/active_storage/direct_uploads");
    // const dataBlobUrlTemplate = this.props.api.url("rails/active_storage/blobs/:signed_id/:filename");
    // const dataDirectUploadUrl = "http://endymion:3000/rails/active_storage/direct_uploads";
    // const dataBlobUrlTemplate = "http://endymion:3000/rails/active_storage/blobs/:signed_id/:filename";
    // data-direct-upload-url={dataDirectUploadUrl}
    // data-blob-url-template={dataBlobUrlTemplate}

    return (
        <div>
          <label htmlFor="note">Note</label>
          <input type="hidden" name="analysis[note]" id={id} value={this.props.note} />
          {/* <textarea name="analysis[note]" id={id} defaultValue={this.props.note} /> */}
          <trix-editor id="analysis_note" input={id} class="trix-content form-control" ref={this.trixInput}>
          </trix-editor>
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