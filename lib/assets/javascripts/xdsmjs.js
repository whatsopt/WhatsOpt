var UID = "_U_";
var MULTI_TYPE = "_multi";

function Node(id, name, type) {
  if (typeof (name) === 'undefined') {
    name = id;
  }
  if (typeof (type) === 'undefined') {
    type = 'analysis';
  }
  this.id = id;
  this.name = name;
  this.isMulti = (type.search(/_multi$/) >= 0);
  this.type = this.isMulti ?
    type.substr(0, type.length - MULTI_TYPE.length) : type;
}

Node.prototype.isMdo = function() {
  return this.type === "mdo";
};

Node.prototype.getScenarioId = function() {
  if (this.isMdo()) {
    var idxscn = this.name.indexOf("_scn-");
    if (idxscn === -1) {
      console.log("Warning: MDO Scenario not found. " +
                  "Bad type or name for node: " + JSON.stringify(this));
      return null;
    }
    return this.name.substr(idxscn + 1);
  }
  return null;
};

function Edge(from, to, name, row, col, isMulti) {
  this.id = "link_" + from + "_" + to;
  this.name = name;
  this.row = row;
  this.col = col;
  this.iotype = row < col ? "in" : "out";
  this.io = {
    fromU: (from === UID),
    toU: (to === UID)
  };
  this.isMulti = isMulti;
}

Edge.prototype.isIO = function() {
  return this.io.fromU || this.io.toU;
};

function Graph(mdo, refname) {
  this.nodes = [new Node(UID, UID, "user")];
  this.nodeIds = [UID];
  this.edges = [];
  this.chains = [];
  this.refname = refname || "";

  var numbering = Graph.number(mdo.workflow);
  var numPrefixes = numbering.toNum;
  this.nodesByStep = numbering.toNode;

  mdo.nodes.forEach(function(item) {
    var num = numPrefixes[item.id];
    this.nodes.push(new Node(item.id,
      num ? num + ":" + item.name : item.name,
      item.type));
  }, this);

  this.ids = this.nodes.map(function(elt) {
    return elt.id;
  });

  mdo.edges.forEach(function(item) {
    var idA = this.idxOf(item.from);
    var idB = this.idxOf(item.to);
    var isMulti = this.nodes[idA].isMulti || this.nodes[idB].isMulti;
    this.edges.push(new Edge(item.from, item.to, item.name, idA, idB, isMulti));
  }, this);

  var echain = Graph.expand(mdo.workflow);
  echain.forEach(function(leafChain) {
    if (leafChain.length < 2) {
      throw new Error("Bad process chain (" + leafChain.length + "elt)");
    } else {
      this.chains.push([]);
      var ids = this.nodes.map(function(elt) {
        return elt.id;
      });
      leafChain.forEach(function(item, j) {
        if (j !== 0) {
          var idA = ids.indexOf(leafChain[j - 1]);
          if (idA < 0) {
            throw new Error("Process chain element (" +
                            leafChain[j - 1] + ") not found");
          }
          var idB = ids.indexOf(leafChain[j]);
          if (idB < 0) {
            throw new Error("Process chain element (" +
                            leafChain[j] + ") not found");
          }
          if (idA !== idB) {
            this.chains[this.chains.length - 1].push([idA, idB]);
          }
        }
      }, this);
    }
  }, this);
}

Graph.prototype.idxOf = function(nodeId) {
  return this.ids.indexOf(nodeId);
};
Graph.prototype.getNode = function(nodeId) {
  return this.nodes[this.ids.indexOf(nodeId)];
};

function _expand(workflow) {
  var ret = [];
  var prev;
  workflow.forEach(function(item) {
    if (item instanceof Array) {
      if (item[0].hasOwnProperty('parallel')) {
        if (prev) {
          ret = ret.slice(0, ret.length - 1).concat(item[0].parallel.map(
              function(elt) {
                return [prev].concat(_expand([elt]), prev);
              }));
        } else {
          throw new Error("Bad workflow structure : " +
              "cannot parallel loop without previous starting point.");
        }
      } else if (prev) {
        ret = ret.concat(_expand(item), prev);
      } else {
        ret = ret.concat(_expand(item));
      }
      prev = ret[ret.length - 1];
    } else if (item.hasOwnProperty('parallel')) {
      if (prev) {
        ret = ret.slice(0, ret.length - 1).concat(
            item.parallel.map(function(elt) {
              return [prev].concat(_expand([elt]));
            }));
      } else {
        ret = ret.concat(item.parallel.map(
            function(elt) {
              return _expand([elt]);
            }));
      }
      prev = undefined;
    } else {
      var i = ret.length - 1;
      var flagParallel = false;
      while (i >= 0 && (ret[i] instanceof Array)) {
        ret[i] = ret[i].concat(item);
        i -= 1;
        flagParallel = true;
      }
      if (!flagParallel) {
        ret.push(item);
      }
      prev = item;
    }
  }, this);
  return ret;
}

Graph._isPatchNeeded = function(toBePatched) {
  var lastElts = toBePatched.map(function(arr) {
    return arr[arr.length - 1];
  });
  var lastElt = lastElts[0];
  for (var i = 0; i < lastElts.length; i++) {
    if (lastElts[i] !== lastElt) {
      return true;
    }
  }
  return false;
};

Graph._patchParallel = function(expanded) {
  var toBePatched = [];
  expanded.forEach(function(elt) {
    if (elt instanceof Array) {
      toBePatched.push(elt);
    } else if (Graph._isPatchNeeded(toBePatched)) {
      toBePatched.forEach(function(arr) {
        arr.push(elt);
      }, this);
    }
  }, this);
};

Graph.expand = function(item) {
  var expanded = _expand(item);
  var result = [];
  var current = [];
  // first pass to add missing 'end link' in case of parallel branches at the end of a loop
  // [a, [b, d], [b, c], a] -> [a, [b, d, a], [b, c, a], a]
  Graph._patchParallel(expanded);
  // [a, aa, [b, c], d] -> [[a, aa, b], [b,c], [c, d]]
  expanded.forEach(function(elt) {
    if (elt instanceof Array) {
      if (current.length > 0) {
        current.push(elt[0]);
        result.push(current);
        current = [];
      }
      result.push(elt);
    } else {
      if (result.length > 0 && current.length === 0) {
        var lastChain = result[result.length - 1];
        var lastElt = lastChain[lastChain.length - 1];
        current.push(lastElt);
      }
      current.push(elt);
    }
  }, this);
  if (current.length > 0) {
    result.push(current);
  }
  return result;
};

Graph.number = function(workflow, num) {
  num = (typeof num === 'undefined') ? 0 : num;
  var toNum = {};
  var toNode = [];

  function setStep(step, nodeId) {
    if (step in toNode) {
      toNode[step].push(nodeId);
    } else {
      toNode[step] = [nodeId];
    }
  }

  function setNum(nodeId, beg, end) {
    if (end === undefined) {
      num = String(beg);
      setStep(beg, nodeId);
    } else {
      num = end + "-" + beg;
      setStep(end, nodeId);
    }
    if (nodeId in toNum) {
      toNum[nodeId] += "," + num;
    } else {
      toNum[nodeId] = num;
    }
  }

  function _number(wks, num) {
    var ret = 0;
    if (wks instanceof Array) {
      if (wks.length === 0) {
        ret = num;
      } else if (wks.length === 1) {
        ret = _number(wks[0], num);
      } else {
        var head = wks[0];
        var tail = wks.slice(1);
        var beg = _number(head, num);
        if (tail[0] instanceof Array) {
          var end = _number(tail[0], beg);
          setNum(head, beg, end);
          beg = end + 1;
          tail.shift();
        }
        ret = _number(tail, beg);
      }
    } else if ((wks instanceof Object) && 'parallel' in wks) {
      var nums = wks.parallel.map(function(branch) {
        return _number(branch, num);
      });
      ret = Math.max.apply(null, nums);
    } else {
      setNum(wks, num);
      ret = num + 1;
    }
    return ret;
  }

  _number(workflow, num);
  // console.log('toNodes=', JSON.stringify(toNode));
  // console.log('toNum=',JSON.stringify(toNum));
  return {toNum: toNum, toNode: toNode};
};

//module.exports = Graph;
function Labelizer() {}

Labelizer.strParse = function(str) {
  if (str === "") {
    return [{base: '', sub: undefined, sup: undefined}];
  }

  var lstr = str.split(',');
  var underscores = /_/g;
  var rg = /([0-9\-]+:)?([A-Za-z0-9\-\.]+)(_[A-Za-z0-9\-\._]+)?(\^.+)?/;

  var res = lstr.map(function(s) {
    var base;
    var sub;
    var sup;

    if ((s.match(underscores) || []).length > 1) {
      var mu = s.match(/(.+)\^(.+)/);
      if (mu) {
        return {base: mu[1], sub: undefined, sup: mu[2]};
      }
      return {base: s, sub: undefined, sup: undefined};
    }
    var m = s.match(rg);
    if (m) {
      base = (m[1] ? m[1] : "") + m[2];
      if (m[3]) {
        sub = m[3].substring(1);
      }
      if (m[4]) {
        sup = m[4].substring(1);
      }
    } else {
      throw new Error("Labelizer.strParse: Can not parse '" + s + "'");
    }
    return {base: base, sub: sub, sup: sup};
  }, this);

  return res;
};

Labelizer.labelize = function() {
  var ellipsis = 0;

  function createLabel(selection) {
    selection.each(function(d) {
      var tokens = Labelizer.strParse(d.name);
      var text = selection.append("text");
      tokens.every(function(token, i, ary) {
        var offsetSub = 0;
        var offsetSup = 0;
        if (ellipsis < 1 || (i < 5 && text.nodes()[0].getBBox().width < 100)) {
          text.append("tspan").text(token.base);
          if (token.sub) {
            offsetSub = 10;
            text.append("tspan")
              .attr("class", "sub")
              .attr("dy", offsetSub)
              .text(token.sub);
          }
          if (token.sup) {
            offsetSup = -10;
            text.append("tspan")
              .attr("class", "sup")
              .attr("dx", -5)
              .attr("dy", -offsetSub + offsetSup)
              .text(token.sup);
            offsetSub = 0;
          }
        } else {
          text.append("tspan")
            .attr("dy", -offsetSub - offsetSup)
            .text("...");
          selection.classed("ellipsized", true);
          return false;
        }
        if (i < ary.length - 1) {
          text.append("tspan")
            .attr("dy", -offsetSub - offsetSup)
            .text(", ");
        }
        return true;
      }, this);
    });
  }

  createLabel.ellipsis = function(value) {
    if (!arguments.length) {
      return ellipsis;
    }
    ellipsis = value;
    return createLabel;
  };

  return createLabel;
};

Labelizer.tooltipize = function() {
  var text = "";

  function createTooltip(selection) {
    var tokens = Labelizer.strParse(text);
    var html = [];
    tokens.forEach(function(token) {
      var item = token.base;
      if (token.sub) {
        item += "<sub>" + token.sub + "</sub>";
      }
      if (token.sup) {
        item += "<sup>" + token.sup + "</sup>";
      }
      html.push(item);
    }, this);
    selection.html(html.join(", "));
  }

  createTooltip.text = function(value) {
    if (!arguments.length) {
      return text;
    }
    text = value;
    return createTooltip;
  };

  return createTooltip;
};

//module.exports = Labelizer;
//var d3 = require('d3');
//var Labelizer = require('./labelizer.js');

var WIDTH = 1000;
var HEIGHT = 500;
var X_ORIG = 0;
var Y_ORIG = 20;
var PADDING = 20;
var CELL_W = 250;
var CELL_H = 75;
var MULTI_OFFSET = 3;

function Cell(x, y, width, height) {
  this.x = x;
  this.y = y;
  this.width = width;
  this.height = height;
}

function Xdsm(graph, svgid, tooltip) {
  this.graph = graph;
  this.tooltip = tooltip;
  var container = d3.select(".xdsm");
  this.svg = container.append("svg")
                 .attr("width", WIDTH)
                 .attr("height", HEIGHT)
                 .attr("class", svgid);

  this.grid = [];
  this.nodes = [];
  this.edges = [];
}

Xdsm.prototype.draw = function() {
  var self = this;

  if (self.graph.refname) {
    var ref = self.svg.append('g').classed('title', true);

    ref.append("text").text(self.graph.refname);
    var bbox = ref.nodes()[0].getBBox();
    ref.insert("rect", "text")
        .attr('x', bbox.x)
        .attr('y', bbox.y)
        .attr('width', bbox.width)
        .attr('height', bbox.height);

    ref.attr('transform',
             'translate(' + X_ORIG + ',' + (Y_ORIG + bbox.height) + ')');
  }

  self.nodes = self._createTextGroup("node");
  self.edges = self._createTextGroup("edge");

  // Workflow
  self._createWorkflow();

  // Layout texts
  self._layoutText(self.nodes);
  self._layoutText(self.edges);

  // Rectangles for nodes
  self.nodes.each(function(d, i) {
    var that = d3.select(this);
    that.call(self._customRect.bind(self), d, i, 0);
    if (d.isMulti) {
      that.call(self._customRect.bind(self), d, i, 1 * Number(MULTI_OFFSET));
      that.call(self._customRect.bind(self), d, i, 2 * Number(MULTI_OFFSET));
    }
  });

  // Trapezium for edges
  self.edges.each(function(d, i) {
    var that = d3.select(this);
    that.call(self._customTrapz.bind(self), d, i, 0);
    if (d.isMulti) {
      that.call(self._customTrapz.bind(self), d, i, 1 * Number(MULTI_OFFSET));
      that.call(self._customTrapz.bind(self), d, i, 2 * Number(MULTI_OFFSET));
    }
  });

  // Dataflow
  self._createDataflow(self.edges);

  // set svg size
  var w = CELL_W * (self.graph.nodes.length + 1);
  var h = CELL_H * (self.graph.nodes.length + 1);
  self.svg.attr("width", w).attr("height", h);

  var bordercolor = 'black';
  self.svg.append("rect")
            .classed("border", true)
            .attr("x", 4)
            .attr("y", 4)
            .attr("height", h - 4)
            .attr("width", w - 4)
            .style("stroke", bordercolor)
            .style("fill", "none")
            .style("stroke-width", 0);
};

Xdsm.prototype._createTextGroup = function(kind) {
  var self = this;

  var group = self.svg.append('g').attr("class", kind + "s");

  var textGroups =
    group.selectAll("." + kind)
      .data(this.graph[kind + "s"])
    .enter()
      .append("g").attr("class", function(d) {
        var klass = kind === "node" ? d.type : "dataInter";
        if (klass === "dataInter" && d.isIO()) {
          klass = "dataIO";
        }
        return d.id + " " + kind + " " + klass;
      }).each(function() {
        var labelize = Labelizer.labelize().ellipsis(5);
        d3.select(this).call(labelize);
      });

  d3.selectAll(".ellipsized").on("mouseover", function(d) {
    self.tooltip.transition().duration(200).style("opacity", 0.9);
    var tooltipize = Labelizer.tooltipize().text(d.name);
    self.tooltip.call(tooltipize)
      .style("width", "200px")
      .style("left", (d3.event.pageX) + "px")
      .style("top", (d3.event.pageY - 28) + "px");
  }).on("mouseout", function() {
    self.tooltip.transition().duration(500).style("opacity", 0);
  });

  return textGroups;
};

Xdsm.prototype._createWorkflow = function() {
  //  console.log(JSON.stringify(this.graph.chains));
  var workflow = this.svg.insert("g", ":first-child")
                    .attr("class", "workflow");

  workflow.selectAll("g")
    .data(this.graph.chains)
  .enter()
    .insert('g').attr("class", "workflow-chain")
    .selectAll('polyline')
      .data(function(d) { return d; })  // eslint-disable-line brace-style
    .enter()
      .append("polyline")
        .attr("class", function(d) {
          return "link_" + d[0] + "_" + d[1];
        })
        .attr("points", function(d) {
          var w = CELL_W * Math.abs(d[0] - d[1]);
          var h = CELL_H * Math.abs(d[0] - d[1]);
          var points = [];
          if (d[0] < d[1]) {
            if (d[0] !== 0) {
              points.push((-w) + ",0");
            }
            points.push("0,0");
            if (d[1] !== 0) {
              points.push("0," + h);
            }
          } else {
            if (d[0] !== 0) {
              points.push(w + ",0");
            }
            points.push("0,0");
            if (d[1] !== 0) {
              points.push("0," + (-h));
            }
          }
          return points.join(" ");
        })
      .attr("transform", function(d) {
        var max = Math.max(d[0], d[1]);
        var min = Math.min(d[0], d[1]);
        var w;
        var h;
        if (d[0] < d[1]) {
          w = CELL_W * max + X_ORIG;
          h = CELL_H * min + Y_ORIG;
        } else {
          w = CELL_W * min + X_ORIG;
          h = CELL_H * max + Y_ORIG;
        }
        return "translate(" + (X_ORIG + w) + "," + (Y_ORIG + h) + ")";
      });
};

Xdsm.prototype._createDataflow = function(edges) {
  var dataflow = this.svg.insert("g", ":first-child")
                   .attr("class", "dataflow");

  edges.each(function(d, i) {
    dataflow.insert("polyline", ":first-child")
      .attr("points", function() {
        var w = CELL_W * Math.abs(d.col - d.row);
        var h = CELL_H * Math.abs(d.col - d.row);
        var points = [];
        if (d.iotype === "in") {
          if (!d.io.fromU) {
            points.push((-w) + ",0");
          }
          points.push("0,0");
          if (!d.io.toU) {
            points.push("0," + h);
          }
        } else {
          if (!d.io.fromU) {
            points.push(w + ",0");
          }
          points.push("0,0");
          if (!d.io.toU) {
            points.push("0," + (-h));
          }
        }
        return points.join(" ");
      }).attr("transform", function() {
        var m = (d.col === undefined) ? i : d.col;
        var n = (d.row === undefined) ? i : d.row;
        var w = CELL_W * m + X_ORIG;
        var h = CELL_H * n + Y_ORIG;
        return "translate(" + (X_ORIG + w) + "," + (Y_ORIG + h) + ")";
      });
  });
};

Xdsm.prototype._layoutText = function(items) {
  var grid = this.grid;
  items.each(function(d, i) {
    var item = d3.select(this);
    if (grid[i] === undefined) {
      grid[i] = new Array(items.length);
    }
    item.select("text").each(function(d, j) {
      var that = d3.select(this);
      var data = item.data()[0];
      var m = (data.row === undefined) ? i : data.row;
      var n = (data.col === undefined) ? i : data.col;
      var bbox = that.nodes()[j].getBBox();
      grid[m][n] = new Cell(-bbox.width / 2, 0, bbox.width, bbox.height);
      that.attr("x", function() {
        return grid[m][n].x;
      }).attr("y", function() {
        return grid[m][n].y;
      }).attr("width", function() {
        return grid[m][n].width;
      }).attr("height", function() {
        return grid[m][n].height;
      });
    });
  });

  items.attr("transform", function(d, i) {
    var m = (d.col === undefined) ? i : d.col;
    var n = (d.row === undefined) ? i : d.row;
    var w = CELL_W * m + X_ORIG;
    var h = CELL_H * n + Y_ORIG;
    return "translate(" + (X_ORIG + w) + "," + (Y_ORIG + h) + ")";
  });
};

Xdsm.prototype._customRect = function(node, d, i, offset) {
  var grid = this.grid;
  node.insert("rect", ":first-child").attr("x", function() {
    return grid[i][i].x + offset - PADDING;
  }).attr("y", function() {
    return -grid[i][i].height * 2 / 3 - PADDING - offset;
  }).attr("width", function() {
    return grid[i][i].width + (PADDING * 2);
  }).attr("height", function() {
    return grid[i][i].height + (PADDING * 2);
  }).attr("rx", function() {
    var rounded = d.type === 'optimization' ||
                  d.type === 'mda' ||
                  d.type === 'doe';
    return rounded ? (grid[i][i].height + (PADDING * 2)) / 2 : 0;
  }).attr("ry", function() {
    var rounded = d.type === 'optimization' ||
                  d.type === 'mda' ||
                  d.type === 'doe';
    return rounded ? (grid[i][i].height + (PADDING * 2)) / 2 : 0;
  });
};

Xdsm.prototype._customTrapz = function(edge, d, i, offset) {
  var grid = this.grid;
  edge.insert("polygon", ":first-child").attr("points", function(d) {
    var pad = 5;
    var w = grid[d.row][d.col].width;
    var h = grid[d.row][d.col].height;
    var topleft = (-pad - w / 2 + offset) + ", " +
                  (-pad - h * 2 / 3 - offset);
    var topright = (w / 2 + pad + offset + 5) + ", " +
                   (-pad - h * 2 / 3 - offset);
    var botright = (w / 2 + pad + offset - 5 + 5) + ", " +
                   (pad + h / 3 - offset);
    var botleft = (-pad - w / 2 + offset - 5) + ", " +
                  (pad + h / 3 - offset);
    var tpz = [topleft, topright, botright, botleft].join(" ");
    return tpz;
  });
};

//module.exports = Xdsm;
