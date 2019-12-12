import React from 'react';
import PropTypes from 'prop-types';
import ReactTable from 'react-table';
import { RIEInput, RIESelect } from './riek/src';

function _computeRoleSelection(conn) {
  const options = [{ id: 'parameter', text: 'Parameter' },
    { id: 'design_var', text: 'Design Variable' },
    { id: 'response', text: 'Response' },
    { id: 'response_of_interest', text: 'Response of interest' },
    { id: 'min_objective', text: 'Min Objective' },
    { id: 'max_objective', text: 'Max Objective' },
    { id: 'ineq_constraint', text: 'Neg Constraint' },
    { id: 'eq_constraint', text: 'Eq Constraint' },
    { id: 'state_var', text: 'State Variable' }];
  if (conn.role === 'parameter' || conn.role === 'design_var') {
    options.splice(2, 6);
    //      if (conn.type === "String") {
    //        options.splice(options.length-1, 1);
    //      }
  } else if (conn.role !== 'state_var') {
    options.splice(options.length - 1, 1);
    options.splice(0, 2);
  }
  return options;
}

// eslint-disable-next-line no-unused-vars
function _computeTypeSelection(conn) {
  const options = [{ id: 'Float', text: 'Float' },
    { id: 'Integer', text: 'Integer' },
    { id: 'String', text: 'String' }];
  //    if (driver !== conn.fromId) {
  //      options.splice(2, 1); // suppress String, String only as parameter
  //    }
  return options;
}

function renderHeader(_cellInfo, title) {
  return (<strong>{title}</strong>);
}
class VariablesEditor extends React.Component {
  constructor(props) {
    super(props);

    this.renderEditable = this.renderEditable.bind(this);
    this.renderReadonly = this.renderReadonly.bind(this);
    this.renderCheckButton = this.renderCheckButton.bind(this);
  }

  componentDidMount() {
    // eslint-disable-next-line no-undef
    $('.table-tooltip').attr('data-toggle', 'tooltip');
    // eslint-disable-next-line no-undef
    $(() => { $('.table-tooltip').tooltip({ placement: 'right' }); });
  }

  componentWillUnmount() {
    // eslint-disable-next-line no-undef
    $('.table-tooltip').tooltip('dispose');
  }

  renderCheckButton(cellInfo) {
    const isChecked = this.connections[cellInfo.index].active;
    const { onConnectionChange } = this.props;
    return (
      <input
        type="checkbox"
        value="true"
        checked={isChecked}
        onChange={() => onConnectionChange(this.connections[cellInfo.index].id,
          { active: !isChecked })}
      />
    );
  }

  renderEditable(cellInfo, selectOptions) {
    const { isEditing, onConnectionChange } = this.props;
    if (isEditing && this.connections[cellInfo.index].active) {
      if (selectOptions) {
        const id = this.connections[cellInfo.index][cellInfo.column.id];
        const selected = selectOptions.filter((choice) => choice.id === id);
        return (
          <RIESelect
            value={{ id, text: selected.length > 0 ? selected[0].text : 'undefined' }}
            change={(attr) => {
              const change = {};
              change[cellInfo.column.id] = attr[cellInfo.column.id].id;
              onConnectionChange(this.connections[cellInfo.index].id, change);
            }}
            propName={cellInfo.column.id}
            shouldBlockWhileLoading
            options={selectOptions}
          />
        );
      }
      return (
        <RIEInput
          className="react-table-cell"
          value={this.connections[cellInfo.index][cellInfo.column.id] || ''}
          change={(attr) => onConnectionChange(this.connections[cellInfo.index].id, attr)}
          propName={cellInfo.column.id}
          shouldBlockWhileLoading
        />
      );
    }
    return this.renderReadonly(cellInfo, selectOptions);
  }

  renderReadonly(cellInfo, selectOptions) {
    let textStyle = this.connections[cellInfo.index].active ? '' : 'text-inactive';
    let info = this.connections[cellInfo.index][cellInfo.column.id];
    if (selectOptions) {
      for (let i = 0; i < selectOptions.length; i += 1) {
        if (info === selectOptions[i].id) {
          info = selectOptions[i].text;
          break;
        }
      }
    }
    if (cellInfo.column.id === 'name') {
      const title = this.connections[cellInfo.index].desc;
      textStyle += ' table-tooltip';
      return (<span className={textStyle} title={title} data-original-title={title}>{info}</span>);
    }
    return (<span className={textStyle}>{info}</span>);
  }

  render() {
    const {
      db, filter, isEditing, useScaling,
    } = this.props;
    this.connections = db.computeConnections(filter);

    const columns = [
      {
        Header: (cellInfo) => renderHeader(cellInfo, 'From'),
        accessor: 'from',
        Cell: (cellInfo) => this.renderReadonly(cellInfo),
      },
      {
        Header: (cellInfo) => renderHeader(cellInfo, 'Name'),
        accessor: 'name',
        minWidth: 200,
        Cell: (cellInfo) => this.renderEditable(cellInfo),
      },
      {
        Header: (cellInfo) => renderHeader(cellInfo, 'Role'),
        accessor: 'role',
        minWidth: 150,
        Cell: (cellInfo) => this.renderEditable(cellInfo,
          _computeRoleSelection(this.connections[cellInfo.index])),
      },
      {
        Header: (cellInfo) => renderHeader(cellInfo, 'Type'),
        accessor: 'type',
        Cell: (cellInfo) => this.renderEditable(cellInfo,
          _computeTypeSelection(this.connections[cellInfo.index])),
      },
      {
        Header: (cellInfo) => renderHeader(cellInfo, 'Shape'),
        accessor: 'shape',
        Cell: (cellInfo) => this.renderEditable(cellInfo),
      },
      {
        Header: (cellInfo) => renderHeader(cellInfo, 'Units'),
        accessor: 'units',
        Cell: (cellInfo) => this.renderEditable(cellInfo),
      },
      {
        Header: (cellInfo) => renderHeader(cellInfo, 'Init'),
        accessor: 'init',
        Cell: (cellInfo) => this.renderEditable(cellInfo),
      },
      {
        Header: (cellInfo) => renderHeader(cellInfo, 'Lower'),
        accessor: 'lower',
        Cell: (cellInfo) => this.renderEditable(cellInfo),
      },
      {
        Header: (cellInfo) => renderHeader(cellInfo, 'Upper'),
        accessor: 'upper',
        Cell: (cellInfo) => this.renderEditable(cellInfo),
      },
    ];
    if (isEditing) {
      columns.splice(0, 0, {
        Header: (cellInfo) => renderHeader(cellInfo, '#'),
        accessor: 'active',
        maxWidth: 25,
        Cell: this.renderCheckButton,
      });
      columns.splice(5, 0, {
        Header: (cellInfo) => renderHeader(cellInfo, 'Description'),
        accessor: 'desc',
        Cell: (cellInfo) => this.renderEditable(cellInfo),
      });
    }
    if (useScaling) {
      columns.push(...[
        {
          Header: (cellInfo) => renderHeader(cellInfo, 'Ref'),
          accessor: 'ref',
          Cell: (cellInfo) => this.renderEditable(cellInfo),
        },
        {
          Header: (cellInfo) => renderHeader(cellInfo, 'Ref0'),
          accessor: 'ref0',
          Cell: (cellInfo) => this.renderEditable(cellInfo),
        },
        {
          Header: (cellInfo) => renderHeader(cellInfo, 'Res.Ref'),
          accessor: 'res_ref',
          Cell: (cellInfo) => this.renderEditable(cellInfo),
        },
      ]);
    }
    return (
      <div className="mt-3">
        <ReactTable
          data={this.connections}
          columns={columns}
          className="-striped -highlight"
          showPagination={false}
          pageSize={this.connections.length}
        />
      </div>
    );
  }
}

VariablesEditor.propTypes = {
  isEditing: PropTypes.bool.isRequired,
  db: PropTypes.object.isRequired,
  filter: PropTypes.object.isRequired,
  onConnectionChange: PropTypes.func.isRequired,
  useScaling: PropTypes.bool.isRequired,
};

export default VariablesEditor;
