import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';
import Form from "react-jsonschema-form";
import CheckboxWidget from '../../utils/CheckboxWidget';

const WIDGETS = {
  CheckboxWidget,
};

const SCHEMA = {
  "type": "object",
  "properties": {
    "disciplines": {"type": "object", "title": "Disciplines",
      "properties": {
        "parallel_group": {"type": "boolean", "title": "Parallel Execution"},
      },
    },
    "nonlinear_solver": {"type": "object", "title": "Nonlinear Solver",
      "properties": {
        "name": {
          "title": "Solver name",
          "enum": ["NonlinearBlockGS", "RecklessNonlinearBlockGS", "NonlinearBlockJac", "NonlinearRunOnce", "NewtonSolver", "BroydenSolver"]
        },
        "atol": {"type": "number", "title": "Absolute error tolerance"},
        "rtol": {"type": "number", "title": "Relative error tolerance"},
        "maxiter": {"type": "number", "title": "Maximum number of iterations (maxiter)"},
        "err_on_maxiter": {"type": "boolean", "title": "Mark as failed if not converged after maxiter iterations"},
        "iprint": {"type": "integer", "title": "Level of solver traces"}
      },
      "required": ["name", "atol", "rtol", "maxiter", "iprint"],
    },
    "linear_solver": {"type": "object", "title": "Linear Solver",
    "properties": {
      "name": {
        "title": "Solver name",
        "enum": ["ScipyKrylov", "LinearBlockGS", "LinearBlockJac", "LinearRunOnce", "DirectSolver", "PETScKrylov", "LinearUserDefined"]
      },
      "atol": {"type": "number", "title": "Absolute error tolerance"},
      "rtol": {"type": "number", "title": "Relative error tolerance"},
      "maxiter": {"type": "number", "title": "Maximum number of iterations (maxiter)"},
      "err_on_maxiter": {"type": "boolean", "title": "Mark as failed if not converged after maxiter iterations"},
      "iprint": {"type": "integer", "title": "Level of solver traces"}
    },
    "required": ["name", "atol", "rtol", "maxiter", "iprint"],
    },
  },
}

class OpenmdaoImplEditor extends React.Component {
  
  constructor(props) {
    super(props);
    this.initForm = {
      disciplines: {
        parallel_group: this.props.impl.parallel_group,
      },
      nonlinear_solver: {...this.props.impl.nonlinear_solver},
      linear_solver: {...this.props.impl.linear_solver},
    };
    this.state = {
      schema: {...SCHEMA},
      formData: {...this.initForm},
    };
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleReset = this.handleReset.bind(this);
  }

  handleChange(data) {
    console.log("Data changed: ",data)
  }

  handleSubmit(data) {
    console.log("Data submitted: ",  data);
    const formData = data.formData;
    this.props.onOpenmdaoImplUpdate(
      {
        parallel_group: formData.disciplines.parallel_group,
        nonlinear_solver: formData.nonlinear_solver,
        linear_solver: formData.linear_solver
      }
    );
  }

  handleReset() {
    this.setState(update(this.state, {formData: {$set: this.initForm}}));
  }

  render() {
    return (
      <div className="editor-section col-md-4">
        <Form schema={this.state.schema} formData={this.state.formData} 
              onChange={this.handleChange} onSubmit={this.handleSubmit} widgets={WIDGETS}>
          <div className="form-group">
            <button type="submit" className="btn btn-primary">Save</button>
            <button type="button" className="ml-1 btn btn-secondary" onClick={this.handleReset}>Reset</button>
          </div>
        </Form>
      </div>
    );
  }

};

OpenmdaoImplEditor.propTypes = {
  nodes: PropTypes.array.isRequired,
  impl: PropTypes.shape({
    parallel_group: PropTypes.bool.isRequired,
    nonlinear_solver: PropTypes.object.isRequired,
    linear_solver: PropTypes.object.isRequired,
  }),
  //nodes: PropTypes.array.isRequired,
  onOpenmdaoImplUpdate: PropTypes.func.isRequired,
  //onDisciplineUpdate: PropTypes.func.isRequired,
};

export default OpenmdaoImplEditor;