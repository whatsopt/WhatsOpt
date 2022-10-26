import React from 'react';
import PropTypes from 'prop-types';

class VariablesPagination extends React.PureComponent {
  render() {
    const {
      canPreviousPage,
      canNextPage,
      pageOptions,
      pageCount,
      gotoPage,
      nextPage,
      previousPage,
      setPageSize,
      pageIndex,
      pageSize,
    } = this.props;

    const pageItemPrev = `page-item ${canPreviousPage ? '' : 'disabled'}`;
    const pageItemNext = `page-item ${canNextPage ? '' : 'disabled'}`;

    return (
      <nav>
        <ul className="pagination" style={{ marginBottom: 0 }}>
          <li className={pageItemPrev}>
            <button type="button" className="page-link" onClick={() => gotoPage(0)} aria-label="Previous">
              <i className="fas fa-angle-double-left" />
            </button>
          </li>
          <li className={pageItemPrev}>
            <button type="button" className="page-link" onClick={() => previousPage()} aria-label="Previous">
              <i className="fas fa-angle-left" />
            </button>
          </li>
          <li className="page-item disabled">
            <span className="page-link">
              {pageIndex + 1}
              {' '}
              /
              {' '}
              {pageOptions.length}
            </span>
          </li>

          <li className={pageItemNext}>
            <button type="button" className="page-link" onClick={() => nextPage()} aria-label="Previous">
              <i className="fas fa-angle-right" />
            </button>
          </li>
          <li className={pageItemNext}>
            <button type="button" className="page-link" onClick={() => gotoPage(pageCount - 1)} aria-label="Previous">
              <i className="fas fa-angle-double-right" />
            </button>
          </li>
          <span className="ms-2" />
          <li className="page-item">
            <div className="form-row align-items-center">
              <div className="mb-3 col-auto">
                <select
                  className="form-control"
                  value={pageSize}
                  onChange={(e) => {
                    setPageSize(Number(e.target.value));
                  }}
                >
                  {[10, 20, 30, 50, 100].map((pSize) => (
                    <option key={pSize} value={pSize}>
                      Show
                      {' '}
                      {pSize}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </li>
        </ul>
      </nav>
    );
  }
}

VariablesPagination.propTypes = {
  canPreviousPage: PropTypes.bool.isRequired,
  canNextPage: PropTypes.bool.isRequired,
  pageOptions: PropTypes.arrayOf(PropTypes.number).isRequired,
  pageCount: PropTypes.number.isRequired,
  gotoPage: PropTypes.func.isRequired,
  nextPage: PropTypes.func.isRequired,
  previousPage: PropTypes.func.isRequired,
  setPageSize: PropTypes.func.isRequired,
  pageIndex: PropTypes.number.isRequired,
  pageSize: PropTypes.number.isRequired,
};

export default VariablesPagination;
