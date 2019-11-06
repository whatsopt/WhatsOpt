import React from 'react';
import PropTypes from 'prop-types';

class AnalysisNotePanel extends React.Component {
  constructor(props) {
    super(props);
    this.content = React.createRef();
  }

  componentDidMount() {
    this.content.current.innerHTML = this.props.note;
  }

  render() {
    return (
      <div className="tab-pane fade" id="note" role="tabpanel" aria-labelledby="note-tab">
        <div className="editor-section" ref={this.content} />
      </div>
    );
  }
}

AnalysisNotePanel.propTypes = {
  note: PropTypes.string.isRequired,
};

export default AnalysisNotePanel;
