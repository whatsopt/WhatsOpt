import React from 'react';
import PropTypes from 'prop-types';

class MetaModelManager extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const metamodelUrl = this.props.api.url(`/operations/${this.props.opeId}/meta_models`);
    const outputs = [...new Set(this.props.selCases.o.map((c) => c.varname))].map((name) => (
      <span className="ml-5">
        {name}
        <input
          type="hidden"
          id={`meta_model_variables_outputs_${name}`}
          name="meta_model[variables][outputs][]"
          value={name}
        />
      </span>
    ));
    const inputs = [...new Set(this.props.selCases.i.map((c) => c.varname))].map((name) => (
      <span className="ml-5">
        {name}
        <input
          type="hidden"
          id={`meta_model_variables_inputs_${name}`}
          name="meta_model[variables][inputs][]"
          value={name}
        />
      </span>
    ));

    return (
      <div className="editor-section">
        <div className="row">
          <div className="col-md-3">
            <form acceptCharset="UTF-8" action={metamodelUrl} method="post" encType="multipart/form-data">
              <input name="authenticity_token" type="hidden" value={this.props.api.csrfToken} />
              <div className="form-group">
                <label>MetaModel Kind</label>
                <select className="form-control" name="meta_model[kind]" id="meta_model_kind">
                  <option value="KRIGING">KRIGING</option>
                  <option value="KPLS">KPLS</option>
                  <option value="KPLSK">KPLSK</option>
                  <option value="LS">LS</option>
                  <option value="QP">QP</option>
                </select>
              </div>
              <div className="form-group">
                <label>Inputs</label>
                <div>{inputs}</div>
              </div>
              <div className="form-group">
                <label>Outputs</label>
                <div>{outputs}</div>
              </div>
              <div className="form-group">
                <button type="submit" className="btn btn-primary">Create</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    );
  }
}

MetaModelManager.propTypes = {
  api: PropTypes.object.isRequired,
  opeId: PropTypes.number.isRequired,
  selCases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }),
  onMetaModelCreate: PropTypes.func.isRequired,
};

export default MetaModelManager;
