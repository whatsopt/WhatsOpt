import React from 'react';
import PropTypes from 'prop-types';
import * as caseUtils from '../../utils/cases.js';

class VariableList extends React.Component {
  render() {
    const varnames = this.props.cases.map((c) => {
      const label = caseUtils.label(c);
      const selected = this.props.selection.includes(c);
      return (<div key={label} className="form-check form-check-inline">
        <input className="form-check-input" type="checkbox" name={label} checked={selected}
          onChange={this.props.onSelectionChange}/>
        <label className="form-check-label" htmlFor={label}>{label}</label>
      </div>);});

    return (
      <div className="editor-section">
        <label className="editor-header">{this.props.title}</label>
        <div>{varnames}</div>
      </div>
    );
  }
};

VariableList.propTypes = {
  cases: PropTypes.array.isRequired,
  title: PropTypes.string.isRequired,
  selection: PropTypes.array.isRequired,
  onSelectionChange: PropTypes.func.isRequired,
};

class VariableSelector extends React.Component {
  render() {
    let stateVars;
    if (this.props.cases.c.length > 0) {
      stateVars = (
        <VariableList cases={this.props.cases.c} title="State Variables"
                      selection={this.props.selCases.c} onSelectionChange={this.props.onSelectionChange}/>
      );
    }
    return (<div className='container-fluid'>
      <VariableList cases={this.props.cases.i} title="Design Variables"
        selection={this.props.selCases.i} onSelectionChange={this.props.onSelectionChange}/>
      <VariableList cases={this.props.cases.o} title="Response Variables"
        selection={this.props.selCases.o} onSelectionChange={this.props.onSelectionChange}/>
      {stateVars}
    </div>);
  }
};

VariableSelector.propTypes = {
  cases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }),
  selCases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }),
  onSelectionChange: PropTypes.func.isRequired,
};


export default VariableSelector;
