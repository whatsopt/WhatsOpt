import React from 'react';
import PropTypes from 'prop-types';
import * as caseUtils from '../../utils/cases';

class VariableList extends React.PureComponent {
  render() {
    const {
      cases, selection, onSelectionChange, title,
    } = this.props;
    const varnames = cases.map((c) => {
      const label = caseUtils.label(c);
      const selected = selection.includes(c);
      return (
        <div key={label} className="form-check form-check-inline">
          <input
            className="form-check-input"
            type="checkbox"
            name={label}
            checked={selected}
            onChange={onSelectionChange}
          />
          <label className="form-check-label" htmlFor={label}>{label}</label>
        </div>
      );
    });

    return (
      <div className="editor-section">
        <div className="editor-header">{title}</div>
        <div>{varnames}</div>
      </div>
    );
  }
}

VariableList.propTypes = {
  cases: PropTypes.array.isRequired,
  title: PropTypes.string.isRequired,
  selection: PropTypes.array.isRequired,
  onSelectionChange: PropTypes.func.isRequired,
};

class VariableSelector extends React.PureComponent {
  render() {
    let stateVars;
    const {
      uqMode, cases, selCases, onSelectionChange,
    } = this.props;
    if (cases.c.length > 0) {
      stateVars = (
        <VariableList
          cases={cases.c}
          title="State Variables"
          selection={selCases.c}
          onSelectionChange={onSelectionChange}
        />
      );
    }

    return (
      <div className="container-fluid">
        <VariableList
          cases={cases.i}
          title={uqMode ? 'Uncertain Variables' : 'Design Variables'}
          selection={selCases.i}
          onSelectionChange={onSelectionChange}
        />
        <VariableList
          cases={cases.o}
          title="Response Variables"
          selection={selCases.o}
          onSelectionChange={onSelectionChange}
        />
        {stateVars}
      </div>
    );
  }
}

VariableSelector.propTypes = {
  uqMode: PropTypes.bool.isRequired,
  cases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }).isRequired,
  selCases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }).isRequired,
  onSelectionChange: PropTypes.func.isRequired,
};

export default VariableSelector;
