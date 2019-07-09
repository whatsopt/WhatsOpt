import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';
import Form from "react-jsonschema-form-bs4";

const SCHEMA_METAMODEL = {
  "type": "object",
  "properties": {
    "metamodel": {
      "title": "MetaModel",
      "type": "object",
      "properties": {
        "kind": {
          "title": "Surrogate Kind",
          "enum": ["KRIGING", "KPLS", "KPLSK", "LS", "QP"],
          "default": "",
        },
      },
      "required": ["kind"],
    },
  },
};

class MetaModelManager extends React.Component {
  constructor(props) {
    super(props);
    this.state = { reset: Date.now(), surrogate_kind: "KRIGING" };
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(data) {
    console.log(data);
  }

  handleSubmit(data) {
    this.props.onMetaModelCreate(data);
  }

  render() {
    const formData = {
      metamodel: { kind: "KRIGING" },
    };
    // UI schema
    const uiSchema = {
      "metamodel": {},
    }

    return (
      <div className="editor-section">
        <div className="row">
          <div className="col-md-3">
            <Form key={this.state.reset} schema={SCHEMA_METAMODEL} formData={formData} uiSchema={uiSchema}
              onChange={this.handleChange}
              onSubmit={this.handleSubmit} liveValidate={true}>
              <div className="form-group">
                <button type="submit" className="btn btn-primary">Create</button>
              </div>
            </Form>
          </div>
        </div>
      </div>
    );
  }
}

MetaModelManager.propTypes = {
  onMetaModelCreate: PropTypes.func.isRequired,
};

export default MetaModelManager;
