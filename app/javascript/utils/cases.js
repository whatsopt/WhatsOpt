function compare(casea, caseb) {
  if (casea.varname === caseb.varname) {
    return casea.coord_index < caseb.coord_index ? -1 : 1
  }
  return casea.varname.localeCompare(caseb.varname);
}

export default compare