class AnalysisDatabase {
  constructor(mda) {
    this.mda = mda;
    this.driver = this.mda.nodes[0];
    this.varList = [];
    for (const d in mda.vars) {
      this.varList.push(...mda.vars[d]['out']);
    }
    this.inputVariables = mda.vars[this.driver.id]['out'].sort();
    this.outputVariables = mda.vars[this.driver.id]['in'].sort();
    this.nodes = this.mda.nodes;
    this.edges = this.mda.edges.concat(this.mda.inactive_edges);
    this.connections = this.computeConnections(this.edges);
  }

  isScaled() {
    return !!this.varList.find((v) => v.scaling);
  }

  isInputVarCases(c) {
    return this.inputVariables.find((v) => v.name === c.varname);
  }
  isDesignVarCases(c) {
    return this.connections.find((conn) => {
      return conn.role === 'design_var' && conn.name === c.varname;
    });
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
    for (let i = 0; i < this.connections.length; i++) {
      if (this.connections[i].role === "min_objective"
        || this.connections[i].role === "max_objective") {
        conn = this.connections[i];
        isMin = (conn.role === "min_objective");
        break;
      }
    }
    if (conn) {
      this.objective = {
        variable: this.outputVariables.find((v) => v.name === conn.name),
        isMin: isMin,
      };
    }
    return this.objective;
  }

  getConstraints() {
    if (this.constraints) {
      return this.constraints;
    }
    const connCstrs = this.connections.filter((c) => c.role === "ineq_constraint" || c.role === "eq_constraint");
    const cstrNames = connCstrs.map((c) => c.name);
    this.constraints = this.outputVariables.filter((v) => cstrNames.includes(v.name));
    return this.constraints;
  }

  computeConnections(filter) {
    let edges = this.edges;
    let nodeSelected = filter && filter.fr && (filter.fr === filter.to);

    if (filter && filter.fr && filter.to) {
      const nodeFrom = this._findNode(filter.fr);
      const nodeTo = this._findNode(filter.to);
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

    const hconns = {};
    edges.forEach((edge) => {
      const vars = edge.name.split(",");
      const fromName = this._findNode(edge.from).name;
      const toName = this._findNode(edge.to).name;
      vars.forEach((v, i) => {
        const id = edge.from + '_' + v;
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
    const conns = [];
    for (const id in hconns) {
      conns.push(hconns[id]);
    }
    conns.sort((a, b) => this._connectionCompare(nodeSelected, a, b));

    const connections = conns.map((conn) => {
      const infos = this._findInfos(conn);
      const val = {
        id: conn.connId, from: conn.frName, to: conn.toName.join(', '), name: infos.vName, desc: infos.desc,
        type: infos.type, shape: infos.shape, units: infos.units, init: infos.init, ref: infos.ref,
        ref0: infos.ref0, res_ref: infos.res_ref, lower: infos.lower, upper: infos.upper, active: infos.active,
        role: conn.role, fromId: conn.fr, toIds: conn.to,
      };
      return val;
    });

    return connections;
  }

  getNodeName(id) {
    try {
      return this._findNode(id).name;
    } catch (error) {
      console.error(error);
      return "unknown_" + id;
    }
  }

  _findNode(id) {
    for (var i = 0; i < this.mda.nodes.length; i++) {
      const node = this.mda.nodes[i];
      if (node.id == id) { // weak equality to deal with 1522 == "1522" transparently
        return (i == 0) ? {id: id, name: "Driver"} : {id: node.id, name: node.name};
      }
    };
    throw Error("Node id (" + id + ") unknown: " + JSON.stringify(this.mda.nodes));
  };

  _findInfos(conn) {
    const vfr = this._findVariable(conn.fr, conn.varname, "out");
    const desc = vfr.desc;
    const vartype = vfr.type;
    const shape = vfr.shape;
    const varname = vfr.name;
    const units = vfr.units;
    let init = "";
    let lower = "";
    let upper = "";
    let ref = "";
    let ref0 = "";
    let resRef = "";
    const active = vfr.active;

    if (vfr.parameter_attributes) {
      init = vfr.parameter_attributes.init;
      lower = vfr.parameter_attributes.lower;
      upper = vfr.parameter_attributes.upper;
    }
    if (vfr.scaling_attributes) {
      ref = vfr.scaling_attributes.ref;
      ref0 = vfr.scaling_attributes.ref0;
      resRef = vfr.scaling_attributes.res_ref;
    }
    const infos = {
      id: conn.connId, idfrName: conn.frName, frUnits: vfr.units,
      vName: varname, desc: desc,
      toName: conn.toName.join(', '),
      type: vartype, shape: shape,
      init: init, lower: lower, upper: upper,
      ref: ref, ref0: ref0, res_ref: resRef,
      units: units, active: active,
    };
    return infos;
  }

  _findVariable(disc, vname, ioMode) {
    const vars = this.mda.vars;
    let vinfo = {
      units: '', desc: '', type: '', shape: '', init: '', lower: '', upper: '', ref: '', ref0: '',
      res_ref: '', active: true,
    };
    const vinfos = vars[disc][ioMode].filter((v) => {
      return v.name === vname;
    });
    if (vinfos.length === 1) {
      vinfo = vinfos[0];
    } else if (vinfos.length > 1) {
      console.log("Warning: Find several occurences of " + vname + "(" + ioMode + "): " + JSON.stringify(vinfos));
      vinfo = vinfos[0];
      console.log("Take the first: " + JSON.stringify(vinfo));
    } else {
      throw Error(`Expected one variable "${vname}" found ${vinfos.length} in ${JSON.stringify(vars[disc][ioMode])}`);
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
