import React from 'react';
import PropTypes from 'prop-types';
import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd';
import AnalysisSelector from './AnalysisSelector';
import ImportSection from './ImportSection';
import DataConfirmModal from '../../utils/components/DataConfirmModal';

// mapping with XDSMjs type values
const DISCIPLINE = 'analysis';
const ANALYSIS = 'mda';
const METAMODEL = 'metamodel';
const XDSMJS_DISCIPLINE = 'function';
const XDSMJS_ANALYSIS = 'group';

function isLocalHost(host) {
  return (host === '' || host === 'localhost' || host === '127.0.0.1');
}
class Discipline extends React.Component {
  constructor(props) {
    super(props);
    const { node: { link } } = props;
    let selected = [];
    if (link) {
      selected = [{ id: link.id, label: `#${link.id} ${link.name}` }];
    }

    this.state = {
      discName: '',
      discType: DISCIPLINE,
      discHost: '',
      discPort: 31400,
      isEditing: false,
      selected,
    };

    this.handleDiscNameChange = this.handleDiscNameChange.bind(this);
    this.handleDiscHostChange = this.handleDiscHostChange.bind(this);
    this.handleDiscPortChange = this.handleDiscPortChange.bind(this);
    this.handleEdit = this.handleEdit.bind(this);
    this.handleCancelEdit = this.handleCancelEdit.bind(this);
    this.handleUpdate = this.handleUpdate.bind(this);
    this.handleSelectChange = this.handleSelectChange.bind(this);
    this.handleSubAnalysisSelected = this.handleSubAnalysisSelected.bind(this);
  }

  componentDidMount() {
    // const { conn: { name } } = this.props;
    // // eslint-disable-next-line no-undef
    // $(`#confirmModal-${name}`).on(
    //   'show.bs.modal',
    //   () => {
    //     this.visible = true;
    //   },
    // );
    // // eslint-disable-next-line no-undef
    // $(`#confirmModal-${name}`).on(
    //   'hidden.bs.modal',
    //   () => {
    //     this.visible = false;
    //   },
    // );
  }

  handleDiscNameChange(event) {
    this.setState({ discName: event.target.value });
  }

  handleDiscHostChange(event) {
    this.setState({ discHost: event.target.value });
  }

  handleDiscPortChange(event) {
    this.setState({ discPort: event.target.value });
  }

  handleEdit() {
    const { node } = this.props;
    let { type } = node;
    if (type === XDSMJS_ANALYSIS) {
      type = ANALYSIS;
    }
    if (type === XDSMJS_DISCIPLINE) {
      type = DISCIPLINE;
    }
    const newState = {
      discName: node.name,
      discType: type,
      discHost: node.endpoint ? node.endpoint.host : '',
      discPort: node.endpoint ? node.endpoint.port : 31400,
      isEditing: true,
    };
    this.setState(newState);
  }

  handleCancelEdit() {
    this.setState({ isEditing: false });
  }

  handleUpdate(event) {
    event.preventDefault();
    this.handleCancelEdit();
    const { node } = this.props;
    const {
      discName, discType, discHost, discPort, selected,
    } = this.state;
    const subAnalysisId = selected[0] && selected[0].id;
    const discAttrs = {
      name: discName,
      type: discType,
    };
    if (discType === DISCIPLINE) {
      discAttrs.endpoint_attributes = { host: discHost, port: discPort };
    }
    if (discType === ANALYSIS) {
      discAttrs.analysis_discipline_attributes = {
        discipline_id: node.id, analysis_id: subAnalysisId,
      };
    }
    const { endpoint } = node; // an endpoint is already present
    if (endpoint && endpoint.id) {
      const endattrs = discAttrs.endpoint_attributes;
      endattrs.id = endpoint.id;
      if (isLocalHost(endattrs.host)) {
        endattrs._destroy = 1;
      }
    }
    // console.log(JSON.stringify(discattrs));
    const { onDisciplineUpdate } = this.props;
    onDisciplineUpdate(node, discAttrs);
  }

  handleSelectChange(event) {
    const discType = event.target.value;
    const { selected } = this.state;
    if (discType !== ANALYSIS && selected) { // unset analysis if needed
      this.setState({ discType, selected: [] });
    } else {
      this.setState({ discType });
    }
  }

  handleSubAnalysisSelected(selected) {
    console.log(`Select ${JSON.stringify(selected)}`);
    // Extract name from analysis label #\d+ name
    const [, discName] = selected[0].label.match(/#\d+\s(.*)/);
    this.setState({ selected, discName });
  }

  render() {
    const {
      isEditing, discType, discHost, discPort, discName, selected,
    } = this.state;
    const {
      node, onSubAnalysisSearch, index, limited, connected,
    } = this.props;
    let { type } = node;
    if (type === XDSMJS_ANALYSIS) {
      type = ANALYSIS;
    }
    if (type === XDSMJS_DISCIPLINE) {
      type = DISCIPLINE;
    }
    const not_editable = (type === METAMODEL);
    const sub_analysable = (type === DISCIPLINE && !connected);
    const type_changeable = sub_analysable || type === ANALYSIS;

    if (isEditing) {
      let deploymentOrSubAnalysis;
      if (discType === ANALYSIS) {
        deploymentOrSubAnalysis = (
          <div className="mb-3 ms-2">
            <AnalysisSelector
              message="Search for sub-analysis..."
              selected={selected}
              onAnalysisSearch={onSubAnalysisSearch}
              onAnalysisSelected={this.handleSubAnalysisSelected}
            />
          </div>
        );
      } else {
        deploymentOrSubAnalysis = (
          <>
            <div className="col-auto">
              <label htmlFor="name" className="mt-2">
                deployed on
              </label>
            </div>
            <div className="col-auto">
              <input
                className="form-control ms-1"
                id="name"
                type="text"
                defaultValue={discHost}
                placeholder="localhost"
                onChange={this.handleDiscHostChange}
              />
            </div>
            <div className="col-auto">
              <label htmlFor="port" className="mt-2">:</label>
            </div>
            <div className="col-auto">
              <input
                className="form-control"
                id="port"
                type="number"
                defaultValue={discPort}
                placeholder="31400"
                onChange={this.handleDiscPortChange}
              />
            </div>

          </>
        );
      }
      return (
        <Draggable draggableId={node.id} index={index}>
          {(provided) => (
            <li
              ref={provided.innerRef}
              // eslint-disable-next-line react/jsx-props-no-spreading
              {...provided.dragHandleProps}
              // eslint-disable-next-line react/jsx-props-no-spreading
              {...provided.draggableProps}
              className="list-group-item editor-discipline"
            >
              <form className="d-flex flex-row align-items-bottom flex-wrap" onSubmit={this.handleUpdate}>
                <div className="row">
                  <div className="col-auto">
                    <input
                      className="form-control"
                      id="name"
                      type="text"
                      defaultValue={discName}
                      placeholder="Enter Name..."
                      onChange={this.handleDiscNameChange}
                    />
                  </div>
                  <div className="col-auto">
                    <select
                      className="form-control ms-2"
                      id="type"
                      value={discType}
                      onChange={this.handleSelectChange}
                      disabled={!type_changeable}
                    >
                      <option value={DISCIPLINE}>Discipline</option>
                      <option value={ANALYSIS}>Sub-Analysis</option>
                    </select>
                  </div>
                  {deploymentOrSubAnalysis}
                  <div className="col-auto">
                    <button type="submit" className="btn btn-primary ms-3">Update</button>
                  </div>
                  <div className="col-auto">
                    <button type="button" onClick={this.handleCancelEdit} className="btn btn-secondary ms-1">Cancel</button>
                  </div>
                </div>
              </form>
            </li>
          )}
        </Draggable>
      );
    }
    let item = node.name;
    const { endpoint } = node;
    if (endpoint && !isLocalHost(endpoint.host)) {
      item += ` on ${endpoint.host}`;
    }

    return (
      <Draggable draggableId={node.id} index={index}>
        {(provided) => (
          <li
            ref={provided.innerRef}
            // eslint-disable-next-line react/jsx-props-no-spreading
            {...provided.dragHandleProps}
            // eslint-disable-next-line react/jsx-props-no-spreading
            {...provided.draggableProps}
            className="list-group-item editor-discipline col-md-4"
          >
            <span className="align-bottom">{item}</span>
            <button
              type="button"
              data-bs-toggle="modal"
              data-bs-target={`#confirmModal-${node.id}`}
              className="d-inline btn btn-light btn-inverse btn-sm float-end text-danger"
              title="Delete"
              disabled={limited}
            >
              <i className="fa fa-times" />
            </button>
            <button
              type="button"
              className="d-inline btn btn-light btn-sm ms-2"
              title="Edit"
              onClick={this.handleEdit}
              disabled={limited || not_editable}
            >
              <i className="fa fa-edit" />
            </button>
          </li>
        )}
      </Draggable>
    );
  }
}

Discipline.propTypes = {
  node: PropTypes.object.isRequired,
  index: PropTypes.number.isRequired,
  subAnalysisOption: PropTypes.number,
  limited: PropTypes.bool.isRequired,
  connected: PropTypes.bool.isRequired,
  onDisciplineUpdate: PropTypes.func.isRequired,
  onDisciplineDelete: PropTypes.func.isRequired,
  onSubAnalysisSearch: PropTypes.func.isRequired,
};
Discipline.defaultProps = { subAnalysisOption: -1 };
class DisciplinesEditor extends React.Component {
  constructor(props) {
    super(props);
    const { db } = this.props;
    this.state = { nodes: db.getDisciplines() };

    this.onDragEnd = this.onDragEnd.bind(this);
  }

  onDragEnd(result) {
    if (!result.destination) {
      return;
    }
    const { db: { nodes }, onDisciplineUpdate } = this.props;
    onDisciplineUpdate(
      nodes[result.source.index + 1],
      { position: result.destination.index + 1 },
    );
  }

  // Take into account in this.state of discipline changes coming
  // from Discipline components that should arrive through new props
  static getDerivedStateFromProps(nextProps) {
    return { nodes: nextProps.db.getDisciplines() };
  }

  render() {
    const { nodes } = this.state;
    const {
      db, api,
      name,
      onDisciplineUpdate, onDisciplineDelete,
      onSubAnalysisSearch,
      onDisciplineCreate, onDisciplineNameChange,
      onDisciplineImport,
    } = this.props;

    const mdaId = db.mda.id;
    const limited = db.isAnalysisUsed;

    let disciplines = nodes.map((node, i) => (
      <Discipline
        key={node.id}
        pos={i + 1}
        index={i}
        node={node}
        limited={limited}
        connected={db.isConnected(node.id)}
        onDisciplineUpdate={onDisciplineUpdate}
        onDisciplineDelete={onDisciplineDelete}
        onSubAnalysisSearch={onSubAnalysisSearch}
      />
    ));
    const disciplinesModals = nodes.map((node) => (
      <DataConfirmModal
        key={node.id}
        id={node.id}
        title="Are you sure?"
        text={`Delete discipline ${node.name}`}
        onCancel={() => { console.log('cancel'); }}
        onConfirm={() => {
          const self = this;
          self.props.onDisciplineDelete(node);
        }}
      />
    ));
    const nbNodes = disciplines.length;
    if (nbNodes === 0) {
      disciplines = 'None';
    }
    return (
      <div className="container-fluid">
        <div className="editor-section">
          <div className="editor-section-label">
            Disciplines
            <span className="badge bg-info ms-2">{nbNodes}</span>
          </div>
          <DragDropContext
            onDragStart={this.onDragStart}
            onDragUpdate={this.onDragUpdate}
            onDragEnd={this.onDragEnd}
          >
            <Droppable droppableId="droppable">
              {(provided) => (
                (
                  // eslint-disable-next-line react/jsx-props-no-spreading
                  <ul ref={provided.innerRef} {...provided.droppableProps} className="list-group">
                    {disciplines}
                    {provided.placeholder}
                  </ul>
                )
              )}
            </Droppable>
          </DragDropContext>
        </div>
        <div className="editor-section">
          <form className="row g-3" onSubmit={onDisciplineCreate}>
            <div className="col-auto">
              <input
                type="text"
                value={name}
                placeholder="Enter Discipline Name..."
                className="form-control"
                id="name"
                onChange={onDisciplineNameChange}
                disabled={limited}
              />
            </div>
            <div className="col-auto">
              <button type="submit" className="btn btn-primary ms-3" disabled={limited}>Add</button>
            </div>
          </form>
        </div>
        <hr />
        <ImportSection api={api} mdaId={mdaId} onDisciplineImport={onDisciplineImport} />
        {disciplinesModals}
      </div>
    );
  }
}

DisciplinesEditor.propTypes = {
  db: PropTypes.object.isRequired,
  api: PropTypes.object.isRequired,
  name: PropTypes.string.isRequired,
  onDisciplineUpdate: PropTypes.func.isRequired,
  onDisciplineDelete: PropTypes.func.isRequired,
  onDisciplineCreate: PropTypes.func.isRequired,
  onDisciplineNameChange: PropTypes.func.isRequired,
  onSubAnalysisSearch: PropTypes.func.isRequired,
  onDisciplineImport: PropTypes.func.isRequired,
};

export default DisciplinesEditor;
