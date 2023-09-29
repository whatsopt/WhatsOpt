import React from 'react';
import PropTypes from 'prop-types';
import Slider from 'rc-slider';

const ZEROTH = 'Zero_th';
const CONDTH = 'Cond_th';
const INDTH = 'Ind_th';

const quantileMarks = {
  0: '0', 25: '0.25', 50: '0.5', 75: '0.75', 100: '1',
};
const gThresholdMarks = {
  0: '0', 25: '0.25', 50: '0.5', 75: '0.75', 100: '1',
};

class HsicControls extends React.PureComponent {
  render() {
    const {
      thresholding, quantile, gThreshold, onThresholdingChange,
      onQuantileChange, onGThresholdChange,
    } = this.props;

    return (
      <div>
        <div className="col hsic-control-slider">
          <div className="dropdown">
            <select
              className="form-control"
              id="type"
              defaultValue={thresholding}
              onChange={onThresholdingChange}
            >
              <option value={ZEROTH}>{ZEROTH}</option>
              <option value={CONDTH}>{CONDTH}</option>
              <option value={INDTH}>{ INDTH}</option>
            </select>
          </div>
        </div>
        <div className="col hsic-control-slider">
          Quantile :
          {' '}
          { quantile }
          <Slider
            marks={quantileMarks}
            value={quantile * 100}
            onChange={(val) => onQuantileChange(val / 100.0)}
            afterChange={(val) => onQuantileChange(val / 100.0)}
          />
        </div>
        <div className="col hsic-control-slider">
          Cstr Threshold:
          {' '}
          { gThreshold }
          <Slider
            marks={gThresholdMarks}
            value={gThreshold * 100}
            onChange={(val) => onGThresholdChange(val / 100.0)}
            afterChange={(val) => onGThresholdChange(val / 100.0)}
          />
        </div>
      </div>
    );
  }
}

HsicControls.propTypes = {
  thresholding: PropTypes.string.isRequired,
  quantile: PropTypes.number.isRequired,
  gThreshold: PropTypes.number.isRequired,
  onThresholdingChange: PropTypes.func.isRequired,
  onQuantileChange: PropTypes.func.isRequired,
  onGThresholdChange: PropTypes.func.isRequired,
};

export default HsicControls;
