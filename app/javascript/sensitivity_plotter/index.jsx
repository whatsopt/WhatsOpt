import React from 'react';
import PropTypes from 'prop-types';
import ScreeningScatterPlot from './components/ScreeningScatterPlot';

class SensitivityPlotter extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      sensitivity: null,
    };
  }

  componentDidMount() {
    const { api, ope: { id: opeId } } = this.props;
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
