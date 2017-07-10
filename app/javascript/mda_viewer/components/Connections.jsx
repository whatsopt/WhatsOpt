import React from 'react';

class Connection extends React.Component {
  constructor(props) {
    super(props);
    this.state = { conn: this.props.conn,
                   vars: this.props.vars };
  }

  render() {
    let infos = this._findInfos(this.state.conn); 
      
    let units = infos.frUnits;
    if (infos.frUnits != infos.toUnits) {
      units += `-> {$infos.toUnits}`;
    }
    
    return (
      <tr>
        <td>{infos.frName}</td>
        <td>{infos.toName}</td>
        <td title={infos.desc} >{infos.vName}</td>
        <td>{units}</td>
      </tr>
    );
  }
   
  _findInfos(conn) { 
    //console.log(JSON.stringify(conn)); 
    let vfr = this._findVariableInfo(conn.fr, conn.varname, "out");
    let vto = this._findVariableInfo(conn.to, conn.varname, "in");
    let desc = vfr.desc || vto.desc
    if (vfr.desc && vto.desc && vfr.desc !== vto.desc) {
      desc = `From: ${vfr.desc}, To: ${vfr.desc}`;
    } 
    let infos = { frName: conn.fr, frUnits: vfr.units, 
                  vName: conn.varname, desc: desc,
                  toName: conn.to, toUnits: vto.units };
    return infos;
  }
  
  _findVariableInfo(disc, vname, io_mode) {
    let vars = this.state.vars;
    let vinfo = {units: '', desc: '', type: '', shape: ''};
    if (disc !== '_U_') {
      let vinfos = vars[disc][io_mode].filter((v) => { 
        return v.name === vname; 
      });
      if (vinfos.length === 1) {
        console.log(vinfos[0]);
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
    this.state = {
      mda: this.props.mda,
      filter: this.props.filter,  // TODO : pass discipline filter
    };
  }

  render() {
    var conns = [];
    var edges = this.state.mda.edges;
    var vars = this.state.mda.vars;
    var filter = this.state.filter;

    if (filter) {
      let nodeFrom = this._findNodeFromIndex(filter.from);
      let nodeTo = this._findNodeFromIndex(filter.to);
      let edges = edges.filter((edge) => {
        return edge.from === nodeFrom.id && edge.to === nodeTo.id;
      });
    }

    edges.forEach((edge) => {
      let vars = edge.name.split(",");
      vars.forEach((v) => {
        let nameFrom = this._findNodeFromId(edge.from).name;
        let nameTo = this._findNodeFromId(edge.to).name;
        conns.push({
          id: nameFrom + '_' + v + '_' + nameTo,
          fr: nameFrom,
          to: nameTo,
          varname: v,
        });
      }, this);
    }, this);

    let connections = conns.map((conn) => {
      return ( <Connection key={conn.id} conn={conn} vars={vars}/> );
    });

    return (
      <table className="table table-striped connections">
        <thead>
          <tr>
            <th>From</th>
            <th>To</th>
            <th>Variable</th>
            <th>Units</th>
            <th>Type</th>
            <th>Shape</th>
          </tr>
        </thead>

        <tbody>
          {connections}
        </tbody>
      </table>
     );
  };

  _findNodeFromIndex(index) {
    if ( 0 <= index && index < this.state.mda.nodes.length ) {
      return this.state.mda.nodes[index];
    }
    throw Error("Node index ("+ index +") out of range: " + JSON.stringify(this.state.nodes));
  }

  _findNodeFromId(id) {
    if (id === '_U_') return {id: '_U_', name: '_U_'}; 
    for (var i=0; i < this.state.mda.nodes.length; i++) {
      if (this.state.mda.nodes[i].id === id) {
        return this.state.mda.nodes[i];
      }
    };
    throw Error("Node id ("+ id +") unknown: " + JSON.stringify(this.state.nodes));  
  }
}

export default Connections;