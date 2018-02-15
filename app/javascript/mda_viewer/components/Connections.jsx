import React from 'react';

class Connection extends React.Component {

  render() {
    let infos = this._findInfos(this.props.conn); 
    let units = infos.frUnits;
    let badge, highlightFr, highlightTo = {};
    if (this.props.nodeSelected) {
      let badgeType = "badge "; 
      let ioType = "in"; 
      if (this.props.nodeSelected.id===this.props.conn.fr) {
        highlightFr = {'fontWeight': 'bold'};  
        badgeType += "badge-secondary";
        ioType = "out";
      } else { 
        highlightTo = {'fontWeight': 'bold'};  
        badgeType += "badge-primary";
      }
      badge = <span className={badgeType}>{ioType}</span>;
    }

    return (
      <tr>
        <td style={highlightFr}>{this.props.conn.frName}</td>
        <td style={highlightTo}>{this.props.conn.toName.join(', ')}</td>
        <td title={infos.desc} >{infos.vName} {badge}</td>
        <td>{infos.type}</td>
        <td>{infos.shape}</td>
        <td>{infos.init}</td>
        <td>{units}</td>
      </tr>
    );
  }
   
  _findInfos(conn) { 
    let vfr = this._findVariableInfo(conn.fr, conn.varname, "out");
    let vto = this._findVariableInfo(conn.to[0], conn.varname, "in");
    let desc = vfr.desc; 
    let vartype = vfr.type;
    let shape = vfr.shape;    
    let varname = vfr.name 
    let init = "";

    if (vto.parameter) { // 'to variable' used to retrieve init info
      init = vto.parameter.init;
    }
    let infos = { frName: conn.frName, frUnits: vfr.units, 
                  vName: varname, desc: desc,
                  toName: conn.toName.join(', '),
                  type: vartype, shape: shape, init: init};
    return infos;
  }
    
  _findVariableInfo(disc, vname, io_mode) {
    let vars = this.props.vars;
    let vinfo = {units: '', desc: '', type: '', shape: '', init: ''};
    let vinfos = vars[disc][io_mode].filter((v) => { 
      return v.name === vname; 
    });
    if (vinfos.length === 1) {
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
    return vinfo;
  }
}

class Connections extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    let edges = this.props.mda.edges;
    let filter = this.props.filter;
    let nodeSelected = filter.fr && (filter.fr === filter.to);
    
    if (filter.fr && filter.to) {
      let nodeFrom = this._findNode(filter.fr);
      let nodeTo = this._findNode(filter.to);
      if (nodeSelected) { // node selected
        nodeSelected = nodeFrom;
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
      let fromName = this._findNode(edge.from).name;
      let toName = this._findNode(edge.to).name;
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
    conns.sort(function(conna, connb) {
      let ret;
      if (nodeSelected) {
        if (conna.fr === nodeSelected.id) {
          if (connb.fr === nodeSelected.id) {  
            ret = conna.varname.localeCompare(connb.varname); 
          } else {
            ret = 1;  
          }
        } else {
          if (connb.fr === nodeSelected.id) {  
            ret = -1;
          } else { 
            ret = conna.varname.localeCompare(connb.varname);  
          }
        }
      } else {
        ret = conna.varname.localeCompare(connb.varname);  
      }
      return ret;
    });
    
    let connections = conns.map((conn) => {
      return ( <Connection key={conn.id} conn={conn} vars={this.props.mda.vars} nodeSelected={nodeSelected}/> );
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

  _findNode(id) { 
    for (var i=0; i < this.props.mda.nodes.length; i++) {
      let node = this.props.mda.nodes[i];
      if (node.id === id) {
        return (i==0)?{id: id, name: "Driver"}:{id: node.id, name: node.name};
      }
    };
    throw Error("Node id ("+ id +") unknown: " + JSON.stringify(this.props.mda.nodes));  
  };
}

export default Connections;