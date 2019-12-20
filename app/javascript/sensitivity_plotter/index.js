import React from 'react';
import PropTypes from 'prop-types';
import ScreeningScatterPlot from './ScreeningScatterPlot'

class SensitivityAnalysisPlotter extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      sensitivity: null,
    };
  }

  componentDidMount() {
    const { api, opeId } = this.props;
    api.openmdaoScreening(
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
      const varnames = Object.keys(sensitivity).sort();
      const outs = [];
      for (const output of varnames) {
        outs.push([output, sensitivity[output]]);
      }
      screenings = outs.map(
        (o) => (<ScreeningScatterPlot key={o[0]} outVarName={o[0]} saData={o[1]} />),
      );
    }
    return (
      <div>
        {screenings}
      </div>
    );
  }
}

SensitivityAnalysisPlotter.propTypes = {
  opeId: PropTypes.number.isRequired,
  api: PropTypes.object.isRequired,
};
