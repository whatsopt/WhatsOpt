import React from 'react';
import PropTypes from 'prop-types';
import { useTable, useSortBy } from 'react-table';
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
  { id: 'String', text: 'String' },
  ];
  return options;
}

function CheckButtonCell({
  cell: { value },
  row: { index },
  column: { id },
  data: connections,
  onConnectionChange,
}) {
  const isChecked = connections[index].active;
  return (
    <input
      type="checkbox"
      value={value}
      checked={isChecked}
      onChange={() => onConnectionChange(connections[index].id,
        { active: !isChecked })}
    />
  );
}

function ReadonlyCell({
  cell: { value },
  row: { index },
  column: { id },
  data: connections,
}) {
  let textStyle = connections[index].active ? '' : 'text-inactive';
  let info = value;
  if (id === 'role') {
    const selectOptions = _computeRoleSelection(connections[index]);
    for (let i = 0; i < selectOptions.length; i += 1) {
      if (info === selectOptions[i].id) {
        info = selectOptions[i].text;
        break;
      }
    }
  }
  if (id === 'type') {
    const selectOptions = _computeTypeSelection(connections[index]);
    for (let i = 0; i < selectOptions.length; i += 1) {
      if (info === selectOptions[i].id) {
        info = selectOptions[i].text;
        break;
      }
    }
  }
  if (id === 'name') {
    const title = connections[index].desc;
    textStyle += ' table-tooltip';
    return (<span className={textStyle} title={title} data-original-title={title}>{info}</span>);
  }
  return (<span className={textStyle}>{info}</span>);
}

function EditableCell({
  cell,
  row,
  column,
  data: connections,
  onConnectionChange,
  isEditing,
  cellToFocus,
}) {
  const { value } = cell;
  const { index } = row;
  const { id } = column;
  if (isEditing && connections[index].active) {
    let selectOptions;
    if (id === 'role') {
      selectOptions = _computeRoleSelection(connections[index]);
    }
    if (id === 'type') {
      selectOptions = _computeTypeSelection(connections[index]);
    }
    if (selectOptions) {
      const selected = selectOptions.filter((choice) => choice.id === value);
      return (
        <RIESelect
          value={{ id: value, text: selected.length > 0 ? selected[0].text : 'undefined' }}
          change={(attr) => {
            const change = {};
            change[id] = attr[id].id;
            onConnectionChange(connections[index].id, change);
          }}
          propName={id}
          shouldBlockWhileLoading
          options={selectOptions}
        />
      );
    }
    const myRef = React.useRef(null);

    React.useEffect(() => {
      if (cellToFocus.current && cellToFocus.current.index === index && cellToFocus.current.id === id) {
        myRef.current.ref.current.focus();
      }
    });

    return (
      <RIEInput
        editProps={{ size: 10 }}
        className="react-table-cell"
        value={value || ''}
        change={(attr) => onConnectionChange(connections[index].id, attr)}
        propName={id}
        afterFinish={() => {
          // eslint-disable-next-line no-param-reassign
          cellToFocus.current = null;
        }}
        afterStart={() => {
          // eslint-disable-next-line no-param-reassign
          cellToFocus.current = { index, id };
        }}
        ref={myRef}
        shouldBlockWhileLoading
      />
    );
  }
  return ReadonlyCell({
    cell, row, column, data: connections, onConnectionChange, isEditing,
  });
}

// Set our editable cell renderer as the default Cell renderer
const defaultColumn = {
  Cell: EditableCell,
};

// Be sure to pass our updateMyData and the skipPageReset option
function Table({
  columns, data, onConnectionChange, isEditing,
}) {
  // For this example, we're using pagination to illustrate how to stop
  // the current page from resetting when our data changes
  // Otherwise, nothing is different here.
  const cellToFocus = React.useRef({ index: null, id: null });

  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
  } = useTable(
    {
      columns,
      data,
      defaultColumn,
      onConnectionChange,
      isEditing,
      cellToFocus,
    },
    useSortBy
  );

  let colWidths = ['10', '15', '10', '10', '5', '5', '10', '10', '10', '5', '5', '5'];
  if (isEditing) {
    colWidths = ['3', '10', '15', '10', '10', '7', '5', '5', '10', '10', '10', '5', '5', '5'];
  }

  // Render the UI for your table
  return (
    <table className="connections table table-striped table-sm table-hover mt-3" {...getTableProps()}>
      <thead>
        {headerGroups.map((headerGroup) => (
          <tr {...headerGroup.getHeaderGroupProps()}>
            {headerGroup.headers.map((column, i) => {
              const cprops = {
                width: `${colWidths[i]}%`,
                ...column.getHeaderProps(column.getSortByToggleProps())
              };
              return (
                <th {...cprops}>
                  {column.render('Header')}
                  <span>
                    {column.isSorted
                      ? column.isSortedDesc
                        ? ' 🔽'
                        : ' 🔼'
                      : ''}
                  </span>
                </th>
              );
            })}
          </tr>
        ))}
      </thead>
      <tbody {...getTableBodyProps()}>
        {rows.map(
          (row, i) => {
            prepareRow(row);
            return (
              <tr {...row.getRowProps()}>
                {row.cells.map((cell) => <td {...cell.getCellProps()}>{cell.render('Cell')}</td>)}
              </tr>
            );
          },
        )}
      </tbody>
    </table>
  );
}

function VariablesEditor(props) {
  React.useEffect(() => {
    // eslint-disable-next-line no-undef
    $('.table-tooltip').attr('data-toggle', 'tooltip');
    // eslint-disable-next-line no-undef
    $(() => { $('.table-tooltip').tooltip({ placement: 'right' }); });

    return () => {
      // eslint-disable-next-line no-undef
      $('.table-tooltip').tooltip('dispose');
    };
  },
    []);

  const {
    db, filter, isEditing, useScaling, onConnectionChange,
  } = props;

  const connections = db.computeConnections(filter);

  const columns = React.useMemo(
    () => [
      {
        Header: '#',
        accessor: 'active',
        isVisible: isEditing,
        Cell: CheckButtonCell,
      },
      {
        Header: 'From',
        accessor: 'from',
        Cell: ReadonlyCell,
      },
      {
        Header: 'Name',
        accessor: 'name',
      },
      {
        Header: 'Role',
        accessor: 'role',
      },
      {
        Header: 'Description',
        accessor: 'desc',
        isVisible: isEditing,
      },
      {
        Header: 'Type',
        accessor: 'type',
      },
      {
        Header: 'Shape',
        accessor: 'shape',
      },
      {
        Header: 'Units',
        accessor: 'units',
      },
      {
        Header: 'Init',
        accessor: 'init',
      },
      {
        Header: 'Lower',
        accessor: 'lower',
      },
      {
        Header: 'Upper',
        accessor: 'upper',
      },
      {
        Header: 'Ref',
        accessor: 'ref',
        isVisible: useScaling,
      },
      {
        Header: 'Ref0',
        accessor: 'ref0',
        isVisible: useScaling,
      },
      {
        Header: 'Res.Ref',
        accessor: 'res_ref',
        isVisible: useScaling,
      },
    ],
    [isEditing, useScaling],
  );

  return (
    <Table
      columns={columns}
      data={connections}
      onConnectionChange={onConnectionChange}
      isEditing={isEditing}
    />
  );
}


VariablesEditor.propTypes = {
  isEditing: PropTypes.bool.isRequired,
  db: PropTypes.object.isRequired,
  filter: PropTypes.object.isRequired,
  onConnectionChange: PropTypes.func.isRequired,
  useScaling: PropTypes.bool.isRequired,
};

export default VariablesEditor;
