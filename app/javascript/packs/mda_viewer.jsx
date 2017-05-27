import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import Graph from 'graph'
import Xdsm from 'xdsm'

class XdsmViewer extends React.Component {
  componentDidMount() {    
    /* D3 code to append elements to this.svg */
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
    return <h2>Discipline {this.state.name}</h2>
  }  
} 

class Mda extends React.Component {
  constructor(props) {
    super(props) 
    this.state = {name: this.props.name, mda: this.props.mda}
  }
  
  render() {
    return (
      <div>
        <h1>MDA {this.state.name}</h1>
        <XdsmViewer />
        <Discipline name='Geometry'/>
      </div>
    );
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Mda name="CICAV" mda={MDA}/>,
    document.getElementById('mda-viewer'),
  )
  
  var tooltip = d3.select("body").selectAll(".tooltip").data(['tooltip'])
      .enter().append("div")
      .attr("class", "tooltip")
      .style("opacity", 0);
  
  console.log(JSON.stringify(MDA));
  var graph = new Graph(MDA);
  var xdsm = new Xdsm(graph, 'root', tooltip);
  xdsm.draw();
})
