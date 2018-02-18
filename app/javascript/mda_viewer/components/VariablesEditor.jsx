import React from 'react';
import ReactTable from 'react-table'
import { RIEToggle, RIEInput, RIETextArea, RIENumber, RIETags, RIESelect } from 'riek'

class VariablesEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state = { editingConnId: null };
    this.connections = this.compute();
    this.renderEditable = this.renderEditable.bind(this);
  }

  compute() {
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
                connId: edge.conn_ids[i]
            }
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
          let badge, highlightFr, highlightTo = {};
          
          if (nodeSelected) {
            let badgeType = "badge "; 
            let ioType = "in"; 
            if (nodeSelected.id===conn.fr) {
              highlightFr = {'fontWeight': 'bold'};  
              badgeType += "badge-secondary";
              ioType = "out";
            } else { 
              highlightTo = {'fontWeight': 'bold'};  
              badgeType += "badge-primary";
            }
          }
          let val = { id: conn.connId, from: conn.frName, to: conn.toName.join(', '), name: infos.vName, desc: infos.desc,
                      type: infos.type, shape: infos.shape, units: infos.units, init: infos.init };
          return val;
          
      });
        
      return connections;
  }
  
  render() {  
    this.connections = this.compute();  
    let columns = [
                   {
                     Header: "From",
                     accessor: "from",
                   },
                   {
                     Header: "To",
                     accessor: "to",
                     minWidth: 300,
                   },
                   {
                     Header: "Variable",
                     accessor: "name", 
                     minWidth: 300, 
                     Cell: this.renderEditable 
                   },
                   {
                     Header: "Type",
                     accessor: "type", 
                     Cell: this.renderEditable 
                   },
                   {
                     Header: "Shape",
                     accessor: "shape", 
                     Cell: this.renderEditable
                   },
                   {
                     Header: "Init",
                     accessor: "init", 
                     Cell: this.renderEditable
                   },
                   {
                     Header: "Units",
                     accessor: "units", 
                     Cell: this.renderEditable
                   }
                 ];
    if (this.props.isEditing) {
      columns.splice(3, 0, {
        Header: "Description",
        accessor: "desc", 
        Cell: this.renderEditable 
      });
    }
    return (
            <div>
              <ReactTable
                data={this.connections}
                columns={columns}
                className="-striped -highlight"
                showPagination={false}
                pageSize={this.connections.length}
              />
            </div>
          );   
  };

  renderEditable(cellInfo) {
//    console.log(cellInfo.column.id);
//    console.log(this.connections[cellInfo.index][cellInfo.column.id]);
    if (this.props.isEditing) {
      return ( <RIEInput
        value={this.connections[cellInfo.index][cellInfo.column.id]}
        change={(attr) => this.props.onConnectionChange(this.connections[cellInfo.index].id, attr)}
        propName={cellInfo.column.id} /> );
    } else {  		
      return (<div>{this.connections[cellInfo.index][cellInfo.column.id]}</div>);
    }
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
  
  _findInfos(conn) { 
      let vfr = this._findVariableInfo(conn.fr, conn.varname, "out");
      let vto = this._findVariableInfo(conn.to[0], conn.varname, "in");
      let desc = vfr.desc; 
      let vartype = vfr.type;
      let shape = vfr.shape;    
      let varname = vfr.name 
      let units = vfr.units 
      let init = "";

      if (vto.parameter) { // 'to variable' used to retrieve init info
        init = vto.parameter.init;
      }
      let infos = { id: conn.connId, idfrName: conn.frName, frUnits: vfr.units, 
                    vName: varname, desc: desc,
                    toName: conn.toName.join(', '),
                    type: vartype, shape: shape, init: init, units: units};
      console.log(JSON.stringify(infos));
      return infos;
    }
      
    _findVariableInfo(disc, vname, io_mode) {
      let vars = this.props.mda.vars;
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

export default VariablesEditor;