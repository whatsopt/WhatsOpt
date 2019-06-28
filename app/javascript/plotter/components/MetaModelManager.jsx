import React from 'react';
import PropTypes from 'prop-types';

class MetaModelManager extends React.Component {

  render() {
    return (
      <div className="btn-toolbar" role="toolbar">
        <div className="btn-group" role="group">
          <a className="btn btn-primary" href="#" onClick={this.props.onMetaModelCreate}>Create</a>
        </div>
      </div>
    );
  }
}

MetaModelManager.propTypes = {
  onMetaModelCreate: PropTypes.func.isRequired,
};

export default MetaModelManager;
