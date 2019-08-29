import React from 'react';
import PropTypes from 'prop-types';
// import update from 'immutability-helper';
// import Form from "react-jsonschema-form-bs4";

// const SCHEMA_METAMODEL = {
//   "type": "object",
//   "properties": {
//     "metamodel": {
//       "title": "MetaModel",
//       "type": "object",
//       "properties": {
//         "kind": {
//           "title": "Surrogate Kind",
//           "enum": ["KRIGING", "KPLS", "KPLSK", "LS", "QP"],
//           "default": "",
//         },
//       },
//       "required": ["kind"],
//     },
//   },
// };

class MetaModelManager extends React.Component {
  constructor(props) {
    super(props);
    // this.state = { reset: Date.now(), surrogate_kind: "KRIGING" };
    // this.handleSubmit = this.handleSubmit.bind(this);
    // this.handleChange = this.handleChange.bind(this);
  }

  // handleChange(data) {
  //   console.log(data);
  // }

  // handleSubmit(data) {
  //   this.props.onMetaModelCreate(data);
  // }

  render() {
    // const formData = {
    //   metamodel: { kind: "KRIGING" },
    // };
    // // UI schema
    // const uiSchema = {
    //   "metamodel": {},
    // }

    const metamodelUrl = this.props.api.url(`/operations/${this.props.opeId}/meta_models`);

    return (
      <div className="editor-section">
        <div className="row">
          <div className="col-md-3">
            <form acceptCharset="UTF-8" action={metamodelUrl} method="post" encType="multipart/form-data">
              <input name="authenticity_token" type="hidden" value={this.props.api.csrfToken} />
              <div className="form-group">
                <select className="form-control" name="meta_model[kind]" id="meta_model_kind">
                  <option value="KRIGING">KRIGING</option>
                  {/* <option value="KPLS">KPLS</option>
                  <option value="KPLSK">KPLSK</option>
                  <option value="LS">LS</option>
                  <option value="QP">QP</option> */}
                </select>
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
  onMetaModelCreate: PropTypes.func.isRequired,
};

export default MetaModelManager;
