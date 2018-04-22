function analysisDatabase(mda) {

  let varList = [];
  for (let d in mda.vars) {
    varList.push(...mda.vars[d]['out']);
  }
  let designVariables = mda.vars[mda.nodes[0].id]['out'].map((vinfo) => {return vinfo.name;}).sort();
  let outputVariables = mda.vars[mda.nodes[0].id]['in'].map((vinfo) => {return vinfo.name;}).sort();

  return ({
    'designVariables': designVariables,
    'outputVariables': outputVariables,
  
    isDesignVarCases: (c) => { return designVariables.includes(c.varname); },
    isOutputVarCases: (c) => { return outputVariables.includes(c.varname); },
    isCouplingVarCases: (c) => { return !(designVariables.includes(c.varname) 
                                          || outputVariables.includes(c.varname)); },
    
    find: (vname) => {
      let vars = mda.vars;
      let vinfos = varList.filter((v) => { 
        return v.name === vname; 
      });
      if (vinfos.length === 1) {
        return vinfos[0];
      } else {
        throw new Error("Find "+vinfos.length+" occurences of "+vname+" variable : "
            +JSON.stringify(vinfos)+"DB : "+JSON.stringify(varList));
      }
    },
  
    findVariable: (disc, vname, io_mode) => {
      let vars = mda.vars;
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
    },
  });
}
  
export { analysisDatabase };