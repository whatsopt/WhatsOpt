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
    let infos = { id: conn.connId, idfrName: conn.frName, frUnits: vfr.units, 
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
