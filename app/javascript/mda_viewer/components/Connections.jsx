import React from 'react';

const USER = '_U_';

class Connection extends React.Component {

  render() {
    let infos = this._findInfos(this.props.conn); 
    let units = infos.frUnits;
    if (infos.frUnits !== infos.toUnits && infos.toUnits) {
      units += `-> ${infos.toUnits}`;
    }
    
    return (
      <tr>
        <td>{this.props.conn.frName}</td>
        <td>{this.props.conn.toName}</td>
        <td title={infos.desc} >{infos.vName}</td>
        <td>{infos.type}</td>
        <td>{infos.shape}</td>
        <td>{units}</td>
      </tr>
    );
  }
   
  _findInfos(conn) { 
    let vfr = this._findVariableInfo(conn.fr, conn.varname, "out");
    let vto = this._findVariableInfo(conn.to, conn.varname, "in");
    let desc = vfr.desc || vto.desc
    if (vfr.desc && vto.desc && vfr.desc !== vto.desc) {
      desc = `From: ${vfr.desc}, To: ${vfr.desc}`;
    } 
    let vartype = vfr.type || vto.type;
    let shape = vfr.shape || vto.shape;    
    let infos = { frName: conn.frName, frUnits: vfr.units, 
                  vName: conn.varname, desc: desc,
                  toName: conn.toName, toUnits: vto.units,
                  type: vartype, shape: shape};
    return infos;
  }
    
  _findVariableInfo(disc, vname, io_mode) {
    let vars = this.props.vars;
    let vinfo = {units: '', desc: '', type: '', shape: ''};
    if (disc !== USER) {
      let vinfos = vars[disc][io_mode].filter((v) => { 
        return v.fullname === vname; 
      });
      if (vinfos.length === 1) {
        vinfo = vinfos[0];
      } else {
        throw Error(`Expected one variable ${vname} found ${vinfos.length} in ${JSON.stringify(vinfos)}`);        
      }
    } 
    return vinfo;
  }
}

class Connections extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    var conns = [];
    var edges = this.props.mda.edges;
    var filter = this.props.filter;

    if (filter.fr && filter.to) {
      let nodeFrom = this._findNodeFromId(filter.fr);
      let nodeTo = this._findNodeFromId(filter.to);
      if (filter.fr === filter.to) { // node selected
        edges = edges.filter((edge) => {
          return edge.from === nodeFrom.id || edge.to === nodeTo.id;
        });
      } else {
        edges = edges.filter((edge) => { // edge selected
          return edge.from === nodeFrom.id && edge.to === nodeTo.id;
        });
      }
    }

    edges.forEach((edge) => {
      let vars = edge.name.split(",");
      let fromName = this._disciplineName(edge.from);
      let toName = this._disciplineName(edge.to);
      vars.forEach((v) => {
        conns.push({
          id: edge.from + '_' + v + '_' + edge.to,
          fr: edge.from,
          to: edge.to,
          frName: fromName,
          toName: toName, 
          varname: v,
        });
      }, this);
    }, this);

    let connections = conns.map((conn) => {
      return ( <Connection key={conn.id} conn={conn} vars={this.props.mda.vars} /> );
    });

    return (
      <table className="table table-striped connections">
        <thead>
          <tr>
            <th>From</th>
            <th>To</th>
            <th>Variable</th>
            <th>Type</th>
            <th>Shape</th>
            <th>Units</th>
          </tr>
        </thead>

        <tbody>
          {connections}
        </tbody>
      </table>
     );
  };
  
  _disciplineName(id) {
    let name = this._findNodeFromId(id).name;
    return name === USER ? 'PENDING' : name;
  };

  _findNodeFromId(id) {
    if (id === USER) return {id: USER, name: USER}; 
    for (var i=0; i < this.props.mda.nodes.length; i++) {
      if (this.props.mda.nodes[i].id === id) {
        return this.props.mda.nodes[i];
      }
    };
    throw Error("Node id ("+ id +") unknown: " + JSON.stringify(this.state.nodes));  
  };
}

export default Connections;