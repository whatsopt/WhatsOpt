function compare(casea, caseb) {
  if (casea.varname === caseb.varname) {
    return casea.coord_index < caseb.coord_index ? -1 : 1;
  }
  return casea.varname.localeCompare(caseb.varname);
}

function label(c) {
  let lbl = c.varname;
  lbl += c.coord_index === -1 ? '' : `[${c.coord_index}]`;
  return lbl;
}

export { compare, label };
