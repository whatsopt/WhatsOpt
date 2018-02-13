import React from 'react';
import XdsmViewer from 'mda_viewer/components/XdsmViewer'
import Connections from 'mda_viewer/components/Connections'
import ToolBar from 'mda_viewer/components/ToolBar'
import DisciplinesEditor from 'mda_viewer/components/DisciplinesEditor'
import ConnectionsEditor from 'mda_viewer/components/ConnectionsEditor'
import update from 'immutability-helper'
let Graph = require('XDSMjs/src/graph');
import {api, url} from '../utils/WhatsOptApi';

let VAR_REGEXP = /^[a-zA-Z][a-zA-Z0-9]*$/;

class MdaViewer extends React.Component {
    
  constructor(props) {
    super(props);
//    let nodes = props.mda.nodes.map(function(n) { return {id: n.id, name: n.name, type: n.type}; });
//    let edges = props.mda.edges.map(function(e) { return {from: e.from, to: e.to, name: e.name, conn_ids}; });
    let isEditing = props.isEditing;
    let filter = { fr: undefined, to: undefined };
    if (isEditing) {
      filter = { fr: "_U_", to: "_U_" };
    } 
    this.state = {
      filter: filter,
      isEditing: isEditing,
      //mda: { name: props.mda.name, nodes: nodes, edges: edges, vars: props.mda.vars },
      mda: props.mda,
      newAnalysisName: props.mda.name,
      newDisciplineName: '',
      newConnectionName: '',
      errors: []
    }
    this.handleFilterChange = this.handleFilterChange.bind(this);
    this.handleAnalysisNameChange = this.handleAnalysisNameChange.bind(this);
    this.handleAnalysisUpdate = this.handleAnalysisUpdate.bind(this);
    this.handleDisciplineNameChange = this.handleDisciplineNameChange.bind(this);
    this.handleDisciplineCreate = this.handleDisciplineCreate.bind(this);
    this.handleDisciplineUpdate = this.handleDisciplineUpdate.bind(this);
    this.handleDisciplineDelete = this.handleDisciplineDelete.bind(this);
    this.handleConnectionNameChange = this.handleConnectionNameChange.bind(this); 
    this.handleConnectionCreate = this.handleConnectionCreate.bind(this); 
    this.handleConnectionDelete = this.handleConnectionDelete.bind(this); 
  }
  
  handleFilterChange(filter) { 
    let newState = update(this.state, {filter: {$set: filter}});
    this.setState(newState);
    this.xdsmViewer.setSelection(filter);
  }
  
  // *** Connections *********************************************************
  
  _validateConnectionNames(namesStr) {
    let names = namesStr.split(',');
    names = names.map((name) => { return name.trim(); });
    let errors = [];
    names.forEach((name) => {
      if (!name.match(VAR_REGEXP)) {
        if (name !== '') {
          errors.push(`Variable name '${name}' is invalid`);   
          console.log("Error: " + errors);
        }
      }
    }, this);  
    return errors;
  }
  
  handleConnectionNameChange(event) {
    event.preventDefault();  
    let errors = this._validateConnectionNames(event.target.value);
    let newState = update(this.state, { newConnectionName: {$set: event.target.value}, 
                                        errors: {$set: errors} });
    this.setState(newState);
  }

  handleConnectionCreate(event) {
    event.preventDefault();

    if (this.state.errors.length > 0) {
      return;
    }
    let names = this.state.newConnectionName.split(',');
    names = names.map((name) => { return name.trim(); });
    names = names.filter((name) => name !== '');
    
    api.createConnection(this.props.mda.id, 
        {from: this.state.filter.fr, to: this.state.filter.to, names: names},
        (response) => {
//            let newconn = response.data;
//            this._addConnection(newconn);
            //this.xdsmViewer.addConnection(newconn);
            let newState = update(this.state, {newConnectionName: {$set: ''}});
            this.setState(newState);
            this.renderXdsm();
          },
        (error) => { 
          let message = error.response.data.message;
          let newState = update(this.state, {errors: {$set: [message]}});
          this.setState(newState);
        });
  };
  
//  _addConnection(connattrs) {
//    console.log("ADDCONN "+JSON.stringify(connattrs));
//    let found = false;
//    let newState;
//    this.state.mda.edges.forEach((edge, i) => {
//      if (connattrs.from === edge.from && connattrs.to === edge.to) {
//        found = true;
//        console.log(JSON.stringify(edge));
//        let names = edge.name.split(',');
//        names.push(connattrs.names);
//        let newName = names.sort().join(','); 
//        console.log(newName);
//        newState = update(this.state, {mda: {edges: {[i]: {name: {$set: newName}}}}, 
//                                       newConnectionName: {$set: ''}});  
//      }    
//    }, this);
//    if (!found) {
//      let newEdge = { from: connattrs.from, to: connattrs.to, name: connattrs.names.join(',') }
//      newState = update(this.state, {mda: {edges: {$push: [newEdge]}}, 
//                                     newConnectionName: {$set: ''}});  
//    }
//    this.setState(newState); 
//    console.log("END ADDCONN ");
//  }

//  handleConnectionDelete(varname) {
//    api.deleteConnection({from: this.state.filter.fr, to: this.state.filter.to, names: [varname]},
//      (response) => {
////        let connattrs = { from: this.state.filter.fr, to: this.state.filter.to, names: [varname] };
////        this._deleteConnection(connattrs);
//        this.renderXdsm();
//        //this.xdsmViewer.removeConnection(connattrs);
//      });
//  }
  
  handleConnectionDelete(connId) {
    api.deleteConnection(connId, (response) => { this.renderXdsm(); });
  }
  
//  _deleteConnection(connattrs) {
//     let newState;
//     this.state.mda.edges.forEach((edge, i) => {
//       if (connattrs.from === edge.from && connattrs.to === edge.to) {
//         let names = edge.name.split(',');
//         connattrs.names.forEach((name) => {
//           let index = names.indexOf(name);
//           if (index < 0) {
//             console.log("Warning delete connection: connection " + connattrs + " not found.")  
//           } else {
//             names.splice(index, 1);  
//           }
//         });
//         if (names.length > 0) {
//           let newName = names.sort().join(','); 
//           newState = update(this.state, {mda: {edges: {[i]: {name: {$set: newName}}}}});
//         } else {
//           newState = update(this.state, {mda: {edges: {$splice: [[i, 1]] }}});  
//         }
//         this.setState(newState); 
//       }    
//     }, this);
//  }
  
  // *** Disciplines ************************************************************

  handleDisciplineCreate(event) { 
    event.preventDefault();
    api.createDiscipline(this.props.mda.id, {name: this.state.newDisciplineName, type: 'analysis'}, 
      (response) => {
//        let newdisc = {id: response.data.id.toString(), name: this.state.newDisciplineName, type: 'analysis'};
//        let newState = update(this.state, {mda: {nodes: {$push: [newdisc]}}, newDisciplineName: {$set: ''}});
//        this.setState(newState);
        let newState = update(this.state, {newDisciplineName: {$set: ''}});
        this.setState(newState);
        this.renderXdsm();
      });
  }
  
  handleDisciplineNameChange(event) { 
    event.preventDefault();
    let newState = update(this.state, {newDisciplineName: {$set: event.target.value}});
    this.setState(newState);
    return false;
  }
    
  handleDisciplineUpdate(node, pos, discattrs) {
    api.updateDiscipline(node.id, discattrs,
        (response) => {
//          let index = pos-1;
//          let newState = update(this.state, {mda: {nodes: {[index]: {$merge: discattrs }} }});
//          this.setState(newState);
          this.renderXdsm();
          //this.xdsmViewer.updateDiscipline(pos, discattrs);
        });
  }
  
  handleDisciplineDelete(node, pos) {
    api.deleteDiscipline(node.id, 
        (response) => {
//          let newState = update(this.state, {mda: {nodes: {$splice: [[pos-1, 1]]}}});
//          this.setState(newState);
          this.renderXdsm();
          //this.xdsmViewer.removeDiscipline(pos);
        });
  }
  
  // *** Analysis ************************************************************
  handleAnalysisNameChange(event) { 
    event.preventDefault();
    let newState = update(this.state, {newAnalysisName: {$set: event.target.value}});
    this.setState(newState);
    return false;
  }
  
  handleAnalysisUpdate(event) { 
      event.preventDefault(); 
      api.updateAnalysis(this.props.mda.id, {name: this.state.newAnalysisName}, 
        (response) => {
          let newState = update(this.state, {mda: { name: {$set: this.state.newAnalysisName}}});
          this.setState(newState);
        });
    }

  
  renderXdsm() {
    api.getAnalysisXdsm(this.props.mda.id, 
        (response) => {
//          let nodes = response.data.nodes.map((n) => { return {id: n.id, name: n.name, type: n.type}; });
//          let edges = response.data.edges.map((e) => { return {from: e.from, to: e.to, name: e.name, }; });
          let newState = update(this.state, 
             {mda: {nodes: {$set: response.data.nodes}, 
                    edges: {$set: response.data.edges}, 
                    vars:  {$set: response.data.vars}}});
          this.setState(newState);
          let mda = {nodes: response.data.nodes, edges: response.data.edges};
          this.xdsmViewer.update(mda);
        }); 
  }
  
  render() {
    if (this.state.isEditing) {
      return(
      <div>
        <form className="button_to" method="get" action={url(`/analyses/${this.props.mda.id}`)}>
          <button className="btn float-right" type="submit">
            <i className="fa fa-times-circle" /> Close
          </button>
        </form>
        <h1>Edit {this.state.mda.name}</h1>
        <div className="mda-section">     
          <XdsmViewer ref={xdsmViewer => this.xdsmViewer = xdsmViewer} mda={this.state.mda} 
                      filter={this.state.filter} onFilterChange={this.handleFilterChange}/>
        </div>
        <ul className="nav nav-tabs" id="myTab" role="tablist">
          <li className="nav-item">
            <a className="nav-link " id="analysis-tab" data-toggle="tab" href="#analysis" role="tab" aria-controls="analysis" aria-selected="false">Analysis</a>
          </li>
          <li className="nav-item">
            <a className="nav-link" id="disciplines-tab" data-toggle="tab" href="#disciplines" role="tab" aria-controls="disciplines" aria-selected="false">Disciplines</a>
          </li>
          <li className="nav-item">
            <a className="nav-link active" id="connection-tab" data-toggle="tab" href="#connections" role="tab" aria-controls="connections" aria-selected="true">Connections</a>
          </li>
        </ul>
        <div className="tab-content" id="myTabContent">
          <div className="tab-pane fade" id="analysis" role="tabpanel" aria-labelledby="analysis-tab">
            <div className="container editor-section">
              <label className="editor-header">Name</label>
              <form className="form-inline" onSubmit={this.handleAnalysisUpdate}>
                <div className="form-group">
                  <label htmlFor="name" className="sr-only">Name</label>
                  <input type="text" value={this.state.newAnalysisName} className="form-control" id="name" onChange={this.handleAnalysisNameChange}/>
                </div>
                <button type="submit" className="btn btn-primary ml-3">Update</button>
              </form>
            </div>
          </div>
          <div className="tab-pane fade" id="disciplines" role="tabpanel" aria-labelledby="disciplines-tab">
            <DisciplinesEditor name={this.state.newDisciplineName} 
                               nodes={this.state.mda.nodes} 
                               onDisciplineNameChange={this.handleDisciplineNameChange}
                               onDisciplineCreate={this.handleDisciplineCreate} 
                               onDisciplineDelete={this.handleDisciplineDelete}
                               onDisciplineUpdate={this.handleDisciplineUpdate}
             />
          </div>
          <div className="tab-pane fade show active" id="connections" role="tabpanel" aria-labelledby="connections-tab">
            <ConnectionsEditor nodes={this.state.mda.nodes} edges={this.state.mda.edges} 
                               filter={this.state.filter} onFilterChange={this.handleFilterChange}
                               newConnectionName={this.state.newConnectionName}
                               connectionErrors={this.state.errors}
                               onConnectionNameChange={this.handleConnectionNameChange}
                               onConnectionCreate={this.handleConnectionCreate}
                               onConnectionDelete={this.handleConnectionDelete}
            />
          </div>
        </div>
      </div>);

    };
    return (
      <div>
        <div className="mda-section">
          <ToolBar mdaId={this.props.mda.id}/>
        </div>
        <div className="mda-section">      
            <XdsmViewer ref={xdsmViewer => this.xdsmViewer = xdsmViewer} mda={this.state.mda} 
             filter={this.state.filter} onFilterChange={this.handleFilterChange}/>
        </div>
        <div className="mda-section">
          <Connections mda={this.state.mda} filter={this.state.filter} onFilterChange={this.handleFilterChange} />
        </div>
      </div>
    );
  }
} 

export { MdaViewer };
    