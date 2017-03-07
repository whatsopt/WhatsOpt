//var d3 = require('d3');
//var Labelizer = require('./labelizer.js');

var WIDTH = 1000;
var HEIGHT = 500;
var X_ORIG = 100;
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
