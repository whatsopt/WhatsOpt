import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';
import Form from "react-jsonschema-form";
import CheckboxWidget from '../../utils/CheckboxWidget';

const WIDGETS = {
  CheckboxWidget,
};

const SCHEMA_DISCIPLINES = {
  "type": "object",

      "properties": {
        "parallel_execution": {"type": "boolean", "title": "Parallel Execution"},
      },
    }


const SCHEMA_NONLINEAR_SOLVER = {
  "type": "object",
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
    }

const SCHEMA_LINEAR_SOLVER = {
  "type": "object",

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
    }

class OpenmdaoImplEditor extends React.Component {
  
  constructor(props) {
    super(props);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleReset = this.handleReset.bind(this);
  }

  handleChange(data) {
    //console.log("Data changed: ", data)
  }

  handleSubmit(partName, data) {
    console.log("Data submitted: ", partName, data.formData)
    this.props.onOpenmdaoImplUpdate(partName, data.formData);
  }

  handleReset(partName) {
    this.props.onOpenmdaoImplReset(partName);
  }

  // static getDerivedStateFromProps(nextProps, prevState) {
  //   return {formData: {
  //     disciplines: {...nextProps.impl.disciplines},
  //     nonlinear_solver: {...nextProps.impl.nonlinear_solver},
  //     linear_solver: {...nextProps.impl.linear_solver},
  //   }};
  // }

  render() {
    return (
      <div className="editor-section">
        <div className="row">
          <div className="col-4">
            <Form schema={SCHEMA_DISCIPLINES} formData={this.props.impl.disciplines}
                  onChange={this.handleChange} onSubmit={(data) => this.handleSubmit('disciplines', data)} widgets={WIDGETS} liveValidate={true}>
              <div className="form-group">
                <button type="submit" className="btn btn-primary">Save</button>
                <button type="button" className="ml-1 btn btn-secondary" onClick={() => this.handleReset('disciplines')}>Reset</button>
              </div>
            </Form>
          </div>
          <div className="col-4">
            <Form schema={SCHEMA_NONLINEAR_SOLVER} formData={this.props.impl.nonlinear_solver}
                  onChange={this.handleChange} onSubmit={(data) => this.handleSubmit('nonlinear_solver', data)} widgets={WIDGETS} liveValidate={true}>
              <div className="form-group">
                <button type="submit" className="btn btn-primary">Save</button>
                <button type="button" className="ml-1 btn btn-secondary" onClick={() => this.handleReset('nonlinear_solver')}>Reset</button>
              </div>
            </Form>
          </div>
          <div className="col-4">
            <Form schema={SCHEMA_LINEAR_SOLVER} formData={this.props.impl.linear_solver}
                  onChange={this.handleChange} onSubmit={(data) => this.handleSubmit('linear_solver', data)} widgets={WIDGETS} liveValidate={true}>
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
  nodes: PropTypes.array.isRequired,
  impl: PropTypes.shape({
    disciplines: PropTypes.object.isRequired,
    nonlinear_solver: PropTypes.object.isRequired,
    linear_solver: PropTypes.object.isRequired,
  }),
  onOpenmdaoImplUpdate: PropTypes.func.isRequired,
};

export default OpenmdaoImplEditor;