import React from 'react';
import PropTypes from 'prop-types';
import MorrisScatterPlot from './components/MorrisScatterPlot';
import SobolScatterPlot from './components/SobolScatterPlot';

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
      (response) => {
        this.setState({ ...response.data });
      },
    );
  }

  render() {
    let screenings;
    const { sensitivity } = this.state;
    if (sensitivity) {
      const { saMethod, saResult } = sensitivity;
      const varnames = Object.keys(saResult).sort();
      const outs = [];
      for (const output of varnames) {
        outs.push([output, saResult[output]]);
      }
      console.log(`samethod ${saMethod}`);
      if (saMethod === 'morris') {
        screenings = outs.map(
          (o) => (<MorrisScatterPlot key={o[0]} outVarName={o[0]} saData={o[1]} />),
        );
      } else if (saMethod === 'sobol') {
        screenings = outs.map(
          (o) => (<SobolScatterPlot key={o[0]} outVarName={o[0]} saData={o[1]} />),
        );
      } else {
        console.log(`Error: sensitivity analysis method ${saMethod} unknown`);
      }
    }

    const { ope, mda } = this.props;
    const title = `${ope.name} on ${mda.name}`;
    return (
      <div>
        <h1>
          {title}
        </h1>

        {screenings}
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
