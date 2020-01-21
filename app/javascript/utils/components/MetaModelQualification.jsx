import React from 'react';
import PropTypes from 'prop-types';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

const Plot = createPlotlyComponent(Plotly);

class MetaModelQualification extends React.Component {
  constructor(props) {
    super(props);
    const { quality } = this.props;
    this.state = { selected: quality.length > 0 ? 0 : -1 }; // select first elt (eg worst r2)
    this.handleQualityDisplay = this.handleQualityDisplay.bind(this);
  }

  static getDerivedStateFromProps(props, state) {
    const { quality } = props;
    const { selected } = state;
    if (selected < 0 && quality.length > 0) {
      return { selected: 0 };
    }
    return null;
  }

  handleQualityDisplay(qualityIndex) {
    this.setState({ selected: qualityIndex });
  }

  render() {
    const { quality } = this.props;
    const { selected } = this.state;
    const qualities = quality.sort((a, b) => a.r2 > b.r2);
    // Quality Buttons
    const qualityButtons = qualities.map((q, i) => {
      let badgeKind = 'badge ';
      badgeKind += ((q.r2 < 0.5) ? 'badge-danger' : '');
      badgeKind += ((q.r2 >= 0.5 && q.r2 < 0.95) ? 'badge-warning' : '');
      badgeKind += ((q.r2 >= 0.95) ? 'badge-success' : '');
      let btnClass = 'btn btn-light m-1';
      btnClass += selected === i ? ' active' : '';
      return (
        <button
          type="button"
          key={q.name}
          className={btnClass}
          onClick={() => this.handleQualityDisplay(i)}
        >
          {q.name}
          {' '}
          <span className={badgeKind}>{q.r2.toPrecision(8)}</span>
        </button>
      );
    });

    // Plot
    let plot;
    if (selected > -1) {
      const data = [];

      const qselected = qualities[selected];

      const { yvalid } = qselected;
      const { ypred } = qselected;
      const trace1 = {
        x: yvalid,
        y: yvalid,
        type: 'scatter',
        mode: 'line',
        name: 'true',
      };
      data.push(trace1);

      const trace2 = {
        x: yvalid,
        y: ypred,
        type: 'scatter',
        mode: 'markers',
        name: 'predicted',
      };
      data.push(trace2);

      const title = `${qselected.name} predicted vs true with ${qselected.kind} surrogate`;
      const layout = { width: 600, height: 500, title };
      plot = (<Plot data={data} layout={layout} />);
    }

    return (
      <div className="editor-section">
        <div>
          Coefficients of determination R
          <sup>2</sup>
          {' '}
          for outputs computed from 10% of original DOE points used as validation set (the closer to one, the better).
        </div>
        <div>
          <span className="mb-3">
            {qualityButtons}
          </span>
        </div>
        {plot}
      </div>
    );
  }
}

MetaModelQualification.propTypes = {
  quality: PropTypes.array.isRequired,
};

export default MetaModelQualification;
