import React from 'react';
import PropTypes from 'prop-types';
import {
  createColumnHelper,
  flexRender,
  getCoreRowModel,
  getSortedRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  useReactTable,
} from '@tanstack/react-table';
import { Tooltip } from 'bootstrap';
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
  } else {
    // options.splice(options.length - 1, 1); // remove state_var
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
  cell,
  row: { index },
  table: { options: { data: connections, meta: { limited, onConnectionChange } } },
}) {
  const isChecked = connections[index].active;
  return (
    <input
      type="checkbox"
      value={cell.getValue()}
      checked={isChecked}
      onChange={() => onConnectionChange(
        connections[index].id,
        { active: !isChecked },
      )}
      disabled={limited}
    />
  );
}

CheckButtonCell.propTypes = {
  cell: PropTypes.shape({
    getValue: PropTypes.func.isRequired,
  }).isRequired,
  row: PropTypes.shape({
    index: PropTypes.number.isRequired,
  }).isRequired,
  table: PropTypes.object.isRequired,
};

// A name for distributions: N(0, 1), U(-10, 10)
function _uqLabelOf(uq) {
  const { kind, options_attributes } = uq;
  const options = options_attributes.map((opt) => opt.value);
  return `${kind[0]}(${options.join(', ')})`;
}
function ReadonlyCell({
  cell,
  row: { index },
  column: { id },
  table: { options: { data: connections } },
}) {
  let textStyle = CELL_CLASSNAME;
  textStyle += connections[index].active ? '' : ' text-inactive';
  let info = cell.getValue();

  if (id === 'uq') {
    // Case of the UQ column: display a distribution name
    const { uq } = connections[index];
    info = uq.length > 0 ? _uqLabelOf(uq[0]) : info;
    info = uq.length > 1 ? `[${info}, ...]` : info;
  }
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
      return (<span className={textStyle} title={title} data-bs-toggle="tooltip" data-bs-placement="right" data-bs-title={title}>{info}</span>);
    }
  }
  return (<span className={textStyle}>{info}</span>);
}

ReadonlyCell.propTypes = {
  cell: PropTypes.object.isRequired,
  row: PropTypes.object.isRequired,
  column: PropTypes.object.isRequired,
  table: PropTypes.object.isRequired,
};

function ButtonCell({
  cell,
  row,
  column,
  table,
}) {
  const { options: { data: connections, meta: { isEditing } } } = table;
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
    cell, row, column, table,
  });
}

ButtonCell.propTypes = {
  cell: PropTypes.object.isRequired,
  row: PropTypes.object.isRequired,
  column: PropTypes.object.isRequired,
  table: PropTypes.object.isRequired,
};

function EditableCell({
  cell,
  row,
  column,
  table,
}) {
  const {
    options: {
      data: connections, meta: {
        onConnectionChange, isEditing, limited, cellToFocus,
      },
    },
  } = table;
  const value = cell.getValue();
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

    // const myRef = React.useRef(null);

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
          // ref={myRef}
          shouldBlockWhileLoading
          options={selectOptions}
        />
      );
    }

    // React.useEffect(() => {
    //   if (cellToFocus.current
    //     && cellToFocus.current.index === index
    //     && cellToFocus.current.id === id) {
    //     // console.log('Trying to focus on cell', { index, id });
    //     // if (myRef.current && myRef.current.myRef && myRef.current.myRef.current) { // defensive programming
    //     //   console.log('myRef.current is', myRef.current);
    //     //   console.log('myRef.current.myRef.current is', myRef.current.myRef.current);
    //     //   const input = myRef.current.myRef.current.querySelector('input');
    //     //   if (input) {
    //     //     input.focus();
    //     //     input.select();
    //     //   }
    //     // }
    //     // // if (myRef.current.myRef.current) { // defensive programming
    //     // //   myRef.current.myRef.current.click();
    //     // // }
    //   } 
    // });

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
      || (role === 'uncertain_var' && (id === 'init' || id === 'uq'))
      || (connections[index].shouldBeBounded && (id === 'lower' || id === 'upper'));
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
          // ref={myRef}
          shouldBlockWhileLoading
        />
      );
    }
  }
  return ReadonlyCell({
    cell, row, column, table,
  });
}

EditableCell.propTypes = {
  cell: PropTypes.object.isRequired,
  row: PropTypes.object.isRequired,
  column: PropTypes.object.isRequired,
  table: PropTypes.object.isRequired,
};

// Set our editable cell renderer as the default Cell renderer
const defaultColumn = {
  cell: (info) => EditableCell(info),
};

/* eslint-disable react/jsx-props-no-spreading */
function Table({
  columns, data,
  onConnectionChange, isEditing, limited, useScaling,
}) {
  const [sorting, setSorting] = React.useState([]);
  const [globalFilter, setGlobalFilter] = React.useState('');
  const [columnVisibility, setColumnVisibility] = React.useState({});

  const cellToFocus = React.useRef({ index: null, id: null });

  columnVisibility.active = isEditing;
  columnVisibility.desc = isEditing;
  columnVisibility.type = isEditing;

  columnVisibility.ref = useScaling;
  columnVisibility.ref0 = useScaling;
  columnVisibility.res_ref = useScaling;

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
  };

  const table = useReactTable({
    data,
    columns,
    defaultColumn,
    initialState: {
      columnVisibility,
    },
    state: {
      sorting,
      globalFilter,
    },
    meta: {
      isEditing,
      limited,
      useScaling,
      onConnectionChange,
      cellToFocus,
    },
    onSortingChange: setSorting,
    onGlobalFilterChange: setGlobalFilter,
    onColumnVisibilityChange: setColumnVisibility,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });

  const canPreviousPage = table.getCanPreviousPage();
  const canNextPage = table.getCanNextPage();
  const pageCount = table.getPageCount();
  const pageOptions = table.getPageOptions();
  const gotoPage = table.setPageIndex;
  const { nextPage } = table;
  const { previousPage } = table;
  const { setPageSize } = table;
  const { pageIndex } = table.getState().pagination;
  const { pageSize } = table.getState().pagination;

  return (
    <div className="container-fluid">

      <div className="row">
        <div className="editor-section row">
          <div className="col-4">
            <VariablesGlobalFilter
              globalFilteredRows={table.getFilteredRowModel().rows}
              globalFilter={globalFilter}
              setGlobalFilter={setGlobalFilter}
            />
          </div>
        </div>
        <div className="col-12">
          <table className="connections table table-striped table-sm table-hover col" {...tableProps}>
            <thead>
              {table.getHeaderGroups().map((headerGroup) => (
                <tr key={headerGroup.id}>
                  {headerGroup.headers.map((header, i) => {
                    const hprops = {
                      width: `${colWidths[i]}% `,
                    };
                    return (
                      <th key={header.id} {...hprops}>
                        {header.isPlaceholder
                          ? null
                          : (
                            // eslint-disable-next-line jsx-a11y/click-events-have-key-events
                            <div
                              {...{
                                className: header.column.getCanSort()
                                  ? 'cursor-pointer select-none'
                                  : '',
                                onClick: header.column.getToggleSortingHandler(),
                              }}
                            >
                              {flexRender(
                                header.column.columnDef.header,
                                header.getContext(),
                              )}
                              {{
                                asc: ' 🔼',
                                desc: ' 🔽',
                              }[header.column.getIsSorted()] || null}
                            </div>
                          )}
                      </th>
                    );
                  })}
                </tr>
              ))}
            </thead>
            <tbody>
              {table.getRowModel().rows.map((row) => (
                <tr key={row.id}>
                  {row.getVisibleCells().map((cell) => (
                    <td key={cell.id}>
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
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
  const {
    db, filter, isEditing, limited, useScaling, onConnectionChange,
  } = props;

  const connections = db.computeConnections(filter);

  const columnHelper = createColumnHelper();

  const columns = [
    columnHelper.accessor('active', {
      header: () => '#',
      cell: (info) => CheckButtonCell(info),
      enableGlobalFilter: false,
    }),
    columnHelper.accessor('from', {
      header: () => 'From',
      cell: (info) => ReadonlyCell(info),
    }),
    columnHelper.accessor('name', {
      header: () => 'Name',
    }),
    columnHelper.accessor('role', {
      header: () => 'Role',
    }),
    columnHelper.accessor('desc', {
      header: () => 'Description',
    }),
    columnHelper.accessor('type', {
      header: () => 'Type',
    }),
    columnHelper.accessor('shape', {
      header: () => 'Shape',
    }),
    columnHelper.accessor('units', {
      header: () => 'Units',
    }),
    columnHelper.accessor('init', {
      header: () => 'Init',
      enableGlobalFilter: false,
    }),
    columnHelper.accessor('lower', {
      header: () => 'Lower',
      enableGlobalFilter: false,
    }),
    columnHelper.accessor('upper', {
      header: () => 'Upper',
      enableGlobalFilter: false,
    }),
    columnHelper.accessor('uq', {
      header: () => 'UQ',
      cell: (info) => ButtonCell(info),
      enableGlobalFilter: false,
    }),
    columnHelper.accessor('ref', {
      header: () => 'Ref',
      enableGlobalFilter: false,
    }),
    columnHelper.accessor('ref0', {
      header: () => 'Ref0',
      enableGlobalFilter: false,
    }),
    columnHelper.accessor('res_ref', {
      header: () => 'Res.Ref',
      enableGlobalFilter: false,
    }),
  ];

  React.useEffect(() => {
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    [...tooltipTriggerList].map((tooltipTriggerEl) => new Tooltip(tooltipTriggerEl));
  }, []);

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
