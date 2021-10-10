/* eslint-disable max-classes-per-file */
import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';
import Form from 'react-jsonschema-form-bs4';
import deepIsEqual from '../utils/compare';

class LogLine extends React.PureComponent {
  render() {
    const { line } = this.props;
    return (<div className="listing-line">{line}</div>);
  }
}

LogLine.propTypes = {
  line: PropTypes.string.isRequired,
};

const OPTTYPES = {
  smt_doe_lhs_nbpts: 'integer',
  smt_doe_egdoe_nbpts: 'integer',
  scipy_optimizer_slsqp_tol: 'number',
  scipy_optimizer_slsqp_disp: 'boolean',
  scipy_optimizer_slsqp_maxiter: 'integer',
  pyoptsparse_optimizer_snopt_tol: 'number',
  pyoptsparse_optimizer_snopt_maxiter: 'integer',
  onerasego_optimizer_segomoe_ncluster: 'integer',
  onerasego_optimizer_segomoe_maxiter: 'integer',
  onerasego_optimizer_segomoe_optimizer: 'string',
  onerasego_optimizer_egmdo_ncluster: 'integer',
  onerasego_optimizer_egmdo_maxiter: 'integer',
  onerasego_optimizer_egmdo_optimizer: 'string',
};
const OPTDEFAULTS = {
  smt_doe_lhs_nbpts: 50,
  smt_doe_egdoe_nbpts: 50,
  scipy_optimizer_slsqp_tol: 1e-6,
  scipy_optimizer_slsqp_maxiter: 100,
  scipy_optimizer_slsqp_disp: true,
  pyoptsparse_optimizer_snopt_tol: 1e-6,
  pyoptsparse_optimizer_snopt_maxiter: 1000,
  onerasego_optimizer_segomoe_maxiter: 100,
  onerasego_optimizer_segomoe_ncluster: 1,
  onerasego_optimizer_segomoe_optimizer: 'slsqp',
  onerasego_optimizer_egmdo_maxiter: 100,
  onerasego_optimizer_egmdo_ncluster: 1,
  onerasego_optimizer_egmdo_optimizer: 'slsqp',
};

const SCHEMA = {
  type: 'object',
  properties: {
    name: { type: 'string', title: 'Operation name' },
    host: { type: 'string', title: 'Analysis server' },
    driver: {
      type: 'string',
      title: 'Driver',
      enum: ['runonce',
        'smt_doe_lhs',
        'smt_doe_egdoe',
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
        'onerasego_optimizer_egmdo',
      ],
      enumNames: ['RunOnce',
        'SMT - LHS',
        'SMT - LHS on EGMDA',
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
        'Onera - SEGOMOE on EGMDA',
      ],
      default: 'runonce',
    },
    // "setSolverOptions": {"type": "boolean", "title": "Set solvers options", "default": false},
  },
  required: ['name', 'host', 'driver'],
  dependencies: {
    driver: {
      oneOf: [
        {
          properties: {
            driver: {
              enum: ['runonce',
                'scipy_optimizer_cobyla',
                'scipy_optimizer_bfgs',
                'pyoptsparse_optimizer_conmin',
                // "pyoptsparse_optimizer_fsqp",
                'pyoptsparse_optimizer_slsqp',
                // "pyoptsparse_optimizer_psqp",
                'pyoptsparse_optimizer_nsga2',
              ],
            },
          },
        },
        {
          properties: {
            driver: { enum: ['smt_doe_lhs'] },
            smt_doe_lhs: {
              title: 'Options for SMT LHS',
              type: 'object',
              properties: {
                smt_doe_lhs_nbpts: {
                  title: 'Number of sampling points',
                  type: OPTTYPES.smt_doe_lhs_nbpts,
                  default: OPTDEFAULTS.smt_doe_lhs_nbpts,
                },
              },
            },
          },
        },
        {
          properties: {
            driver: { enum: ['smt_doe_egdoe'] },
            smt_doe_egdoe: {
              title: 'Options for SMT LHS on EGMDA',
              type: 'object',
              properties: {
                smt_doe_egdoe_nbpts: {
                  title: 'Number of sampling points',
                  type: OPTTYPES.smt_doe_egdoe_nbpts,
                  default: OPTDEFAULTS.smt_doe_egdoe_nbpts,
                },
              },
            },
          },
        },
        {
          properties: {
            driver: { enum: ['scipy_optimizer_slsqp'] },
            scipy_optimizer_slsqp: {
              title: 'Options for Scipy optimizer',
              type: 'object',
              properties: {
                scipy_optimizer_slsqp_tol: {
                  title: 'Objective function tolerance for stopping criterion',
                  type: OPTTYPES.scipy_optimizer_slsqp_tol,
                  default: OPTDEFAULTS.scipy_optimizer_slsqp_tol,
                },
                scipy_optimizer_slsqp_disp: {
                  title: 'Print convergence messages',
                  type: OPTTYPES.scipy_optimizer_slsqp_disp,
                  default: OPTDEFAULTS.scipy_optimizer_slsqp_disp,
                },
                scipy_optimizer_slsqp_maxiter: {
                  title: 'Maximum of iterations',
                  type: OPTTYPES.scipy_optimizer_slsqp_maxiter,
                  default: OPTDEFAULTS.scipy_optimizer_slsqp_maxiter,
                },
              },
            },
          },
        },
        {
          properties: {
            driver: { enum: ['pyoptsparse_optimizer_snopt'] },
            pyoptsparse_optimizer_snopt: {
              title: 'Options for PyOptSparse optimizer',
              type: 'object',
              properties: {
                pyoptsparse_optimizer_snopt_tol: {
                  title: 'Nonlinear constraint violation tolerance',
                  type: OPTTYPES.pyoptsparse_optimizer_snopt_tol,
                  default: OPTDEFAULTS.pyoptsparse_optimizer_snopt_tol,
                },
                pyoptsparse_optimizer_snopt_maxiter: {
                  title: 'Major iteration limit',
                  type: OPTTYPES.pyoptsparse_optimizer_snopt_maxiter,
                  default: OPTDEFAULTS.pyoptsparse_optimizer_snopt_maxiter,
                },
              },
            },
          },
        },
        {
          properties: {
            driver: { enum: ['onerasego_optimizer_segomoe'] },
            onerasego_optimizer_segomoe: {
              title: 'Options for Onera SEGOMOE optimizer',
              type: 'object',
              properties: {
                onerasego_optimizer_segomoe_maxiter: {
                  title: 'Number max of iterations to run',
                  type: OPTTYPES.onerasego_optimizer_segomoe_maxiter,
                  default: OPTDEFAULTS.onerasego_optimizer_segomoe_maxiter,
                },
                onerasego_optimizer_segomoe_ncluster: {
                  title:
                    'Number of clusters used for objective and constraints surrogate mixture models (0: automatic)',
                  type: OPTTYPES.onerasego_optimizer_segomoe_ncluster,
                  default: OPTDEFAULTS.onerasego_optimizer_segomoe_ncluster,
                },
                onerasego_optimizer_segomoe_optimizer: {
                  title: 'Internal optimizer used for enrichment step',
                  type: OPTTYPES.onerasego_optimizer_segomoe_optimizer,
                  default: OPTDEFAULTS.onerasego_optimizer_segomoe_optimizer,
                  enum: ['cobyla', 'slsqp'],
                  enumNames: ['COBYLA', 'SLSQP'],
                },
              },
            },
          },
        },
        {
          properties: {
            driver: { enum: ['onerasego_optimizer_egmdo'] },
            onerasego_optimizer_egmdo: {
              title: 'Options for Onera SEGO+EGMDA optimizer',
              type: 'object',
              properties: {
                onerasego_optimizer_egmdo_maxiter: {
                  title: 'Number max of iterations to run',
                  type: OPTTYPES.onerasego_optimizer_egmdo_maxiter,
                  default: OPTDEFAULTS.onerasego_optimizer_egmdo_maxiter,
                },
                onerasego_optimizer_egmdo_ncluster: {
                  title:
                    'Number of clusters used for objective and constraints surrogate mixture models (0: automatic)',
                  type: OPTTYPES.onerasego_optimizer_egmdo_ncluster,
                  default: OPTDEFAULTS.onerasego_optimizer_egmdo_ncluster,
                },
                onerasego_optimizer_egmdo_optimizer: {
                  title: 'Internal optimizer used for enrichment step',
                  type: OPTTYPES.onerasego_optimizer_egmdo_optimizer,
                  default: OPTDEFAULTS.onerasego_optimizer_egmdo_optimizer,
                  enum: ['cobyla', 'slsqp'],
                  enumNames: ['COBYLA', 'SLSQP'],
                },
              },
            },
          },
        },
      ],
    },
  },
};

const UI_SCHEMA = {
};

function _filterFormOptions(options) {
  const filteredOptions = {};
  const re = new RegExp(`^${options.driver}`);
  // eslint-disable-next-line no-restricted-syntax
  for (const opt in options) {
    if ({}.hasOwnProperty.call(options, opt)) {
      if (opt === 'name' || opt === 'host' || opt === 'driver') {
        filteredOptions[opt] = options[opt];
      } else if (opt.match(re)) {
        filteredOptions[opt] = options[opt];
      }
    }
  }
  return filteredOptions;
}

function _toFormOptions(driver, options) {
  const formOptions = {};
  formOptions[driver] = options.reduce((acc, val) => {
    switch (OPTTYPES[val.name]) {
      case 'boolean':
        acc[val.name] = (val.value === 'true');
        break;
      case 'integer':
        acc[val.name] = parseInt(val.value, 10);
        break;
      case 'number':
        acc[val.name] = parseFloat(val.value);
        break;
      default:
        acc[val.name] = val.value;
    }
    return acc;
  }, {});
  return formOptions;
}

class Runner extends React.Component {
  constructor(props) {
    super(props);
    const { api, ope } = this.props;
    this.api = api;

    const status = (ope.job && ope.job.status) || 'PENDING';
    const log = (ope.job && ope.job.log) || '';
    const logCount = (ope.job && ope.job.log_count) || 0;

    const formData = {
      host: ope.host,
      name: ope.name,
      driver: ope.driver || 'runonce',
    };
    const formOptions = _toFormOptions(ope.driver, ope.options);
    Object.assign(formData, formOptions);
    this.opeData = {};
    Object.assign(this.opeData, formData);
    this.opeStatus = status;
    this.state = {
      schema: SCHEMA,
      formData,
      cases: ope.cases,
      status,
      log,
      log_count: logCount,
      startInMs: ope.job && ope.job && ope.job.start_in_ms,
      endInMs: ope.job && ope.job && ope.job.end_in_ms,
      // setSolverOptions: false,
    };

    this.handleRun = this.handleRun.bind(this);
    this.handleAbort = this.handleAbort.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleJobUpdate = this.handleJobUpdate.bind(this);

    if (status === 'RUNNING') { this._pollOperationJob(formData); }
  }

  handleRun(data) {
    const form = _filterFormOptions(data.formData);
    console.log(`FORM DATA = ${JSON.stringify(form)}`);
    const opeAttrs = {
      name: form.name, host: form.host, driver: form.driver, options_attributes: [],
    };
    const { ope } = this.props;
    this.api.getOperation(ope.id,
      (response) => {
        console.log(`resp=${JSON.stringify(response.data)}`);
        const ids = response.data.options.map((opt) => opt.id);
        for (const section in form) {
          if (section === form.driver) {
            for (const opt in form[section]) {
              if ({}.hasOwnProperty.call(form[section], opt)) {
                const optionAttrs = { name: opt, value: data.formData[section][opt] };
                if (ids.length) {
                  optionAttrs.id = ids.shift();
                }
                opeAttrs.options_attributes.push(optionAttrs);
              }
            }
          }
        }
        ids.forEach((id) => opeAttrs.options_attributes.push({ id, _destroy: '1' }));

        const newState = update(this.state, { status: { $set: 'STARTED' } });
        this.setState(newState);
        console.log(`opeAttrs=${JSON.stringify(opeAttrs)}`);

        this.api.updateOperation(ope.id, opeAttrs,
          () => { this._pollOperationJob(data.formData); });
      },
      (error) => { console.log(error); });
  }

  handleAbort() {
    console.log('ABORT');
    const { ope } = this.props;
    this.api.killOperationJob(ope.id);
    const newState = update(this.state, { status: { $set: 'ABORTED' } });
    this.setState(newState);
  }

  handleJobUpdate(job) {
    const newState = update(this.state, {
      status: { $set: job.status },
      log: { $set: job.log },
      log_count: { $set: job.log_count },
      startInMs: { $set: job.start_in_ms },
      endInMs: { $set: job.end_in_ms || Date.now() },
    });
    this.setState(newState);
  }

  handleChange(data) {
    console.log(`FORMDATA= ${JSON.stringify(data.formData)}`);
    console.log(`OPEDATA= ${JSON.stringify(this.opeData)}`);
    console.log(`FILTERDATA= ${JSON.stringify(_filterFormOptions(data.formData))}`);
    const { formData } = data;

    let newState;
    if (deepIsEqual(formData, this.opeData)) {
      console.log('NOT CHANGED');
      newState = update(this.state, {
        formData: { $set: formData },
        status: { $set: this.opeStatus },
      });
    } else {
      newState = update(this.state, {
        formData: { $set: formData },
        status: { $set: 'PENDING' },
      });
    }
    this.setState(newState);
  }

  _pollOperationJob(formData) {
    const { ope } = this.props;
    this.api.pollOperationJob(ope.id,
      (job) => {
        console.log('CHECK');
        console.log(JSON.stringify(job.status));
        return job.status === 'DONE' || job.status === 'FAILED';
      },
      (job) => {
        console.log('UPDATE');
        console.log(JSON.stringify(job));
        this.opeData = {};
        Object.assign(this.opeData, formData);
        this.opeStatus = job.status;
        this.handleJobUpdate(job);
      },
      (error) => {
        console.log(error);
      });
  }

  render() {
    const { log, log_count: logCount } = this.state;
    const lines = log.split('\n').map((l, i) => {
      const count = Math.max(logCount - 100, 0) + i;
      const line = `#${count}  ${l}`;
      return (<LogLine key={count} line={line} />);
    });

    const {
      status, cases, startInMs, endInMs, schema, formData,
    } = this.state;
    let btnStatusClass = status === 'DONE' ? 'btn btn-success' : 'btn btn-danger';
    let btnIcon = <i className="fa fa-exclamation-triangle" />;
    if (status === 'DONE') {
      btnIcon = <i className="fa fa-check" />;
    }
    if (status === 'RUNNING' || status === 'STARTED') {
      btnStatusClass = 'btn btn-info';
      btnIcon = <i className="fa fa-cog fa-spin" />;
    }
    if (status === 'PENDING') {
      btnStatusClass = 'btn btn-info';
      btnIcon = <i className="fa fa-question" />;
    }
    const active = (status === 'RUNNING' || status === 'STARTED');

    const { mda, ope } = this.props;
    let urlOnClose = `/analyses/${mda.id}`;
    if (cases.length > 0) {
      urlOnClose = `/operations/${ope.id}`;
    }

    let startTime = '?';
    if (startInMs) {
      startTime = (new Date(startInMs)).toLocaleString('en-GB');
    }

    let elapsed = '?';
    if (startInMs && endInMs) {
      elapsed = Math.ceil((endInMs - startInMs) / 1000);
    }

    return (
      <div>
        <form className="button_to" method="get" action={this.api.url(urlOnClose)}>
          <button className="btn float-right" type="submit">
            <i className="fa fa-times-circle" />
            {' '}
            Close
          </button>
        </form>

        <h1>
          Operation on
          {' '}
          {mda.name}
        </h1>
        <h2>Specification</h2>
        <div className="editor-section col-4">
          <Form
            schema={schema}
            formData={formData}
            uiSchema={UI_SCHEMA}
            onSubmit={this.handleRun}
            onChange={this.handleChange}
          >
            <div className="form-group">
              <button type="submit" className="btn btn-primary" disabled={active}>Run</button>
              <button
                type="button"
                className="ml-1 btn btn-secondary"
                disabled={!active}
                onClick={this.handleAbort}
              >
                Abort

              </button>
            </div>
          </Form>
        </div>

        <h2>Status</h2>

        <div className="editor-section">
          <div className="btn-group ml-2" role="group">
            <button
              className={`${btnStatusClass} btn-primary`}
              style={{ width: '120px' }}
              type="button"
              data-toggle="collapse"
              data-target="#collapseListing"
              aria-expanded="false"
            >
              {btnIcon}
              <span className="ml-1">{status}</span>
            </button>
          </div>
          <div className="btn-group ml-2" role="group">
            <strong>Started on</strong>
            :
            {' '}
            {startTime}
          </div>
          <div className="btn-group ml-2" role="group">
            <strong>{(status === 'RUNNING') ? 'Elapsed' : 'Ended after'}</strong>
            :
            {' '}
            {elapsed}
            s
          </div>
          <div className="collapse" id="collapseListing">
            <div className="card card-block">
              <div className="listing">
                {lines}
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

Runner.propTypes = {
  api: PropTypes.object.isRequired,
  mda: PropTypes.shape({
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
    impl: PropTypes.shape({
      openmdao: PropTypes.object.isRequired,
    }),
  }).isRequired,
  ope: PropTypes.shape({
    id: PropTypes.number.isRequired,
    name: PropTypes.string,
    host: PropTypes.string,
    driver: PropTypes.string,
    options: PropTypes.array,
    cases: PropTypes.array,
    job: PropTypes.shape({
      status: PropTypes.string.isRequired,
      log: PropTypes.string,
      log_count: PropTypes.number,
      start_in_ms: PropTypes.number,
      end_in_ms: PropTypes.number,
    }),
  }).isRequired,
};

export default Runner;
