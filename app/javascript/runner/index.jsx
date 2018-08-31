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
  lhs_nbpts: "integer",    
  slsqp_tol: "number",
  slsqp_disp: "boolean",
  slsqp_maxiter: "integer"
};
const OPTDEFAULTS = {
  lhs_nbpts: 50,
  slsqp_tol: 1e-6,
  slsqp_maxiter: 100,
  slsqp_disp: true,
}

const FORM = {
  "type": "object",
  "properties": {
    "name": {"type": "string", "title": "Operation name"},
    "host": {"type": "string", "title": "Analysis Server"},
    "driver" : {"type": "string", "title": "Driver", 
                "enum": ["runonce", "lhs", "slsqp"],
                "enumNames": ["RunOnce", "LHS", "SLSQP"],
                "default": "runonce"
               }},
  "required": [ "name", "host", "driver" ],
  "dependencies": {
    "driver": {
      "oneOf": [
        {
          "properties": {"driver": {"enum": ["runonce"]}}
        },   
        {
          "properties": {"driver": {"enum": ["lhs"]},
                         "lhs_nbpts": {"title": "Number of sampling points", 
                                       "type": OPTTYPES.lhs_nbpts,
                                       "default": OPTDEFAULTS.lhs_nbpts}, },
        },   
        {
          "properties": {"driver": {"enum": ["slsqp"]},
                         "slsqp_tol": {"title": "Objective function tolerance for stopping criterion", 
                                       "type": OPTTYPES.slsqp_tol, 
                                       "default": OPTDEFAULTS.slsqp_tol },
                         "slsqp_disp": {"title": "Print convergence messages", 
                                        "type": OPTTYPES.slsqp_disp, 
                                        "default": OPTDEFAULTS.slsqp_disp}, 
                         "slsqp_maxiter": {"title": "Maximum of iterations", 
                                           "type": OPTTYPES.slsqp_maxiter,
                                           "default": OPTDEFAULTS.slsqp_maxiter }, },
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
    if (this.state.status === "RUNNING") {
      btnStatusClass = "btn btn-info";
      btnIcon = <i className="fa fa-cog fa-spin"/>;
    }
    if (this.state.status === "PENDING") {
      btnStatusClass = "btn btn-info";
      btnIcon = <i className="fa fa-question"/>;
    }    

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
            <button type="submit" className="btn btn-primary">Run</button>
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
