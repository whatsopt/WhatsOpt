import React from 'react';
import PropTypes from 'prop-types';
// import Plot from 'react-plotly.js';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';
import * as caseUtils from '../../utils/cases';

const Plot = createPlotlyComponent(Plotly);

class DistributionHistogramList extends React.PureComponent {
  render() {
    const { varcase, mask } = this.props;
    const { values } = varcase;

    const data = [];
    const layout = {};

    const trace = {
      x: values.filter((item, i) => mask[i]),
      type: 'histogram',
    };

    data.push(trace);
    layout.width = 300;
    layout.height = 300;
    layout.title = { text: caseUtils.label(varcase) };

    return (<Plot data={data} layout={layout} />);
  }
}

DistributionHistogramList.propTypes = {
  varcase: PropTypes.object.isRequired,
  mask: PropTypes.array.isRequired,
};

class DistributionHistograms extends React.PureComponent {
  render() {
    const { cases, success } = this.props;
    const inputs = cases.i;
    const outputs = cases.o;
    let succ = success;
    if (succ.length === 0) {
      succ = new Array(inputs[0].values.length);
      succ.fill(1);
    }
    const mask = succ.map((item) => item === 1);
    const nb = mask.filter((b) => b).length;

    const inputDists = inputs.map((c) => (
      <DistributionHistogramList key={caseUtils.label(c)} varcase={c} mask={mask} />));
    const outputDists = outputs.map((c) => (
      <DistributionHistogramList key={caseUtils.label(c)} varcase={c} mask={mask} />));

    return (
      <div>
        <div className="editor-section">
          Input Distributions -
          {' '}
          {nb}
          {' '}
          cases
        </div>
        {inputDists}
        <div className="editor-section">
          Output Distributions -
          {' '}
          {nb}
          {' '}
          cases
        </div>
        {outputDists}
      </div>
    );
  }
}

DistributionHistograms.propTypes = {
  cases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }).isRequired,
  success: PropTypes.array.isRequired,
};

export default DistributionHistograms;
