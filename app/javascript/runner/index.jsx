import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';
import Form from "react-jsonschema-form-bs4";
import { deepIsEqual } from '../utils/compare';

class LogLine extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (<div className="listing-line">{this.props.line}</div>);
  }
}

LogLine.propTypes = {
  line: PropTypes.string.isRequired,
};

const OPTTYPES = {
  smt_doe_lhs_nbpts: "integer",
  scipy_optimizer_slsqp_tol: "number",
  scipy_optimizer_slsqp_disp: "boolean",
  scipy_optimizer_slsqp_maxiter: "integer",
  pyoptsparse_optimizer_snopt_tol: "number",
  pyoptsparse_optimizer_snopt_maxiter: "integer",
  onerasego_optimizer_segomoe_ncluster: "integer",
  onerasego_optimizer_segomoe_maxiter: "integer",
  onerasego_optimizer_segomoe_optimizer: "string",
};
const OPTDEFAULTS = {
  smt_doe_lhs_nbpts: 50,
  scipy_optimizer_slsqp_tol: 1e-6,
  scipy_optimizer_slsqp_maxiter: 100,
  scipy_optimizer_slsqp_disp: true,
  pyoptsparse_optimizer_snopt_tol: 1e-6,
  pyoptsparse_optimizer_snopt_maxiter: 1000,
  onerasego_optimizer_segomoe_maxiter: 100,
  onerasego_optimizer_segomoe_ncluster: 1,
  onerasego_optimizer_segomoe_optimizer: "slsqp",
};

const SCHEMA = {
  type: "object",
  properties: {
    "name": {"type": "string", "title": "Operation name"},
    "host": {"type": "string", "title": "Analysis server"},
    "driver": {"type": "string", "title": "Driver",
      "enum": ["runonce", "smt_doe_lhs",
        "scipy_optimizer_cobyla",
        "scipy_optimizer_bfgs",
        "scipy_optimizer_slsqp",
        "pyoptsparse_optimizer_conmin",
        // "pyoptsparse_optimizer_fsqp",
        "pyoptsparse_optimizer_slsqp",
        // "pyoptsparse_optimizer_psqp",
        "pyoptsparse_optimizer_nsga2",
        // "pyoptsparse_optimizer_snopt",
        "onerasego_optimizer_segomoe",
      ],
      "enumNames": ["RunOnce", 
        "SMT - LHS", 
        "Scipy - COBYLA", 
        "Scipy - BFGS", 
        "Scipy - SLSQP",
        "pyOptSparse - CONMIN",
        // "pyOptSparse - FSQP",
        "pyOptSparse - SLSQP",
        // "pyOptSparse - PSQP", 
        "pyOptSparse - NSGA2", 
        // "pyOptSparse - SNOPT", 
        "Onera - SEGOMOE"],
      "default": "runonce",
    },
    //"setSolverOptions": {"type": "boolean", "title": "Set solvers options", "default": false},
  },
  required: ["name", "host", "driver"],
  dependencies: {
    "driver": {
      "oneOf": [
        {
          "properties": {"driver": {"enum": ["runonce",
            "scipy_optimizer_cobyla",
            "scipy_optimizer_bfgs",
            "pyoptsparse_optimizer_conmin",
            // "pyoptsparse_optimizer_fsqp",
            "pyoptsparse_optimizer_slsqp",
            // "pyoptsparse_optimizer_psqp",
            "pyoptsparse_optimizer_nsga2"
          ]}},
        },
        {
          "properties": {"driver": {"enum": ["smt_doe_lhs"]},
            "smt_doe_lhs": {
              "title": "Options for SMT LHS",
              "type": "object",
              "properties": {
                "smt_doe_lhs_nbpts": {
                  "title": "Number of sampling points",
                  "type": OPTTYPES.smt_doe_lhs_nbpts,
                  "default": OPTDEFAULTS.smt_doe_lhs_nbpts
                },
              },
            },
          },
        },
        {
          "properties": {"driver": {"enum": ["scipy_optimizer_slsqp"]},
          "scipy_optimizer_slsqp": {
            "title": "Options for Scipy optimizer",
            "type": "object",
            "properties": {
              "scipy_optimizer_slsqp_tol": {"title": "Objective function tolerance for stopping criterion",
                "type": OPTTYPES.scipy_optimizer_slsqp_tol,
                "default": OPTDEFAULTS.scipy_optimizer_slsqp_tol},
              "scipy_optimizer_slsqp_disp": {"title": "Print convergence messages",
                "type": OPTTYPES.scipy_optimizer_slsqp_disp,
                "default": OPTDEFAULTS.scipy_optimizer_slsqp_disp},
              "scipy_optimizer_slsqp_maxiter": {"title": "Maximum of iterations",
                "type": OPTTYPES.scipy_optimizer_slsqp_maxiter,
                "default": OPTDEFAULTS.scipy_optimizer_slsqp_maxiter}
              },
            },
          },
        },
        {
          "properties": {"driver": {"enum": ["pyoptsparse_optimizer_snopt"]},
          "pyoptsparse_optimizer_snopt": {
            "title": "Options for PyOptSparse optimizer",
            "type": "object",
            "properties": {
              "pyoptsparse_optimizer_snopt_tol": {"title": "Nonlinear constraint violation tolerance",
                "type": OPTTYPES.pyoptsparse_optimizer_snopt_tol,
                "default": OPTDEFAULTS.pyoptsparse_optimizer_snopt_tol},
              "pyoptsparse_optimizer_snopt_maxiter": {"title": "Major iteration limit",
                "type": OPTTYPES.pyoptsparse_optimizer_snopt_maxiter,
                "default": OPTDEFAULTS.pyoptsparse_optimizer_snopt_maxiter}
              },
            },
          },
        }, 
        {
          "properties": {"driver": {"enum": ["onerasego_optimizer_segomoe"]},
          "onerasego_optimizer_segomoe": {
            "title": "Options for Onera SEGOMOE optimizer",
            "type": "object",
            "properties": {
              "onerasego_optimizer_segomoe_maxiter": {"title": "Number max of iterations to run",
                "type": OPTTYPES.onerasego_optimizer_segomoe_maxiter,
                "default": OPTDEFAULTS.onerasego_optimizer_segomoe_maxiter},
              "onerasego_optimizer_segomoe_ncluster": {"title": "Number of clusters used for objective and constraints surrogate mixture models (0: automatic)",
                "type": OPTTYPES.onerasego_optimizer_segomoe_ncluster,
                "default": OPTDEFAULTS.onerasego_optimizer_segomoe_ncluster},
              "onerasego_optimizer_segomoe_optimizer": {"title": "Internal optimizer used for enrichment step",
                "type": OPTTYPES.onerasego_optimizer_segomoe_optimizer,
                "default": OPTDEFAULTS.onerasego_optimizer_segomoe_optimizer,
                "enum": ["cobyla", "slsqp"],
                "enumNames": ["COBYLA", "SLSQP"]},
              },
            },
          },
        },
      ],
    },
  },
};

const UI_SCHEMA = {
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
        "err_on_maxiter": { "type": "boolean", "title": "Mark as failed if not converged" },
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
        "err_on_maxiter": { "type": "boolean", "title": "Mark as failed if not converged" },
        "iprint": { "type": "integer", "title": "Level of solver traces" }
      },
      "required": ["name", "atol", "rtol", "maxiter", "iprint"],
    },
  },
}

class Runner extends React.Component {
  constructor(props) {
    super(props);
    this.api = this.props.api;

    const status = (this.props.ope.job && this.props.ope.job.status) || 'PENDING';
    const log = (this.props.ope.job && this.props.ope.job.log) || "";
    const log_count = (this.props.ope.job && this.props.ope.job.log_count) || 0;

    const formData = {
      host: this.props.ope.host,
      name: this.props.ope.name,
      driver: this.props.ope.driver || "runonce",
    };
    console.log(this.props.ope.options);
    const formOptions = this._toFormOptions(this.props.ope.driver, this.props.ope.options);
    Object.assign(formData, formOptions);
    this.opeData = {};
    Object.assign(this.opeData, formData);
    this.opeStatus = status;
    this.state = {
      schema: SCHEMA,
      formData: formData,
      cases: this.props.ope.cases,
      status: status,
      log: log,
      log_count: log_count,
      startInMs: this.props.ope.job && this.props.ope.job && this.props.ope.job.start_in_ms,
      endInMs: this.props.ope.job && this.props.ope.job && this.props.ope.job.end_in_ms,
      //setSolverOptions: false,
    };

    this.handleRun = this.handleRun.bind(this);
    this.handleAbort = this.handleAbort.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleJobUpdate = this.handleJobUpdate.bind(this);

    if (status === "RUNNING") {this._pollOperationJob(formData);}
  }

  handleRun(data) {
    const form = this._filterFormOptions(data.formData);
    // console.log("FORM DATA = "+JSON.stringify(form));
    const opeAttrs = {name: form.name, host: form.host, driver: form.driver, options_attributes: []};

    this.api.getOperation(this.props.ope.id,
        (response) => {
        // console.log(response);
          const ids = response.data.options.map((opt) => opt.id);
          for (const section in form) {
            if (section === form.driver) {
              for (const opt in form[section]) {
                const optionAttrs = {name: opt, value: data.formData[section][opt]};
                if (ids.length) {
                  optionAttrs.id = ids.shift();
                }
                opeAttrs.options_attributes.push(optionAttrs);
              }
            }
          }
          ids.forEach((id) => opeAttrs.options_attributes.push({id: id, _destroy: '1'}));

          const newState = update(this.state, {status: {$set: "STARTED"}});
          this.setState(newState);
          console.log(opeAttrs);

          this.api.updateOperation(this.props.ope.id, opeAttrs,
              (response) => {this._pollOperationJob(data.formData);},
              (error) => {console.log(error);});
        },
        (error) => {console.log(error);});
  }

  handleAbort() {
    console.log("ABORT");
    this.api.killOperationJob(this.props.ope.id);
    const newState = update(this.state, {status: {$set: "ABORTED"}});
    this.setState(newState);
  }

  handleJobUpdate(job) {
    const newState = update(this.state, {status: {$set: job.status},
      log: {$set: job.log},
      log_count: {$set: job.log_count},
      startInMs: {$set: job.start_in_ms},
      endInMs: {$set: job.end_in_ms || Date.now()},
    });
    this.setState(newState);
  }

  handleChange(data) {
    console.log("FORMDATA= "+JSON.stringify(data.formData));
    console.log("OPEDATA= "+JSON.stringify(this.opeData));
    console.log("FILTERDATA= "+JSON.stringify(this._filterFormOptions(data.formData)));
    const formData = data.formData;
    // let schema = {...this.state.schema} 
    // if (formData.setSolverOptions) {
    //   schema.properties = Object.assign(schema.properties, {
    //     ...(SCHEMA_NONLINEAR_SOLVER.properties),
    //     ...(SCHEMA_LINEAR_SOLVER.properties),
    //   })
    //   // schema.properties.nonlinear_solver.properties = {...(this.props.mda.impl.openmdao.nonlinear_solver)};
    //   // schema.properties.nonlinear_solver.properties = {...(this.props.mda.impl.openmdao.nonlinear_solver)};
    // } else {
    //   schema.properties = Object.assign({},schema.properties)
    //   delete formData.nonlinear_solver
    //   delete schema.properties.nonlinear_solver
    //   delete formData.linear_solver
    //   delete schema.properties.linear_solver
    // }

    let newState;
    if (deepIsEqual(formData, this.opeData)) {
      console.log("NOT CHANGED");
      newState = update(this.state, {
        //schema: {$set: schema},
        formData: {$set: formData},
        status: {$set: this.opeStatus}});
    } else {
      newState = update(this.state, {
        //schema: {$set: schema},
        formData: {$set: formData},
        status: {$set: "PENDING"}});
    }
    this.setState(newState);
  }

  _pollOperationJob(formData) {
    this.api.pollOperationJob(this.props.ope.id,
        (job) => {
        // console.log("CHECK");
        // console.log(job);
          return job.status === 'DONE'|| job.status === 'FAILED';
        },
        (job) => {
          //console.log(job);
          this.opeData = {};
          Object.assign(this.opeData, formData);
          this.opeStatus = job.status;
          this.handleJobUpdate(job);
        },
        (error) => {console.log(error);
        });
  }

  _filterFormOptions(options) {
    const filteredOptions = {};
    const re = new RegExp(`^${options['driver']}`);
    for (const opt in options) {
      if (opt === "name" || opt === "host" || opt === "driver") {
        filteredOptions[opt] = options[opt];
      } else if (opt.match(re)) {
        filteredOptions[opt] = options[opt];
      }
    }
    return filteredOptions;
  }

  _toFormOptions(driver, options) {
    const formOptions = {};
    formOptions[driver] = options.reduce((acc, val) => {
      switch (OPTTYPES[val['name']]) {
        case "boolean":
          acc[val['name']] = (val['value']==='true');
          break;
        case "integer":
          acc[val['name']] = parseInt(val['value']);
          break;
        case "number":
          acc[val['name']] = parseFloat(val['value']);
          break;
        default:
          acc[val['name']] = val['value'];
      }
      return acc;
    }, {});
    return formOptions;
  }

  render() {
    //console.log(this.state.log);
    const lines = this.state.log.split('\n').map((l, i) => {
      let count = Math.max(this.state.log_count-100, 0)+i;
      let line = `#${count}  ${l}`
      return ( <LogLine key={count} line={line}/> );
    });

    let btnStatusClass = this.state.status === "DONE"?"btn btn-success":"btn btn-danger";
    let btnIcon = <i className="fa fa-exclamation-triangle" />;
    if (this.state.status === "DONE") {
      btnIcon = <i className="fa fa-check"/>;
    }
    if (this.state.status === "RUNNING" || this.state.status === "STARTED") {
      btnStatusClass = "btn btn-info";
      btnIcon = <i className="fa fa-cog fa-spin"/>;
    }
    if (this.state.status === "PENDING") {
      btnStatusClass = "btn btn-info";
      btnIcon = <i className="fa fa-question"/>;
    }
    const active = (this.state.status === "RUNNING" || this.state.status === "STARTED");

    let urlOnClose = `/analyses/${this.props.mda.id}`;
    if (this.state.cases.length > 0) {
      urlOnClose = `/operations/${this.props.ope.id}`;
    }

    let startTime = "?";
    if (this.state.startInMs) {
      startTime = (new Date(this.state.startInMs)).toLocaleString("en-GB");
    }

    let elapsed = "?";
    if (this.state.startInMs && this.state.endInMs) {
      elapsed = Math.ceil((this.state.endInMs - this.state.startInMs)/1000);
    }
    //console.log("START: "+this.state.startInMs+"    END: "+this.state.endInMs);

    return (
      <div>
        <form className="button_to" method="get" action={this.api.url(urlOnClose)}>
          <button className="btn float-right" type="submit">
            <i className="fa fa-times-circle" /> Close
          </button>
        </form>

        <h1>Operation on {this.props.mda.name}</h1>
        <h2>Specification</h2>
        <div className="editor-section col-4">
          <Form schema={this.state.schema} formData={this.state.formData} uiSchema={UI_SCHEMA}
            onSubmit={this.handleRun} onChange={this.handleChange} >
            <div className="form-group">
              <button type="submit" className="btn btn-primary" disabled={active}>Run</button>
              <button type="button" className="ml-1 btn btn-secondary" disabled={!active} onClick={this.handleAbort}>Abort</button>
            </div>
          </Form>
        </div>

        <h2>Status</h2>

        <div className="editor-section">
          <div className="btn-group ml-2" role="group">
            <button className={btnStatusClass + " btn-primary"} style={{width: "120px"}}
              type="button" data-toggle="collapse" data-target="#collapseListing" aria-expanded="false">
              {btnIcon}<span className="ml-1">{this.state.status}</span>
            </button>
          </div>
          <div className="btn-group ml-2" role="group">
            <strong>Started on</strong>: {startTime}
          </div>
          <div className="btn-group ml-2" role="group">
            <strong>{(this.state.status==="RUNNING")?"Elapsed":"Ended after"}</strong>: {elapsed}s
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
      openmdao: PropTypes.object.isRequired
    }),
  }),
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
      start_in_ms: PropTypes.number,
      end_in_ms: PropTypes.number,
    }),
  }),
};

export default Runner;
