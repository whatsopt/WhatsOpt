import React from 'react';
import PropTypes from 'prop-types';
import Form from '@rjsf/bootstrap-4';

const SCHEMA_GENERAL = {
  type: 'object',
  properties: {
    general: {
      type: 'object',
      title: 'General',
      properties: {
        use_units: { type: 'boolean', title: 'Use units' },
        use_scaling: { type: 'boolean', title: 'Use scaling' },
        parallel_group: { type: 'boolean', title: 'Parallel Group (MPI)' },
        packaging: {
          type: 'object',
          title: 'Packaging',
          properties: {
            package_name: { type: 'string', title: 'Package Name' },
          },
        },
        driver: {
          type: 'object',
          title: 'Driver',
          properties: {
            optimization: {
              type: 'string',
              title: 'Optimization',
              enum: [
                'scipy_optimizer_cobyla',
                'scipy_optimizer_bfgs',
                'scipy_optimizer_slsqp',
                'pyoptsparse_optimizer_conmin',
                // "pyoptsparse_optimizer_fsqp",
                'pyoptsparse_optimizer_slsqp',
                // "pyoptsparse_optimizer_psqp",
                'pyoptsparse_optimizer_nsga2',
                'pyoptsparse_optimizer_snopt',
                'onerasego_optimizer_segomoe',
              ],
              enumNames: [
                'Scipy - COBYLA',
                'Scipy - BFGS',
                'Scipy - SLSQP',
                'pyOptSparse - CONMIN',
                // "pyOptSparse - FSQP",
                'pyOptSparse - SLSQP',
                // "pyOptSparse - PSQP",
                'pyOptSparse - NSGA2',
                'pyOptSparse - SNOPT',
                'Onera - SEGOMOE',
              ],
              default: 'scipy_optimizer_slsqp',
            },
          },
        },
      },
    },
  },
};

const SCHEMA_NONLINEAR_SOLVER = {
  type: 'object',
  properties: {
    nonlinear_solver: {
      title: 'Nonlinear solver',
      type: 'object',
      properties: {
        name: {
          title: 'Solver name',
          enum: ['NonlinearBlockGS', 'RecklessNonlinearBlockGS', 'NonlinearBlockJac',
            'NonlinearRunOnce', 'NewtonSolver', 'BroydenSolver'],
        },
        atol: { type: 'number', title: 'Absolute error tolerance' },
        rtol: { type: 'number', title: 'Relative error tolerance' },
        maxiter: { type: 'number', title: 'Maximum number of iterations (maxiter)' },
        err_on_non_converge: { type: 'boolean', title: 'Fail if not converged' },
        iprint: { type: 'integer', title: 'Level of solver traces' },
      },
      required: ['name', 'atol', 'rtol', 'maxiter', 'iprint'],
    },
  },
};

const SCHEMA_LINEAR_SOLVER = {
  type: 'object',
  properties: {
    linear_solver: {
      title: 'Linear solver',
      type: 'object',
      properties: {
        name: {
          title: 'Solver name',
          enum: ['ScipyKrylov', 'LinearBlockGS', 'LinearBlockJac', 'LinearRunOnce',
            'DirectSolver', 'PETScKrylov', 'LinearUserDefined'],
        },
        atol: { type: 'number', title: 'Absolute error tolerance' },
        rtol: { type: 'number', title: 'Relative error tolerance' },
        maxiter: { type: 'number', title: 'Maximum number of iterations (maxiter)' },
        err_on_non_converge: { type: 'boolean', title: 'Fail if not converged' },
        iprint: { type: 'integer', title: 'Level of solver traces' },
      },
      required: ['name', 'atol', 'rtol', 'maxiter', 'iprint'],
    },
  },
};

function _getOpenmdaoImpl(formData) {
  console.log(formData);
  const openmdaoComps = formData.components;
  const nodes = [];
  for (const discId in openmdaoComps) {
    // eslint-disable-next-line no-restricted-globals
    if (!isNaN(parseInt(discId, 10))) { // take only ids, discard use_scaling and parallel_group
      nodes.push({
        discipline_id: discId,
        implicit_component: openmdaoComps[discId].implicit,
        support_derivatives: openmdaoComps[discId].derivatives,
        egmdo_surrogate: openmdaoComps[discId].surrogate,
      });
    }
  }
  const openmdaoImpl = {
    parallel_group: formData.general.parallel_group,
    use_scaling: formData.general.use_scaling,
    use_units: formData.general.use_units,
    optimization_driver: formData.general.driver.optimization,
    packaging: formData.general.packaging,
    nodes,
    nonlinear_solver: { ...formData.nonlinear_solver },
    linear_solver: { ...formData.linear_solver },
  };
  return openmdaoImpl;
}
class OpenmdaoImplEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state = { reset: Date.now() };

    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleReset = this.handleReset.bind(this);
  }

  handleChange(data) {
    const openmdaoImpl = _getOpenmdaoImpl(data.formData);
    const { onOpenmdaoImplChange } = this.props;
    onOpenmdaoImplChange(openmdaoImpl);
  }

  handleSubmit(data) {
    console.log('Data submitted: ', data.formData);
    const openmdaoImpl = _getOpenmdaoImpl(data.formData);
    const { onOpenmdaoImplUpdate } = this.props;
    onOpenmdaoImplUpdate(openmdaoImpl);
  }

  handleReset() {
    this.setState({ reset: Date.now() });
    const { onOpenmdaoImplReset } = this.props;
    onOpenmdaoImplReset();
  }

  render() {
    // console.log("BEFORE", this.props.formData);
    const { impl, db } = this.props;
    const { nodes } = impl;

    // Schema and Form data for components
    // schema
    const schema = {
      type: 'object',
      properties: {
        components: {
          type: 'object',
          title: 'Components',
          properties: {},
        },
      },
    };
    const compProps = schema.properties.components.properties;
    nodes.forEach((node) => {
      const name = db.getNodeName(node.discipline_id);
      compProps[node.discipline_id] = {
        type: 'object',
        title: name,
        properties: {
          implicit: { type: 'boolean', title: 'Implicit component', default: node.implicit_component },
          derivatives: { type: 'boolean', title: 'Support derivatives', default: node.support_derivatives },
          surrogate: { type: 'boolean', title: 'EGMDO surrogate', default: node.egmdo_surrogate },
        },
      };
    });
    // UI schema
    const uiSchema = {
      general: { 'ui:order': ['use_units', 'use_scaling', 'parallel_group', 'packaging', 'driver'] },
    };
    if (db.isScaled()) {
      uiSchema.general.use_scaling = { 'ui:disabled': true };
    }

    // formData: nodes -> components.disc1, components.disc2
    const nonlinearSolver = impl.nonlinear_solver;
    const linearSolver = impl.linear_solver;
    const formData = {
      general: {
        use_units: impl.use_units,
        use_scaling: impl.use_scaling,
        parallel_group: impl.parallel_group,
        packaging: impl.packaging,
        driver: { optimization: impl.optimization_driver },
      },
      components: {},
      nonlinear_solver: { ...nonlinearSolver },
      linear_solver: { ...linearSolver },
    };
    nodes.forEach((node) => {
      formData.components[`${node.discipline_id}`] = {
        implicit: node.implicit_component,
        derivatives: node.support_derivatives,
        surrogate: node.egmdo_surrogate,
      };
    });

    const { reset } = this.state;
    return (
      <div className="editor-section">
        <div className="row">
          <div className="col-md-2">
            <Form
              key={reset}
              schema={SCHEMA_GENERAL}
              formData={formData}
              uiSchema={uiSchema}
              onChange={(data) => this.handleChange(data)}
              onSubmit={(data) => this.handleSubmit(data)}
              liveValidate
            >
              <div>
                <button type="submit" className="btn btn-primary">Save</button>
                <button type="button" className="ml-1 btn btn-secondary" onClick={this.handleReset}>Reset</button>
              </div>
            </Form>
          </div>
          <div className="col-md-2">
            <Form
              key={reset}
              schema={schema}
              formData={formData}
              onChange={(data) => this.handleChange(data)}
              onSubmit={(data) => this.handleSubmit(data)}
              liveValidate
            >
              <div>
                <button type="submit" className="d-none btn btn-primary">Save</button>
              </div>
            </Form>
          </div>
          <div className="col-md-3">
            <Form
              key={reset}
              schema={SCHEMA_NONLINEAR_SOLVER}
              formData={formData}
              onChange={(data) => this.handleChange(data)}
              onSubmit={(data) => this.handleSubmit(data)}
              liveValidate
            >
              <div className="form-group">
                <button type="submit" className="d-none btn btn-primary">Save</button>
              </div>
            </Form>
          </div>
          <div className="col-md-3">
            <Form
              key={reset}
              schema={SCHEMA_LINEAR_SOLVER}
              formData={formData}
              onChange={(data) => this.handleChange(data)}
              onSubmit={(data) => this.handleSubmit(data)}
              liveValidate
            >
              <div className="form-group">
                <button type="submit" className="d-none btn btn-primary">Save</button>
              </div>
            </Form>
          </div>
        </div>
      </div>
    );
  }
}

OpenmdaoImplEditor.propTypes = {
  db: PropTypes.object.isRequired,
  impl: PropTypes.shape({
    use_units: PropTypes.bool.isRequired,
    parallel_group: PropTypes.bool.isRequired,
    use_scaling: PropTypes.bool.isRequired,
    optimization_driver: PropTypes.string.isRequired,
    packaging: PropTypes.shape({
      package_name: PropTypes.string.isRequired,
    }),
    nodes: PropTypes.array.isRequired,
    nonlinear_solver: PropTypes.object.isRequired,
    linear_solver: PropTypes.object.isRequired,
  }).isRequired,
  onOpenmdaoImplUpdate: PropTypes.func.isRequired,
  onOpenmdaoImplChange: PropTypes.func.isRequired,
  onOpenmdaoImplReset: PropTypes.func.isRequired,
};

export default OpenmdaoImplEditor;
