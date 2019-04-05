import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';
import Form from "react-jsonschema-form-bs4";
import CheckboxWidget from '../../utils/CheckboxWidget';

const WIDGETS = {
  //CheckboxWidget,
};

const SCHEMA_COMPONENTS = {
  "type": "object",
  "properties": {
    "components": {
      "title": "Components",
      "type": "object",
      "properties": {
        "parallel_execution": { "type": "boolean", "title": "Parallel Execution" },
        "nodes": {
          "type": "array",
          "title": "Implicits",
          "items": [],
        },
      },
    },
  }
}

const SCHEMA_NONLINEAR_SOLVER = {
  "type": "object",
  "properties": {
    "nonlinear_solver": {
      "title": "Nonlinear solver",
      "type": "object",
      "properties": {
        "name": {
          "title": "Solver name",
          "enum": ["NonlinearBlockGS", "RecklessNonlinearBlockGS", "NonlinearBlockJac", "NonlinearRunOnce", "NewtonSolver", "BroydenSolver"]
        },
        "atol": { "type": "number", "title": "Absolute error tolerance" },
        "rtol": { "type": "number", "title": "Relative error tolerance" },
        "maxiter": { "type": "number", "title": "Maximum number of iterations (maxiter)" },
        "err_on_maxiter": { "type": "boolean", "title": "Mark as failed if not converged after maxiter iterations" },
        "iprint": { "type": "integer", "title": "Level of solver traces" }
      },
      "required": ["name", "atol", "rtol", "maxiter", "iprint"],
    },
  },
}

const SCHEMA_LINEAR_SOLVER = {
  "type": "object",
  "properties": {
    "linear_solver": {
      "title": "Linear solver",
      "type": "object",
      "properties": {
        "name": {
          "title": "Solver name",
          "enum": ["ScipyKrylov", "LinearBlockGS", "LinearBlockJac", "LinearRunOnce", "DirectSolver", "PETScKrylov", "LinearUserDefined"]
        },
        "atol": { "type": "number", "title": "Absolute error tolerance" },
        "rtol": { "type": "number", "title": "Relative error tolerance" },
        "maxiter": { "type": "number", "title": "Maximum number of iterations (maxiter)" },
        "err_on_maxiter": { "type": "boolean", "title": "Mark as failed if not converged after maxiter iterations" },
        "iprint": { "type": "integer", "title": "Level of solver traces" }
      },
      "required": ["name", "atol", "rtol", "maxiter", "iprint"],
    },
  },
}

const UI_SCHEMA_COMPONENTS = {

}
class OpenmdaoImplEditor extends React.Component {

  constructor(props) {
    super(props);

    let nodes = this.props.impl.components.nodes;
    this.state = {
      schema: {...SCHEMA_COMPONENTS},
      formData: {
        components: {
          parallel_execution: this.props.impl.components.parallel_execution,
          nodes: nodes.map((node) => node.implicit_component),
        },
      },        
    };
    this.state.schema.properties.components.properties.nodes.items = 
      nodes.map((node) => { return {"title": this.props.db.getNodeName(node.discipline_id), "type": "boolean", "default": false}});

    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleReset = this.handleReset.bind(this);
  }

  handleChange(data) {
    //console.log("Data changed: ", data)
  }

  handleSubmit(data) {
    console.log("Data submitted: ", data.formData)
    this.props.onOpenmdaoImplUpdate(data.formData);
  }

  handleReset() {
  }

  // static getDerivedStateFromProps(nextProps, prevState) {
  //   return {formData: {
  //     disciplines: {...nextProps.impl.disciplines},
  //     nonlinear_solver: {...nextProps.impl.nonlinear_solver},
  //     linear_solver: {...nextProps.impl.linear_solver},
  //   }};
  // }

  render() {
    console.log("RENDER", this.state.formData);    

    return (
      <div className="editor-section">
        <div className="row">
          <div className="col-4">
            <Form schema={this.state.schema} formData={this.state.formData} uiSchema={UI_SCHEMA_COMPONENTS}
              onChange={this.handleChange} onSubmit={this.handleSubmit} widgets={WIDGETS} liveValidate={true}>
              <div className="form-group">
                <button type="submit" className="btn btn-primary">Save</button>
                <button type="button" className="ml-1 btn btn-secondary" onClick={() => this.handleReset('disciplines')}>Reset</button>
              </div>
            </Form>
          </div>
          <div className="col-4">
            <Form schema={SCHEMA_NONLINEAR_SOLVER} formData={...this.props.impl}
              onChange={this.handleChange} onSubmit={this.handleSubmit} widgets={WIDGETS} liveValidate={true}>
              <div className="form-group">
                <button type="submit" className="btn btn-primary">Save</button>
                <button type="button" className="ml-1 btn btn-secondary" onClick={() => this.handleReset('nonlinear_solver')}>Reset</button>
              </div>
            </Form>
          </div>
          <div className="col-4">
            <Form schema={SCHEMA_LINEAR_SOLVER} formData={...this.props.impl}
              onChange={this.handleChange} onSubmit={this.handleSubmit} widgets={WIDGETS} liveValidate={true}>
              <div className="form-group">
                <button type="submit" className="btn btn-primary">Save</button>
                <button type="button" className="ml-1 btn btn-secondary" onClick={() => this.handleReset('linear_solver')}>Reset</button>
              </div>
            </Form>
          </div>
        </div>
      </div>
    );
  }

};

OpenmdaoImplEditor.propTypes = {
  db: PropTypes.object.isRequired,
  impl: PropTypes.shape({
    components: PropTypes.object.isRequired,
    nonlinear_solver: PropTypes.object.isRequired,
    linear_solver: PropTypes.object.isRequired,
  }),
  onOpenmdaoImplUpdate: PropTypes.func.isRequired,
  onOpenmdaoImplReset: PropTypes.func.isRequired,
};

export default OpenmdaoImplEditor;