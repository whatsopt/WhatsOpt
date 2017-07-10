import * as d3 from 'd3';
import React from 'react';
import Graph from 'XDSMjs/src/graph';
import Xdsm from 'XDSMjs/src/xdsm';

class XdsmViewer extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props.mda;
  } 

  componentDidMount() {
    // D3 drawing
    var tooltip = d3.select("body").selectAll(".tooltip").data(['tooltip'])
    .enter().append("div")
    .attr("class", "tooltip")
    .style("opacity", 0);

    var graph = new Graph(this.state);
    
    let config = {
        labelizer: {
          ellipsis: 5,
          subSupScript: false,
          showLinkNbOnly: true,
        },
      };
    var xdsm = new Xdsm(graph, 'root', tooltip, config);
    xdsm.draw();
  }

  shouldComponentUpdate() {
    return false; // This prevents future re-renders of this component
  }

  render() {
    return ( <div className="xdsm"></div> );
  }
}

export default XdsmViewer;