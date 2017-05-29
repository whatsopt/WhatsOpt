import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import Graph from 'graph'
import Xdsm from 'xdsm'

class XdsmViewer extends React.Component {
  constructor(props) {
    super(props) 
    this.state = this.props.mda
  }
  
  componentDidMount() {    
    // D3 drawing
    var tooltip = d3.select("body").selectAll(".tooltip").data(['tooltip'])
    .enter().append("div")
    .attr("class", "tooltip")
    .style("opacity", 0);

    console.log(JSON.stringify(this.state));
    var graph = new Graph(this.state);
    var xdsm = new Xdsm(graph, 'root', tooltip);
    xdsm.draw();
  }
  
  shouldComponentUpdate() {
    return false; // This prevents future re-renders of this component
  }
  
  render() {
    return (
      <div className="xdsm"></div>
     );
  }
}

class Discipline extends React.Component {
  constructor(props) {
    super(props)
    this.state = {name: this.props.name}
  }
  
  render() { 
    return <h2>{this.state.name}</h2>
  }  
} 

class Mda extends React.Component {
  constructor(props) {
    super(props) 
    this.state = this.props.mda
  }
   
  render() {
    var disciplines = this.state.nodes.map((node) => {
      return (
          <Discipline key={node.id} name={node.name} />
        );
    }); 
    
    return (
      <div>
        <h1>MDA {this.state.name}</h1>
        <XdsmViewer mda={this.state}/>
        {disciplines}
      </div>
    );
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Mda mda={MDA}/>,
    document.getElementById('mda-viewer'),
  )
})
