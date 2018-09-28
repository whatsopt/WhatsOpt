import React from 'react';
import PropTypes from 'prop-types';
import update from 'immutability-helper';
// disable actioncable: import actionCable from 'actioncable'
import Form from "react-jsonschema-form";
import CheckboxWidget from 'runner/components/CheckboxWidget'

const widgets = {
  CheckboxWidget,
//  RadioWidget,
}


class LogLine extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (<div className="listing-line">{this.props.line}</div>);
  }
}

const OPTTYPES = {
  smt_doe_lhs_nbpts: "integer",    
  scipy_optimizer_slsqp_tol: "number",
  scipy_optimizer_slsqp_disp: "boolean",
  scipy_optimizer_slsqp_maxiter: "integer",
  pyoptsparse_optimizer_snopt_tol: "number",
  pyoptsparse_optimizer_snopt_maxiter: "integer",
};
const OPTDEFAULTS = {
  smt_doe_lhs_nbpts: 50,
  scipy_optimizer_slsqp_tol: 1e-6,
  scipy_optimizer_slsqp_maxiter: 1000,
  scipy_optimizer_slsqp_disp: true,
  pyoptsparse_optimizer_snopt_tol: 1e-6,
  pyoptsparse_optimizer_snopt_maxiter: 1000,
}

const FORM = {
  "type": "object",
  "properties": {
    "name": {"type": "string", "title": "Operation name"},
    "host": {"type": "string", "title": "Analysis Server"},
    "driver" : {"type": "string", "title": "Driver", 
                "enum": ["runonce", "smt_doe_lhs", 
                         "scipy_optimizer_cobyla", 
                         "scipy_optimizer_bfgs", 
                         "scipy_optimizer_slsqp", 
                         "pyoptsparse_optimizer_conmin",
                         // "pyoptsparse_optimizer_fsqp", 
                         "pyoptsparse_optimizer_slsqp", 
                         "pyoptsparse_optimizer_psqp", 
                         "pyoptsparse_optimizer_nsga2", 
                         "pyoptsparse_optimizer_snopt"],
                "enumNames": ["RunOnce", "SMT - LHS", "Scipy - COBYLA", "Scipy - BFGS", "Scipy - SLSQP",
                              "pyOptSparse - CONMIN", 
                              // "pyOptSparse - FSQP", 
                              "pyOptSparse - SLSQP", 
                              "pyOptSparse - PSQP", "pyOptSparse - NSGA2", "pyOptSparse - SNOPT"],
                "default": "runonce"
               }},
  "required": [ "name", "host", "driver" ],
  "dependencies": {
    "driver": {
      "oneOf": [
        {
          "properties": {"driver": {"enum": ["runonce",                  
                                             "scipy_optimizer_cobyla", 
                                             "scipy_optimizer_bfgs", 
                                             "pyoptsparse_optimizer_conmin",
                                             // "pyoptsparse_optimizer_fsqp", 
                                             "pyoptsparse_optimizer_slsqp", 
                                             "pyoptsparse_optimizer_psqp", 
                                             "pyoptsparse_optimizer_nsga2"]}}
        },   
        {
          "properties": {"driver": {"enum": ["smt_doe_lhs"]},
                         "smt_doe_lhs_nbpts": {"title": "Number of sampling points", 
                                               "type": OPTTYPES.smt_doe_lhs_nbpts,
                                               "default": OPTDEFAULTS.smt_doe_lhs_nbpts}, },
        },   
        {
          "properties": {"driver": {"enum": ["scipy_optimizer_slsqp"]},
                         "scipy_optimizer_slsqp_tol": {"title": "Objective function tolerance for stopping criterion", 
                                       "type": OPTTYPES.scipy_optimizer_slsqp_tol, 
                                       "default": OPTDEFAULTS.scipy_optimizer_slsqp_tol },
                         "scipy_optimizer_slsqp_disp": {"title": "Print convergence messages", 
                                        "type": OPTTYPES.scipy_optimizer_slsqp_disp, 
                                        "default": OPTDEFAULTS.scipy_optimizer_slsqp_disp}, 
                         "scipy_optimizer_slsqp_maxiter": {"title": "Maximum of iterations", 
                                           "type": OPTTYPES.scipy_optimizer_slsqp_maxiter,
                                           "default": OPTDEFAULTS.scipy_optimizer_slsqp_maxiter }, },
        },   
        {
          "properties": {"driver": {"enum": ["pyoptsparse_optimizer_snopt"]},
                         "pyoptsparse_optimizer_snopt_tol": {"title": "Nonlinear constraint violation tolerance", 
                                                             "type": OPTTYPES.pyoptsparse_optimizer_snopt_tol, 
                                                             "default": OPTDEFAULTS.pyoptsparse_optimizer_snopt_tol },
                         "pyoptsparse_optimizer_snopt_maxiter": {"title": "Major iteration limit", 
                                          "type": OPTTYPES.pyoptsparse_optimizer_snopt_maxiter,
                                          "default": OPTDEFAULTS.pyoptsparse_optimizer_snopt_maxiter }, },
        },       
      ]  
    }  
  }
}

class Runner extends React.Component {
  constructor(props) {
    super(props);
    this.api = this.props.api;
    
    let status = (this.props.ope.job && this.props.ope.job.status) || 'DONE';;
    let log = (this.props.ope.job && this.props.ope.job.log) || '';
    
    let formData = { 
            host: this.props.ope.host, 
            name: this.props.ope.name, 
            driver: this.props.ope.driver || "runonce",
          }
    let formOptions = this._toFormOptions(this.props.ope.options);
    let optionsIds = this.props.ope.options.map(opt => opt.id);
    Object.assign(formData, formOptions);
    
    this.state = {formData: formData, 
                  optionsIds: optionsIds,
                  cases: this.props.ope.cases,
                  status: status,
                  log: log};
    
    this.handleRun = this.handleRun.bind(this); 
    this.handleAbort = this.handleAbort.bind(this); 
    this.handleChange = this.handleChange.bind(this); 
    this.handleOperationUpdate = this.handleOperationUpdate.bind(this);
  }
  
  handleRun(data) {
    let form = this._filterFormOptions(data.formData);
    //console.log("FORM DATA = "+JSON.stringify(form));
    let opeAttrs = { name: form.name, host: form.host, driver: form.driver, options_attributes: []};
    let ids = this.state.optionsIds.slice(); 
    for (let opt in form) {
      if (opt !== "name" && opt !== "host" && opt !== "driver") {
        let optionAttrs = { name: opt, value: data.formData[opt] };
        if (ids.length) {
          optionAttrs.id = ids.shift();  
        }        
        opeAttrs.options_attributes.push(optionAttrs);  
      }
    }
    ids.forEach(id => opeAttrs.options_attributes.push({id: id, _destroy: '1'}));
    //console.log("OPT ATTRS = "+JSON.stringify(opeAttrs));

    let newState = update(this.state, {status: {$set: "STARTED"}});
    this.setState(newState);  
    
    this.api.updateOperation(this.props.ope.id, opeAttrs, 
        (response) => { this.api.pollOperation(this.props.ope.id,
                        (respData) => {   
                          return (respData.job && (respData.job.status === 'DONE'|| respData.job.status === 'FAILED'))
                        },
                        (response) => { //console.log(response.data); 
                          this.handleOperationUpdate(response.data);
                        },
                        (error) => { console.log(error); });
        },
        (error) => { console.log(error); });
  }

  handleAbort() {
    this.api.killOperationJob(this.props.ope.id);
    let newState = update(this.state, {status: {$set: "ABORTED"}});
    this.setState(newState);
  }
  
  handleOperationUpdate(ope) {
    let formData = { name: ope.name, host: ope.host, driver: ope.driver, }
    let formOptions = this._toFormOptions(ope.options);
    Object.assign(formData, formOptions);
    let optionsIds = ope.options.map(opt => opt.id);
    let newState = update(this.state, {formData: {$set: formData},
                                       optionsIds: {$set: optionsIds},
                                       cases: {$set: ope.cases},
                                       status: {$set: ope.job.status}, 
                                       log: {$set: ope.job.log},
    });
    this.setState(newState);  
  }
  
  handleChange(data) {
    console.log("FORMDATA= "+JSON.stringify(data.formData));
    console.log("FILTERDATA= "+JSON.stringify(this._filterFormOptions(data.formData)));
    let newState = update(this.state, {formData: {$set: data.formData}});
    this.setState(newState);
  }
  
  _filterFormOptions = (options) => {
    let filteredOptions = {};
    let re = new RegExp(`^${options['driver']}`);
    for (let opt in options) {
      if (opt === "name" || opt === "host" || opt === "driver") {
        filteredOptions[opt] = options[opt];  
      } else if (opt.match(re)) {
        filteredOptions[opt] = options[opt];  
      } 
    }  
    return filteredOptions;
  }
  
  _toFormOptions = (options) => {
    let formOptions = options.reduce((acc, val) => {
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
        acc[val['name']] = val['value']   
      }
      return acc;
    }, {});
    return formOptions;
  }
  
  render() {
    let lines = this.state.log.split('\n').map((l, i) => {
      return ( <LogLine key={i} line={l}/> );
    });

    let btnStatusClass = this.state.status === "DONE"?"btn btn-success":"btn btn-danger";
    let btnIcon = this.state.status === "DONE"?<i className="fa fa-check"/>:<i className="fa fa-exclamation-triangle" />;
    if (this.state.status === "RUNNING" || this.state.status === "STARTED") {
      btnStatusClass = "btn btn-info";
      btnIcon = <i className="fa fa-cog fa-spin"/>;
    }
    if (this.state.status === "PENDING") {
      btnStatusClass = "btn btn-info";
      btnIcon = <i className="fa fa-question"/>;
    }
    let active = (this.state.status === "RUNNING" || this.state.status === "STARTED");

    let showEnabled=false;
    if (this.state.status === "DONE" && this.state.driver!=="runonce") {
      showEnabled=true;
    } 
    let showClass="btn btn-light";
    showClass+=showEnabled?"":" disabled"; 
    
    let urlOnClose = `/analyses/${this.props.mda.id}`;
    if (this.state.cases.length > 0) {
      urlOnClose = `/operations/${this.props.ope.id}`;  
    }
    
    return (   
      <div>
      <form className="button_to" method="get" action={this.api.url(urlOnClose)}>
        <button className="btn float-right" type="submit">
          <i className="fa fa-times-circle" /> Close
        </button>
      </form>

      <h1>Operation on {this.props.mda.name}</h1>

      <div className="editor-section">   
        <div className="btn-toolbar" role="toolbar">
          <div className="btn-group mr-2" role="group">
            <button className={btnStatusClass + " btn-primary"} style={{width: "120px"}} type="button" data-toggle="collapse"
                    data-target="#collapseListing" aria-expanded="false">
              {btnIcon}<span className="ml-1">{this.state.status}</span>
            </button>
          </div>
        </div>
        <div className="collapse" id="collapseListing">
          <div className="card card-block">
            <div className="listing">
              {lines}
            </div>
          </div>
        </div>
      </div>
      <div className="editor-section col-3">
        <Form schema={FORM} formData={this.state.formData} 
              onSubmit={this.handleRun} onChange={this.handleChange} widgets={widgets}>      
          <div className="form-group">
            <button type="submit" className="btn btn-primary" disabled={active}>Run</button>
            <button type="button" className="ml-2 btn" disabled={!active} onClick={this.handleAbort}>Abort</button>
          </div>
        </Form>
      </div>
      </div>
    );
  } 
}

Runner.propTypes = {
  mda: PropTypes.shape({
    name: PropTypes.string,
  }),
};

export default Runner;
