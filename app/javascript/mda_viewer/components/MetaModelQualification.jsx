import React from 'react';
import PropTypes from 'prop-types';
//import Plot from 'react-plotly.js';

import Plotly from './custom-plotly'
import createPlotlyComponent from 'react-plotly.js/factory';
const Plot = createPlotlyComponent(Plotly);

class MetaModelQualification extends React.Component {

  constructor(props) {
    super(props);

    this.state = {selected: -1};
    this.handleQualityDisplay = this.handleQualityDisplay.bind(this)
  }

  handleQualityDisplay(quality_index) {
    this.setState({selected: quality_index})
  }

  render() {
    const qualities = this.props.quality.sort((a, b) => a.r2 > b.r2)
    // Quality Buttons
    const qualityButtons = qualities.map((q, i) => {
      let badgeKind = "badge " 
      badgeKind += ((q.r2 < 0.5)?"badge-danger":"");
      badgeKind += ((0.5 <= q.r2 && q.r2 < 0.95)?"badge-warning":"");
      badgeKind += ((0.95 <= q.r2)?"badge-success":"");
      const btnClass = "btn m-1";
      return (
        <button key={q.name} className={btnClass} onClick={(e) => this.handleQualityDisplay(i)}>
          {q.name} <span className={badgeKind}>{q.r2.toPrecision(8)}</span>
        </button>
      );
    });

    // Plot
    let plot;
    if (this.state.selected > -1) {
      const data = [];

      const ylabel = "Output predicted"
      const selected = qualities[this.state.selected];

      const yvalid = selected.yvalid;
      const ypred = selected.ypred;
      const trace1 = {
        x: yvalid,
        y: yvalid,
        type: 'scatter',
        mode: 'line',
        name: "true",
      };
      data.push(trace1);

      const trace2 = {
        x: yvalid,
        y: ypred,
        type: 'scatter',
        mode: 'markers',
        name: "predicted",
      };
      data.push(trace2);

      const title = `${selected["name"]} predicted with ${selected["kind"]} surrogate`;
      const layout = {width: 600, height: 500, title: title};
      plot = (<Plot data={data} layout={layout} />);
    }

    return (
      <div className="editor-section">
        <label>Coefficients of determination R<sup>2</sup> for outputs: <em>the closer to one, the better</em></label>
        <div>
          <span className="mb-3">{qualityButtons}</span>
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