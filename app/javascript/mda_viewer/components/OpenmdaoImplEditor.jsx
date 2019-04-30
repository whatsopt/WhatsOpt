import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';
import Form from "react-jsonschema-form-bs4";

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
        "err_on_maxiter": { "type": "boolean", "title": "Fail if not converged" },
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
        "err_on_maxiter": { "type": "boolean", "title": "Fail if not converged" },
        "iprint": { "type": "integer", "title": "Level of solver traces" }
      },
      "required": ["name", "atol", "rtol", "maxiter", "iprint"],
    },
  },
}

const UI_SCHEMA_COMPONENTS = {
  "components": { "ui:order": ["parallel_group", "use_scaling", "*"] }
}
class OpenmdaoImplEditor extends React.Component {

  constructor(props) {
    super(props);
    
    this.state = {reset: Date.now()}

    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleReset = this.handleReset.bind(this);
  }

  handleChange(data) {
    let openmdaoImpl = this._getOpenmdaoImpl(data.formData)
    this.props.onOpenmdaoImplChange(openmdaoImpl);
  }

  handleSubmit(data) {
    console.log("Data submitted: ", data.formData);
    let openmdaoImpl = this._getOpenmdaoImpl(data.formData)
    this.props.onOpenmdaoImplUpdate(openmdaoImpl);
  }

  _getOpenmdaoImpl(formData) {
    let openmdaoComps = formData.components;
    let nodes = [];
    for (let discId in openmdaoComps) {
      if (!isNaN(parseInt(discId))) { // take only ids, discard use_scaling and parallel_group
        nodes.push({discipline_id: discId, 
                      implicit_component: openmdaoComps[discId].implicit,
                      support_derivatives: openmdaoComps[discId].derivatives
                    });
      }
    }
    let openmdaoImpl = {
      components: {
        parallel_group: formData.components.parallel_group,
        use_scaling: formData.components.use_scaling,
        nodes: nodes,
      },
      nonlinear_solver: {...formData.nonlinear_solver},
      linear_solver: {...formData.linear_solver},
    }    
    return openmdaoImpl;
  }

  handleReset() {
    this.setState({reset: Date.now()});
    this.props.onOpenmdaoImplReset();
  }

  render() {
    // console.log("BEFORE", this.props.formData);    
    let nodes = this.props.impl.components.nodes;

    // Schema and Form data for components
    // schema
    let schema = {
      "type": "object",
      "properties": {
        "components": {
          "title": "Group",
          "type": "object",
          "properties": {
            "parallel_group": { "type": "boolean", "title": "Parallel Execution (MPI)" },
            "use_scaling": { "type": "boolean", "title": "Use scaling" },
          },
        },
      }
    }
    let compProps = schema.properties.components.properties;
    nodes.forEach((node) => {
      let name = this.props.db.getNodeName(node.discipline_id)
      compProps[node.discipline_id] = {
        "type": "object",
        "title": name,
        "properties": {
          "implicit": {"type": "boolean", "title": "Implicit component", "default": node.implicit_component},
          "derivatives": {"type": "boolean", "title": "Support derivatives", "default": node.support_derivatives},  
        }
      };  
    });
    // UI schema
    let uiSchema = {
      "components": { "ui:order": ["parallel_group", "use_scaling", "*"] }
    }
    if (this.props.db.isScaled()) {
      uiSchema.components.use_scaling = {"ui:disabled": true}
    }

    // formData: components.nodes -> components.disc1, components.disc2
    let nonlinear_solver = this.props.impl.nonlinear_solver;
    let linear_solver = this.props.impl.linear_solver;
    let formData = {
      components: {
        parallel_group: this.props.impl.components.parallel_group,
        use_scaling: this.props.impl.components.use_scaling,
      },
      nonlinear_solver: {...nonlinear_solver},
      linear_solver: {...linear_solver}
    };
    nodes.forEach((node) => {
      formData.components[`${node.discipline_id}`] = {
        implicit: node.implicit_component,
        derivatives: node.support_derivatives,
      };
    });

    return (
      <div className="editor-section">
        <div className="row">
          <div className="col-md-3">
            <Form key={this.state.reset} schema={schema} formData={formData} uiSchema={uiSchema}
              onChange={(data) => this.handleChange(data)} 
              onSubmit={(data) => this.handleSubmit(data)} liveValidate={true}>
              <div>
                <button type="submit" className="btn btn-primary">Save</button>
                <button type="button" className="ml-1 btn btn-secondary" onClick={this.handleReset}>Reset</button>
              </div>
            </Form>
          </div>
          <div className="col-md-3">
            <Form key={this.state.reset} schema={SCHEMA_NONLINEAR_SOLVER} formData={formData}
              onChange={(data) => this.handleChange(data)} 
              onSubmit={(data) => this.handleSubmit(data)} liveValidate={true}>
              <div className="form-group">
                <button type="submit" className="d-none btn btn-primary">Save</button>
              </div>
            </Form>
          </div>
          <div className="col-md-3">
            <Form key={this.state.reset} schema={SCHEMA_LINEAR_SOLVER} formData={formData}
              onChange={(data) => this.handleChange(data)} 
              onSubmit={(data) => this.handleSubmit(data)} liveValidate={true}>
              <div className="form-group">
                <button type="submit" className="d-none btn btn-primary">Save</button>
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
  onOpenmdaoImplChange: PropTypes.func.isRequired,
  onOpenmdaoImplReset: PropTypes.func.isRequired,
};

export default OpenmdaoImplEditor;