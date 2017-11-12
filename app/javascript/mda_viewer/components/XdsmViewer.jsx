import * as d3 from 'd3';
import React from 'react';
import Graph from 'XDSMjs/src/graph';
import Xdsm from 'XDSMjs/src/xdsm';
import Selectable from 'XDSMjs/src/selectable';

class XdsmViewer extends React.Component {
  constructor() {
    super();
    this.state = {
      filter: undefined,
    }
  } 

  componentDidMount() {
    // D3 drawing
    var tooltip = d3.select("body").selectAll(".tooltip").data(['tooltip'])
      .enter().append("div")
      .attr("class", "tooltip")
      .style("opacity", 0);

    var graph = new Graph(this.props.mda);
    
    let config = {
        labelizer: {
          ellipsis: 5,
          subSupScript: false,
          showLinkNbOnly: true,
        },
        layout: { 
          origin: {x: 50, y: 20},
          cellsize: {w: 150, h: 50},
          padding: 10,
        },
        titleTooltip: true,
      };
    var xdsm = new Xdsm(graph, 'root', config);
    xdsm.draw();
    var selectable_xdsm = new Selectable(xdsm, this._onXDSMSelectionChange.bind(this));
    
    // bootstrap tooltip for connections
    $(".ellipsized").attr("data-toggle", "tooltip").attr("data-placement", "right");
    $(function () {
      $('.ellipsized').tooltip()
    })
  }

  shouldComponentUpdate() {
    return false; // This prevents future re-renders of this component
  }

  render() {
    return ( <div className="xdsm"></div> );
  }

  _onXDSMSelectionChange(filter) {
    this.props.onFilterChange(filter);    
  }
}

export default XdsmViewer;