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

import { RIEInput, RIESelect } from './riek/src';
import VariablesPagination from './VariablesPagination';
import VariablesGlobalFilter from './VariablesGlobalFilter';

/* eslint-disable react/jsx-props-no-spreading */
function Table({
  columns, data: defaultData,
  onConnectionChange, isEditing, limited, useScaling,
}) {
  const [data, setData] = React.useState(() => [...defaultData]);
  const [sorting, setSorting] = React.useState([]);
  const [globalFilter, setGlobalFilter] = React.useState('');

  const columnVisibility = {};
  if (!isEditing) {
    columnVisibility.active = false;
    columnVisibility.desc = false;
    columnVisibility.type = false;
  }
  if (!useScaling) {
    columnVisibility.ref = false;
    columnVisibility.ref0 = false;
    columnVisibility.res_ref = false;
  }

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
    initialState: {
      columnVisibility,
    },
    state: {
      sorting,
      globalFilter,
    },
    onSortingChange: setSorting,
    onGlobalFilterChange: setGlobalFilter,
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
                  {headerGroup.headers.map((header) => (
                    <th key={header.id}>
                      {header.isPlaceholder
                        ? null
                        : (
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
                  ))}
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
      cell: (info) => info.getValue(),
    }),
    columnHelper.accessor('from', {
      header: () => 'From',
      cell: (info) => info.getValue(), // ReadonlyCell
    }),
    columnHelper.accessor('name', {
      header: () => 'Name',
      cell: (info) => info.getValue(),
    }),
    columnHelper.accessor('role', {
      header: () => 'Role',
      cell: (info) => info.getValue(),
    }),
    columnHelper.accessor('desc', {
      header: () => 'Description',
      cell: (info) => info.getValue(),
    }),
    columnHelper.accessor('type', {
      header: () => 'Type',
      cell: (info) => info.getValue(),
    }),
    columnHelper.accessor('shape', {
      header: () => 'Shape',
      cell: (info) => info.getValue(),
    }),
    columnHelper.accessor('units', {
      header: () => 'Units',
      cell: (info) => info.getValue(),
    }),
    columnHelper.accessor('init', {
      header: () => 'Init',
      cell: (info) => info.getValue(),
    }),
    columnHelper.accessor('lower', {
      header: () => 'Lower',
      cell: (info) => info.getValue(),
    }),
    columnHelper.accessor('upper', {
      header: () => 'Upper',
      cell: (info) => info.getValue(),
    }),
    columnHelper.accessor('uq', {
      header: () => 'UQ',
      cell: (info) => '',
    }),
    columnHelper.accessor('ref', {
      header: () => 'Ref',
      cell: (info) => info.getValue(),
    }),
    columnHelper.accessor('ref0', {
      header: () => 'Ref0',
      cell: (info) => info.getValue(),
    }),
    columnHelper.accessor('res_ref', {
      header: () => 'Res.Ref',
      cell: (info) => info.getValue(),
    }),
  ];

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
