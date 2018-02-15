import React from 'react';

const USER = '_U_';

class Connection extends React.Component {

  render() {
    let infos = this._findInfos(this.props.conn); 
    let units = infos.frUnits;
    //console.log("VARNAME "+JSON.stringify(infos));
    return (
      <tr>
        <td>{this.props.conn.frName}</td>
        <td>{this.props.conn.toName.join(', ')}</td>
        <td title={infos.desc} >{infos.vName}</td>
        <td>{infos.type}</td>
        <td>{infos.shape}</td>
        <td>{infos.init}</td>
        <td>{units}</td>
      </tr>
    );
  }
   
  _findInfos(conn) { 
    //console.log("CONN : "+JSON.stringify(conn));
    let vfr = this._findVariableInfo(conn.fr, conn.varname, "out");
    let vto = this._findVariableInfo(conn.to[0], conn.varname, "in");
    let desc = vfr.desc || vto.desc; 
    let vartype = vfr.type || vto.type;
    let shape = vfr.shape || vto.shape;    
    let varname = vfr.name || vto.name; 
    let init = "";

    if (vto.parameter) {
      init = vto.parameter.init;
    }
    let infos = { frName: conn.frName, frUnits: vfr.units, 
                  vName: varname, desc: desc,
                  toName: conn.toName.join(', '),
                  type: vartype, shape: shape, init: init};
    return infos;
  }
    
  // TODO: Big technical debt to be reduced
  _findVariableInfo(disc, vname, io_mode) {
    let vars = this.props.vars;
    //console.log(disc, vname);
    let vinfo = {units: '', desc: '', type: '', shape: '', init: ''};
    if (disc !== USER) {
      // console.log("search "+ vname + " in " + JSON.stringify(vars[disc][io_mode])); 
      let vinfos = vars[disc][io_mode].filter((v) => { 
        return v.name === vname; 
      });
      if (vinfos.length === 1) {
        // console.log("FIND "+JSON.stringify(vinfos));
        vinfo = vinfos[0];
      } else if (vinfos.length > 1) {
        console.log("Find several occurences of " + vname + "("+io_mode +"): " + JSON.stringify(vinfos));
        console.log("Check against fullnames");
        vinfos = vars[disc][io_mode].filter((v) => { 
          return v.fullname === vname; 
        });
        if (vinfos.length === 1) {
          vinfo = vinfos[0];
        } else {
          throw Error(`Expected one variable ${vname} found ${vinfos.length} in ${JSON.stringify(vars[disc][io_mode])}`);
        }
      } else {
        // console.log("Find no occurence of " + vname + "(" + io_mode + "): " + JSON.stringify(vinfos));
        // console.log("Check against fullnames");
        vinfos = vars[disc][io_mode].filter((v) => { 
          return v.fullname === vname; 
        });
        if (vinfos.length === 1) {
          vinfo = vinfos[0];
        } else {
          throw Error(`Expected one variable ${vname} found ${vinfos.length} in ${JSON.stringify(vars[disc][io_mode])}`);
        }
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

    let hconns = {};
    edges.forEach((edge) => {
      let vars = edge.name.split(",");
      let fromName = this._findNodeFromId(edge.from).name;
      let toName = this._findNodeFromId(edge.to).name;
      vars.forEach((v) => {
        let id = edge.from + '_' + v;
        if (hconns[id]) {
          hconns[id].to.push(edge.to);
          hconns[id].toName.push(toName);
        } else {
          hconns[id] = {
              id: id,
              fr: edge.from,
              to: [edge.to],
              frName: fromName,
              toName: [toName], 
              varname: v,
          }
        }
      }, this);
    }, this);
    
    let conns = [];
    for (let id in hconns) {
      if (hconns.hasOwnProperty(id)) {
        conns.push(hconns[id]);
      }
    }
    conns.sort(function(a, b) {return a.id < b.id});
    
    console.log(JSON.stringify(conns));
    
    let connections = conns.map((conn) => {
      return ( <Connection key={conn.id} conn={conn} vars={this.props.mda.vars} /> );
    });

    return (
      <table className="table table-striped connections">
        <thead>
          <tr>
            <th className="col-1">From</th>
            <th className="col-3">To</th>
            <th className="col-3">Variable</th>
            <th className="col-1">Type</th>
            <th className="col-1">Shape</th>
            <th className="col-2">Init</th>
            <th className="col-1">Units</th>
          </tr>
        </thead>

        <tbody>
          {connections}
        </tbody>
      </table>
     );
  };

  _findNodeFromId(id) {
    if (id === USER) return {id: USER, name: 'Driver'}; 
    for (var i=0; i < this.props.mda.nodes.length; i++) {
      if (this.props.mda.nodes[i].id === id) {
        return this.props.mda.nodes[i];
      }
    };
    throw Error("Node id ("+ id +") unknown: " + JSON.stringify(this.state.nodes));  
  };
}

export default Connections;