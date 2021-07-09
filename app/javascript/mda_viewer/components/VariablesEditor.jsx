import React from 'react';
import PropTypes from 'prop-types';
import {
  useTable, useSortBy, usePagination, useGlobalFilter,
} from 'react-table';
import { RIEInput, RIESelect } from './riek/src';
import VariablesPagination from './VariablesPagination';
import VariablesGlobalFilter from './VariablesGlobalFilter';

const CELL_CLASSNAME = 'react-table-cell';
// const EDITABLE_CELL_CLASSNAME = 'bg-light';
const EDITABLE_CELL_CLASSNAME = 'editable-react-table-cell';

function _computeRoleSelection(conn) {
  const options = [
    { id: 'parameter', text: 'Parameter' },
    { id: 'design_var', text: 'Design Variable' },
    { id: 'uncertain_var', text: 'Uncertain Variable' },

    { id: 'response', text: 'Response' },
    { id: 'response_of_interest', text: 'Response of interest' },
    { id: 'min_objective', text: 'Min Objective' },
    { id: 'max_objective', text: 'Max Objective' },
    { id: 'ineq_constraint', text: 'Neg Constraint' },
    { id: 'pos_constraint', text: 'Pos Constraint' },
    { id: 'eq_constraint', text: 'Eq Constraint' },
    { id: 'constraint', text: 'Constraint' },
    { id: 'state_var', text: 'State Variable' }];
  if (conn.role === 'parameter' || conn.role === 'design_var' || conn.role === 'uncertain_var') {
    options.splice(3); // remove outputs and state vars
  } else if (conn.role !== 'state_var') {
    options.splice(options.length - 1, 1); // remove state_var
    options.splice(0, 3); // remove inputs
  }
  return options;
}

// eslint-disable-next-line no-unused-vars
function _computeTypeSelection(conn) {
  const options = [
    { id: 'Float', text: 'Float' },
    { id: 'Integer', text: 'Integer' },
    { id: 'String', text: 'String' },
  ];
  return options;
}

function CheckButtonCell({
  cell: { value },
  row: { index },
  data: connections,
  onConnectionChange,
  limited,
}) {
  const isChecked = connections[index].active;
  return (
    <input
      type="checkbox"
      value={value}
      checked={isChecked}
      onChange={() => onConnectionChange(connections[index].id,
        { active: !isChecked })}
      disabled={limited}
    />
  );
}

CheckButtonCell.propTypes = {
  cell: PropTypes.shape({
    value: PropTypes.bool.isRequired,
  }).isRequired,
  row: PropTypes.shape({
    index: PropTypes.number.isRequired,
  }).isRequired,
  data: PropTypes.array.isRequired,
  onConnectionChange: PropTypes.func.isRequired,
  limited: PropTypes.bool.isRequired,
};

function ReadonlyCell({
  cell: { value },
  row: { index },
  column: { id },
  data: connections,
}) {
  let textStyle = CELL_CLASSNAME;
  textStyle += connections[index].active ? '' : ' text-inactive';
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
    if (title) {
      textStyle += ' table-tooltip';
      return (<span className={textStyle} title={title} data-original-title={title}>{info}</span>);
    }
  }
  return (<span className={textStyle}>{info}</span>);
}

ReadonlyCell.propTypes = {
  cell: PropTypes.object.isRequired,
  row: PropTypes.object.isRequired,
  column: PropTypes.object.isRequired,
  data: PropTypes.array.isRequired,
};

function _uqLabelOf(uq) {
  const { kind, options_attributes } = uq;
  const options = options_attributes.map((opt) => opt.value);
  return `${kind[0]}(${options.join(', ')})`;
}

function ButtonCell({
  /* cell, */
  row,
  column,
  data: connections,
  onConnectionChange,
  isEditing,
}) {
  const { index } = row;
  const {
    name, role, shape, uq,
  } = connections[index];
  let label = uq.length > 0 ? _uqLabelOf(uq[0]) : '';
  label = uq.length > 1 ? `[${label}, ...]` : label;
  if (isEditing) {
    const isEditable = (role === 'uncertain_var');
    if (isEditable) {
      return (
        <button
          type="button"
          className={`btn btn-sm ${CELL_CLASSNAME} ${EDITABLE_CELL_CLASSNAME}`}
          style={{ paddingTop: 0, paddingBottom: 0 }}
          onClick={() => {
            if (shape === '1' || shape === '(1,)') {
              // eslint-disable-next-line no-undef
              $(`#distributionModal-${name}`).modal('show');
            } else {
              // eslint-disable-next-line no-undef
              $(`#distributionListModal-${name}`).modal('show');
            }
          }}
        >
          {label || 'No'}
        </button>
      );
    }
  }
  return ReadonlyCell({
    cell: { value: label }, row, column, data: connections, onConnectionChange, isEditing,
  });
}

function EditableCell({
  cell,
  row,
  column,
  data: connections,
  onConnectionChange,
  isEditing,
  limited,
  cellToFocus,
}) {
  const { value } = cell;
  const { index } = row;
  const { id } = column;
  if (isEditing && !(limited && id === 'type') && connections[index].active) {
    let selectOptions;
    if (id === 'role') {
      selectOptions = _computeRoleSelection(connections[index]);
    }
    if (id === 'type') {
      selectOptions = _computeTypeSelection(connections[index]);
    }

    const myRef = React.useRef(null);

    if (selectOptions) {
      const selected = selectOptions.filter((choice) => choice.id === value);
      return (
        <RIESelect
          className={`${CELL_CLASSNAME} ${EDITABLE_CELL_CLASSNAME}`}
          value={{ id: value, text: selected.length > 0 ? selected[0].text : 'undefined' }}
          change={(attr) => {
            const change = {};
            change[id] = attr[id].id;
            onConnectionChange(connections[index].id, change);
          }}
          propName={id}
          afterFinish={() => {
            // eslint-disable-next-line no-param-reassign
            cellToFocus.current = null;
            // console.log(cellToFocus.current);
          }}
          afterStart={() => {
            // eslint-disable-next-line no-param-reassign
            cellToFocus.current = { index, id };
            // console.log(cellToFocus.current);
          }}
          ref={myRef}
          shouldBlockWhileLoading
          options={selectOptions}
        />
      );
    }

    React.useEffect(() => {
      if (cellToFocus.current
        && cellToFocus.current.index === index
        && cellToFocus.current.id === id) {
        if (myRef.current.myRef.current) { // defensive programming
          myRef.current.myRef.current.click();
        }
      }
    });

    // Editable fields regarding variable role
    const { role } = connections[index];
    const isEditable = (((id === 'name' || id === 'shape') && !limited) || id === 'desc' || id === 'units'
      || id === 'ref' || id === 'ref0' || id === 'res_ref')
      || (role === 'state_var' && id === 'init')
      || (role === 'response' && id === 'init')
      || (role === 'ineq_constraint' && id === 'upper')
      || (role === 'pos_constraint' && id === 'lower')
      || (role === 'eq_constraint' && id === 'init')
      || (role === 'constraint' && (id === 'lower' || id === 'upper'))
      || (role === 'parameter' && (id === 'init' || id === 'lower' || id === 'upper'))
      || (role === 'design_var' && (id === 'init' || id === 'lower' || id === 'upper'))
      || (role === 'uncertain_var' && (id === 'init' || id === 'uq'));
    if (isEditable) {
      return (
        <RIEInput
          editProps={{ size: 8 }}
          className={`${CELL_CLASSNAME} ${EDITABLE_CELL_CLASSNAME}`}
          value={value || ''}
          change={(attr) => onConnectionChange(connections[index].id, attr)}
          propName={id}
          afterFinish={() => {
            // eslint-disable-next-line no-param-reassign
            cellToFocus.current = null;
            // console.log(cellToFocus.current);
          }}
          afterStart={() => {
            // eslint-disable-next-line no-param-reassign
            cellToFocus.current = { index, id };
            // console.log(cellToFocus.current);
          }}
          ref={myRef}
          shouldBlockWhileLoading
        />
      );
    }
  }
  return ReadonlyCell({
    cell, row, column, data: connections, onConnectionChange, isEditing,
  });
}

// Set our editable cell renderer as the default Cell renderer
const defaultColumn = {
  Cell: EditableCell,
};

/* eslint-disable react/jsx-props-no-spreading */
// Be sure to pass our updateMyData and the skipPageReset option
function Table({
  columns, data,
  onConnectionChange, isEditing, limited, useScaling,
}) {
  // For this example, we're using pagination to illustrate how to stop
  // the current page from resetting when our data changes
  // Otherwise, nothing is different here.
  const cellToFocus = React.useRef({ index: null, id: null });

  const hiddenColumns = [];
  if (!isEditing) {
    hiddenColumns.push('active', 'desc', 'type');
  }
  if (!useScaling) {
    hiddenColumns.push('ref', 'ref0', 'res_ref');
  }

  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    prepareRow,
    page, // instead of rows,
    preGlobalFilteredRows,
    globalFilteredRows,
    setGlobalFilter,

    // The rest of these things are super handy, too ;)
    canPreviousPage,
    canNextPage,
    pageOptions,
    pageCount,
    gotoPage,
    nextPage,
    previousPage,
    setPageSize,
    state: { pageIndex, pageSize, globalFilter },
  } = useTable(
    {
      columns,
      data,
      defaultColumn,
      onConnectionChange,
      isEditing,
      limited,
      useScaling,
      cellToFocus,
      initialState: { hiddenColumns },
      autoResetPage: false,
      autoResetSortBy: false,
    },
    useGlobalFilter,
    useSortBy,
    usePagination,
  );

  //            From, Name, Role, Shape, Units, Init, Lower, Upper, UQ
  let colWidths = ['10', '30', '10', '5', '5', '10', '10', '10', '10'];
  if (isEditing) {
    //         # From Name Role Description Type Shape Units Init Lower Upper UQ
    colWidths = ['2', '10', '36', '10', '13', '5', '5', '5', '8', '8', '8', '10'];
  }
  if (isEditing && useScaling) {
    //   #  From Name Role Description Type  Shape  Units  Init  Lower  Upper UQ, Ref, Ref0, Res.Ref
    colWidths = ['2', '5', '20', '10', '13', '5', '5', '5', '5', '5', '5', '10', '5', '5', '5'];
  }

  let table_layout = 'auto';
  if (isEditing) {
    table_layout = 'fixed';
  }

  const tableProps = {
    style: { tableLayout: table_layout },
    ...getTableProps(),
  };

  return (
    <div className="container-fluid">
      <div className="editor-section row">
        <div className="col-4">
          <VariablesGlobalFilter
            globalFilteredRows={globalFilteredRows}
            globalFilter={globalFilter}
            setGlobalFilter={setGlobalFilter}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-12">
          <table className="connections table table-striped table-sm table-hover col" {...tableProps}>
            <thead>
              {headerGroups.map((headerGroup) => (
                <tr {...headerGroup.getHeaderGroupProps()}>
                  {headerGroup.headers.map((column, i) => {
                    const cprops = {
                      width: `${colWidths[i]}% `,
                      ...column.getHeaderProps(column.getSortByToggleProps()),
                    };
                    const sortSymbol = (column.isSortedDesc ? ' 🔽' : ' 🔼');
                    return (
                      <th {...cprops}>
                        {column.render('Header')}
                        <span>
                          {column.isSorted
                            ? sortSymbol
                            : ''}
                        </span>
                      </th>
                    );
                  })}
                </tr>
              ))}
            </thead>
            <tbody {...getTableBodyProps()}>
              {page.map( // {rows.map(
                (row /* i */) => {
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
        </div>
      </div>
      <div className="row">
        <div className="col-12">
          <VariablesPagination
            canPreviousPage={canPreviousPage}
            canNextPage={canNextPage}
            pageOptions={pageOptions}
            pageCount={pageCount}
            gotoPage={gotoPage}
            nextPage={nextPage}
            previousPage={previousPage}
            setPageSize={setPageSize}
            pageIndex={pageIndex}
            pageSize={pageSize}
          />
        </div>
      </div>
    </div>
  );
}

Table.propTypes = {
  columns: PropTypes.array.isRequired,
  data: PropTypes.array.isRequired,
  onConnectionChange: PropTypes.func.isRequired,
  isEditing: PropTypes.bool.isRequired,
  limited: PropTypes.bool.isRequired,
  useScaling: PropTypes.bool.isRequired,
};

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
  }, []);

  const {
    db, filter, isEditing, limited, useScaling, onConnectionChange,
  } = props;

  const connections = db.computeConnections(filter);

  const columns = React.useMemo(
    () => [
      {
        Header: '#',
        accessor: 'active',
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
        Header: 'UQ',
        accessor: (/* row */) => '',
        Cell: ButtonCell,
      },
      {
        Header: 'Ref',
        accessor: 'ref',
      },
      {
        Header: 'Ref0',
        accessor: 'ref0',
      },
      {
        Header: 'Res.Ref',
        accessor: 'res_ref',
      },
    ],
    [isEditing, limited, useScaling],
  );

  return (
    <Table
      columns={columns}
      data={connections}
      onConnectionChange={onConnectionChange}
      isEditing={isEditing}
      limited={limited}
      useScaling={useScaling}
    />
  );
}

VariablesEditor.propTypes = {
  isEditing: PropTypes.bool.isRequired,
  limited: PropTypes.bool,
  db: PropTypes.object.isRequired,
  filter: PropTypes.object.isRequired,
  onConnectionChange: PropTypes.func.isRequired,
  useScaling: PropTypes.bool.isRequired,
};

VariablesEditor.defaultProps = {
  limited: true,
};

export default VariablesEditor;
