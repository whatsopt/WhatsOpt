import React from 'react';
import PropTypes from 'prop-types';
import ReactTable from 'react-table';
import {RIEInput, RIESelect} from '@attently/riek';

class VariablesEditor extends React.Component {
  constructor(props) {
    super(props);

    this.renderEditable = this.renderEditable.bind(this);
    this.renderReadonly = this.renderReadonly.bind(this);
    this.renderCheckButton = this.renderCheckButton.bind(this);
  }

  componentDidMount() {
    $(".table-tooltip").attr("data-toggle", "tooltip");
    $(() => {$('.table-tooltip').tooltip({placement: 'right'});});
  }

  componentWillUnmount() {
    $('.table-tooltip').tooltip('dispose');
  }

  render() {
    this.connections = this.props.db.computeConnections(this.props.filter);

    const columns = [
      {
        Header: (cellInfo) => this.renderHeader(cellInfo, 'From'),
        accessor: "from",
        Cell: (cellInfo) => this.renderReadonly(cellInfo),
      },
      {
        Header: (cellInfo) => this.renderHeader(cellInfo, 'To'),
        accessor: "to",
        minWidth: 200,
        Cell: (cellInfo) => this.renderReadonly(cellInfo),
      },
      {
        Header: (cellInfo) => this.renderHeader(cellInfo, 'Name'),
        accessor: "name",
        minWidth: 200,
        Cell: this.renderEditable,
      },
      {
        Header: (cellInfo) => this.renderHeader(cellInfo, 'Role'),
        accessor: "role",
        minWidth: 150,
        Cell: (cellInfo) => this.renderEditable(cellInfo,
            this._computeRoleSelection(this.connections[cellInfo.index])),
      },
      {
        Header: (cellInfo) => this.renderHeader(cellInfo, 'Type'),
        accessor: "type",
        Cell: (cellInfo) => this.renderEditable(cellInfo,
            this._computeTypeSelection(this.connections[cellInfo.index])),
      },
      {
        Header: (cellInfo) => this.renderHeader(cellInfo, 'Shape'),
        accessor: "shape",
        Cell: this.renderEditable,
      },
      {
        Header: (cellInfo) => this.renderHeader(cellInfo, 'Units'),
        accessor: "units",
        Cell: this.renderEditable,
      },
      {
        Header: (cellInfo) => this.renderHeader(cellInfo, 'Init'),
        accessor: "init",
        Cell: this.renderEditable,
      },
      {
        Header: (cellInfo) => this.renderHeader(cellInfo, 'Lower'),
        accessor: "lower",
        Cell: this.renderEditable,
      },
      {
        Header: (cellInfo) => this.renderHeader(cellInfo, 'Upper'),
        accessor: "upper",
        Cell: this.renderEditable,
      },
    ];
    if (this.props.isEditing) {
      columns.splice(0, 0, {
        Header: (cellInfo) => this.renderHeader(cellInfo, '#'),
        accessor: "active",
        maxWidth: 25,
        Cell: this.renderCheckButton,
      });
      columns.splice(5, 0, {
        Header: (cellInfo) => this.renderHeader(cellInfo, 'Description'),
        accessor: "desc",
        Cell: this.renderEditable,
      });
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
  };

  renderHeader(cellInfo, title) {
    return (<strong>{title}</strong>);
  }

  renderCheckButton(cellInfo) {
    const isChecked = this.connections[cellInfo.index].active;
    return (<input type="checkbox" value="true" checked={isChecked}
      onChange={() => this.props.onConnectionChange(this.connections[cellInfo.index].id,
          {active: !isChecked})}/>);
  }

  renderEditable(cellInfo, selectOptions) {
    if (this.props.isEditing && this.connections[cellInfo.index].active) {
      if (selectOptions) {
        const id = this.connections[cellInfo.index][cellInfo.column.id];
        const selected = selectOptions.filter((choice) => choice.id === id);
        return ( <RIESelect
          value={{id: id, text: selected.length>0?selected[0].text:"undefined"}}
          change={ (attr) => {
            const change = {};
            change[cellInfo.column.id] = attr[cellInfo.column.id].id;
            this.props.onConnectionChange(this.connections[cellInfo.index].id, change);
          } }
          propName={cellInfo.column.id}
          shouldBlockWhileLoading
          options={selectOptions}/> );
      } else {
        return ( <RIEInput
          className="react-table-cell"
          defaultValue=""
          value={this.connections[cellInfo.index][cellInfo.column.id]}
          change={(attr) => this.props.onConnectionChange(this.connections[cellInfo.index].id, attr)}
          propName={cellInfo.column.id}
          shouldBlockWhileLoading /> );
      }
    } else {
      return this.renderReadonly(cellInfo, selectOptions);
    }
  };

  renderReadonly(cellInfo, selectOptions) {
    let textStyle = this.connections[cellInfo.index].active?"":"text-inactive";
    let info = this.connections[cellInfo.index][cellInfo.column.id];
    if (selectOptions) {
      for (let i=0; i<selectOptions.length; i++) {
        if (info === selectOptions[i].id) {
          info = selectOptions[i].text;
          break;
        }
      }
    }
    if (cellInfo.column.id === 'name') {
      const title = this.connections[cellInfo.index]['desc'];
      textStyle += " table-tooltip";
      return (<span className={textStyle} title={title} data-original-title={title}>{info}</span>);
    } else {
      return (<span className={textStyle}>{info}</span>);
    }
  }

  _computeTypeSelection(conn) {
    const options = [{id: 'Float', text: 'Float'},
      {id: 'Integer', text: 'Integer'},
      {id: 'String', text: 'String'}];
    //    if (driver !== conn.fromId) {
    //      options.splice(2, 1); // suppress String, String only as parameter
    //    }
    return options;
  }

  _computeRoleSelection(conn) {
    const options = [{id: 'parameter', text: 'Parameter'},
      {id: 'design_var', text: 'Design Variable'},
      {id: 'response', text: 'Response'},
      {id: 'min_objective', text: 'Min Objective'},
      {id: 'max_objective', text: 'Max Objective'},
      {id: 'ineq_constraint', text: 'Neg Constraint'},
      {id: 'eq_constraint', text: 'Eq Constraint'},
      {id: 'state_var', text: 'State Variable'}];
    if (conn.role == "parameter" || conn.role == "design_var") {
      options.splice(2, 6);
      //      if (conn.type === "String") {
      //        options.splice(options.length-1, 1);
      //      }
    } else if (conn.role !== "state_var") {
      options.splice(options.length-1, 1);
      options.splice(0, 2);
    }
    return options;
  }
}

VariablesEditor.propTypes = {
  isEditing: PropTypes.bool,
  db: PropTypes.object.isRequired,
  filter: PropTypes.object.isRequired,
  onConnectionChange: PropTypes.func,
};

export default VariablesEditor;
