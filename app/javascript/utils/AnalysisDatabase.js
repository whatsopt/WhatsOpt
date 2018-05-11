class AnalysisDatabase {
  constructor(mda) {
    this.mda = mda;
    this.driver = this.mda.nodes[0];
    let varList = [];
    for (let d in mda.vars) {
      varList.push(...mda.vars[d]['out']);
    }
    this.inputVariables = mda.vars[this.driver.id]['out'].sort();
    this.outputVariables = mda.vars[this.driver.id]['in'].sort();
    this.nodes = this.mda.nodes;
    this.edges = this.mda.edges.concat(this.mda.inactive_edges);
    this.connections = this.computeConnections(this.edges);
  }

  isInputVarCases(c) {
    return this.inputVariables.find((v) => v.name === c.varname);
  }
  isOutputVarCases(c) {
    return this.outputVariables.find((v) => v.name === c.varname);
  }
  isCouplingVarCases(c) {
    return !(this.inputVariables.find((v) => v.name === c.varname)
             || this.outputVariables.find((v) => v.name === c.varname));
  }

  isObjective(c) {
    this.objective = this.objective || this.getObjective();
    if (this.objective) {
      return this.objective.variable.name === c.varname;
    }
    return false;
  }
  isMinObjective() {
    return this.getObjective().isMin;
  }
  isMaxObjective() {
    return !this.getObjective().isMin;
  }
  isConstraint(c) {
    this.constraints = this.constraints || this.getConstraints();
    return this.constraints.map((cstr) => cstr.name).includes(c.varname);
  }

  getObjective() {
    if (this.objective) {
      return this.objective;
    }
    let isMin;
    let conn;
    for (let i=0; i<this.connections.length; i++) {
      if (this.connections[i].role === "min_objective"
          || this.connections[i].role === "max_objective") {
        conn = this.connections[i];
        isMin = (conn.role === "min_objective");
        break;
      }
    }
    if (conn) {
      this.objective = {variable: this.outputVariables.find((v) => v.name === conn.name),
                         isMin: isMin};
    }
    return this.objective;
  }

  getConstraints() {
    if (this.constraints) {
      return this.constraints;
    }
    let connCstrs = this.connections.filter((c) => c.role === "ineq_constraint" || c.role === "eq_constraint");
    let cstrNames = connCstrs.map((c) => c.name);
    this.constraints = this.outputVariables.filter((v) => cstrNames.includes(v.name));
    return this.constraints;
  }

  computeConnections(filter) {
    let edges = this.edges;
    let nodeSelected = filter && filter.fr && (filter.fr === filter.to);

    if (filter && filter.fr && filter.to) {
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
    vars.forEach((v, i) => {
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
            connId: edge.conn_ids[i],
            role: edge.roles[i],
          };
        }
      }, this);
    }, this);

    let conns = [];
    for (let id in hconns) {
      conns.push(hconns[id]);
    }
    conns.sort((a, b) => this._connectionCompare(nodeSelected, a, b));

    let connections = conns.map((conn) => {
      let infos = this._findInfos(conn);
      let val = {id: conn.connId, from: conn.frName, to: conn.toName.join(', '), name: infos.vName, desc: infos.desc,
                  type: infos.type, shape: infos.shape, units: infos.units, init: infos.init, lower: infos.lower,
                  upper: infos.upper, active: infos.active, role: conn.role, fromId: conn.fr, toIds: conn.to};
      return val;
    });

    return connections;
  }

  _findNode(id) {
    for (var i=0; i < this.mda.nodes.length; i++) {
      let node = this.mda.nodes[i];
      if (node.id === id) {
        return (i==0)?{id: id, name: "Driver"}:{id: node.id, name: node.name};
      }
    };
    throw Error("Node id ("+ id +") unknown: " + JSON.stringify(this.mda.nodes));
  };

  _findInfos(conn) {
    let vfr = this._findVariable(conn.fr, conn.varname, "out");
    let desc = vfr.desc;
    let vartype = vfr.type;
    let shape = vfr.shape;
    let varname = vfr.name;
    let units = vfr.units;
    let init = "";
    let lower = "";
    let upper = "";
    let active = vfr.active;

    if (vfr.parameter) {
      init = vfr.parameter.init;
      lower = vfr.parameter.lower;
      upper = vfr.parameter.upper;
    }
    let infos = {id: conn.connId, idfrName: conn.frName, frUnits: vfr.units,
                  vName: varname, desc: desc,
                  toName: conn.toName.join(', '),
                  type: vartype, shape: shape, init: init, lower: lower, upper: upper,
                  units: units, active: active};
    return infos;
  }

  _findVariable(disc, vname, ioMode) {
    let vars = this.mda.vars;
    let vinfo = {units: '', desc: '', type: '', shape: '', init: '', lower: '', upper: '', active: true};
    let vinfos = vars[disc][ioMode].filter((v) => {
      return v.name === vname;
    });
    if (vinfos.length === 1) {
      vinfo = vinfos[0];
    } else if (vinfos.length > 1) {
      console.log("Find several occurences of " + vname + "("+ioMode +"): " + JSON.stringify(vinfos));
      console.log("Check against fullnames");
      vinfos = vars[disc][ioMode].filter((v) => {
        return v.fullname === vname;
      });
      if (vinfos.length === 1) {
        vinfo = vinfos[0];
      } else {
        throw Error(`Expected one variable ${vname} found ${vinfos.length} in ${JSON.stringify(vars[disc][ioMode])}`);
      }
    } else {
      // console.log("Find no occurence of " + vname + "(" + ioMode + "): " +
      // JSON.stringify(vinfos));
      // console.log("Check against fullnames");
      vinfos = vars[disc][ioMode].filter((v) => {
        return v.fullname === vname;
      });
      if (vinfos.length === 1) {
        vinfo = vinfos[0];
      } else {
        throw Error(`Expected one variable ${vname} found ${vinfos.length} in ${JSON.stringify(vars[disc][ioMode])}`);
      }
    }
    return vinfo;
  }

  _connectionCompare(nodeSelected, conna, connb) {
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
  }
}

export default AnalysisDatabase;
