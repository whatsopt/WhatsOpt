
class AnalysisDatabase {
  
  constructor(mda) {
    this.mda = mda;
    this.varList = [];
    for (let d in this.mda.vars) {
      this.varList.push(...this.mda.vars[d]['out']);
    }
  }
  
  designVariables() {
    return this.mda.vars[this.mda.nodes[0].id]['out'].map((vinfo) => {return vinfo.name;});
  }
  
  outputVariables() {
    return this.mda.vars[this.mda.nodes[0].id]['in'].map((vinfo) => {return vinfo.name;});
  }
  
  find(vname) {
    let vars = this.mda.vars;
    let vinfos = this.varList.filter((v) => { 
      return v.name === vname; 
    });
    if (vinfos.length === 1) {
      return vinfos[0];
    } else {
      throw new Error("Find "+vinfos.length+" occurences of "+vname+" variable : "
                       +JSON.stringify(vinfos)+"DB : "+JSON.stringify(this.varList));
    }
  }
  
  findVariable(disc, vname, io_mode) {
    let vars = this.mda.vars;
    let vinfo = {units: '', desc: '', type: '', shape: '', init: '', lower: '', upper: '', active: true};
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
      // console.log("Find no occurence of " + vname + "(" + io_mode + "): " +
      // JSON.stringify(vinfos));
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
  
export { AnalysisDatabase };