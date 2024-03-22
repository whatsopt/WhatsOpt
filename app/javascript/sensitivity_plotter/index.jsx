import React from 'react';
import PropTypes from 'prop-types';
import MorrisScatterPlot from './components/MorrisScatterPlot';
import SobolScatterPlot from './components/SobolScatterPlot';
import SobolHeatMap from './components/SobolHeatMap';

class SensitivityPlotter extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      sensitivity: null,
    };
  }

  componentDidMount() {
    const { api, ope: { id: opeId } } = this.props;
    api.analyseSensitivity(
      opeId,
      undefined,
      undefined,
      undefined,
      (response) => {
        this.setState({ ...response.data });
      },
    );
  }

  render() {
    let heatmaps;
    let plots;
    let desc;
    const { sensitivity } = this.state;
    if (sensitivity) {
      const { saMethod, saResult } = sensitivity;
      const varnames = Object.keys(saResult).sort();
      const outs = [];
      for (const output of varnames) {
        outs.push({ outname: output, sensitivity: saResult[output] });
      }
      if (saMethod === 'morris') {
        desc = 'For each output, plot of standard deviation (\u03c3) vs mean (\u03bc*) of the effect of a given input (the closer to (0,0), the lesser influent the input is)';
        plots = outs.map(
          (o) => (
            <MorrisScatterPlot
              key={o.outname}
              outVarName={o.outname}
              saData={o.sensitivity}
            />
          ),
        );
      } else if (saMethod === 'sobol') {
        desc = 'For each output, plot of Sobol first order (S1) and total order (ST) indices (share of the variance of the output that is due to a given input: the greater, the more influent the input is)';
        heatmaps = [
          <SobolHeatMap outVarNames={varnames} saResult={saResult} firstOrder />,
          <SobolHeatMap outVarNames={varnames} saResult={saResult} />,
        ];
        plots = outs.map(
          (o) => (
            <SobolScatterPlot
              key={o.outname}
              outVarName={o.outname}
              saData={o.sensitivity}
            />
          ),
        );
      } else {
        console.log(`Error: sensitivity analysis method ${saMethod} unknown`);
      }
    }

    const { ope, mda } = this.props;
    const title = `Sensitivity analysis on ${mda.name} (${ope.name})`;
    return (
      <div>
        <h1>
          {title}
        </h1>
        <p>
          {desc}
        </p>
        {heatmaps}
        {plots}
      </div>
    );
  }
}

SensitivityPlotter.propTypes = {
  mda: PropTypes.object.isRequired,
  ope: PropTypes.object.isRequired,
  api: PropTypes.object.isRequired,
};

export default SensitivityPlotter;
