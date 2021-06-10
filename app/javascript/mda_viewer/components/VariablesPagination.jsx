import React from 'react';
import PropTypes from 'prop-types';

class VariablesPagination extends React.Component {
    constructor(props) {
        super(props)
    }

    render() {
        let {
            canPreviousPage,
            canNextPage,
            pageOptions,
            pageCount,
            gotoPage,
            nextPage,
            previousPage,
            setPageSize,
            pageIndex,
            pageSize
        } = this.props;

        const pageItemPrev = `page-item ${canPreviousPage ? "" : "disabled"}`;
        const pageItemNext = `page-item ${canNextPage ? "" : "disabled"}`;

        return (
            <div className="editor-section">
                <nav>
                    <ul className="pagination" style={{ marginBottom: 0 }}>
                        <li className={pageItemPrev}>
                            <button className="page-link" onClick={() => gotoPage(0)} aria-label="Previous">
                                <i className="fas fa-angle-double-left"></i>
                            </button>
                        </li>
                        <li className={pageItemPrev}>
                            <button className="page-link" onClick={() => previousPage()} aria-label="Previous">
                                <i className="fas fa-angle-left"></i>
                            </button>
                        </li>
                        <li className="page-item disabled"><span className="page-link">{pageIndex + 1} / {pageOptions.length}</span></li>

                        <li className={pageItemNext}>
                            <button className="page-link" onClick={() => nextPage()} aria-label="Previous">
                                <i className="fas fa-angle-right"></i>
                            </button>
                        </li>
                        <li className={pageItemNext}>
                            <button className="page-link" onClick={() => gotoPage(pageCount - 1)} aria-label="Previous">
                                <i className="fas fa-angle-double-right"></i>
                            </button>
                        </li>
                        <span className="ml-2" />
                        <li className="page-item">
                            <div className="form-row align-items-center">
                                <div className="form-group col-auto">
                                    <select className="form-control"
                                        value={pageSize}
                                        onChange={e => {
                                            setPageSize(Number(e.target.value))
                                        }}
                                    >
                                        {[10, 20, 30, 50, 100].map(pageSize => (
                                            <option key={pageSize} value={pageSize}>
                                                Show {pageSize}
                                            </option>
                                        ))}
                                    </select>
                                </div>
                            </div>
                        </li>
                    </ul>
                </nav>
            </div >
        );
    }
}


VariablesPagination.propTypes = {
    canPreviousPage: PropTypes.bool,
    canNextPage: PropTypes.bool,
    pageOptions: PropTypes.arrayOf(PropTypes.number),
    pageCount: PropTypes.number,
    gotoPage: PropTypes.func,
    nextPage: PropTypes.func,
    previousPage: PropTypes.func,
    setPageSize: PropTypes.func,
    pageIndex: PropTypes.number,
    pageSize: PropTypes.number,
};

export default VariablesPagination;