import React from 'react';
import PropTypes from 'prop-types';
import Form from 'react-jsonschema-form-bs4';
import update from 'immutability-helper';

const NORMAL = 'Normal';
const BETA = 'Beta';
const GAMMA = 'Gamma';
const UNIFORM = 'Uniform';

const SCHEMA = {
  type: 'object',
  properties: {
    kind: {
      type: 'string',
      title: 'Distribution Kind',
      enum: [NORMAL, BETA, GAMMA, UNIFORM],
      enumNames: [NORMAL, BETA, GAMMA, UNIFORM],
      default: NORMAL,
    },
  },
  required: ['kind'],
  dependencies: {
    kind: {
      oneOf: [
        {
          properties: {
            kind: { enum: [NORMAL] },
            normal_options: {
              title: `${NORMAL} options`,
              type: 'object',
              properties: {
                mu: { title: 'mu - mean', type: 'number', default: 0.0 },
                sigma: { title: 'sigma - standard deviation', type: 'number', default: 1.0 },
              },
            },
          },
        },
        {
          properties: {
            kind: { enum: [BETA] },
            beta_options: {
              title: `${BETA} options`,
              type: 'object',
              properties: {
                alpha: { title: 'alpha - shape', type: 'number', default: 2.0 },
                beta: { title: 'beta - shape', type: 'number', default: 2.0 },
                a: { title: 'a - lower bound', type: 'number', default: -1.0 },
                b: { title: 'b - upper bound', type: 'number', default: 1.0 },
              },
            },
          },
        },
        {
          properties: {
            kind: { enum: [GAMMA] },
            gamma_options: {
              title: `${GAMMA} options`,
              type: 'object',
              properties: {
                k: { title: 'k - shape', type: 'number', default: 2.0 },
                lambda: { title: 'lambda - rate', type: 'number', default: 2.0 },
                gamma: { title: 'gamma - location', type: 'number', default: -1.0 },
              },
            },
          },
        },
        {
          properties: {
            kind: { enum: [UNIFORM] },
            uniform_options: {
              title: `${UNIFORM} options`,
              type: 'object',
              properties: {
                a: { title: 'a - lower bound', type: 'number', default: -1.0 },
                b: { title: 'b - upper bound', type: 'number', default: 1.0 },
              },
            },
          },
        },
      ],
    },
  },
};


class DistributionModal extends React.Component {
  static _uqLabelOf(uq) {
    const { kind, options_attributes } = uq;
    const options = options_attributes.map((opt) => opt.value);
    return `${kind[0]}(${options.join(', ')})`;
  }

  static _uqToState(uq) {
    console.log('UQTOSTATE ', uq);
    const state = { dists: [] };
    for (let k = 0; k < uq.length; k += 1) {
      const { id, kind, options_attributes } = uq[k];
      state.dists.push({ id, kind, options_attributes: [] });
      for (let i = 0; i < options_attributes.length; i += 1) {
        const opt = options_attributes[i];
        state.dists[k].options_attributes.push({ ...opt });
      }
    }
    return state;
  }

  constructor(props) {
    super(props);
    const { conn: { uq } } = this.props;
    console.log('CONSTRUCT ', uq);
    this.state = { selected: -1, dists: DistributionModal._uqToState(uq).dists };
    this.visible = false;

    this.getFormData = this.getFormData.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleSave = this.handleSave.bind(this);
  }

  componentDidMount() {
    const { conn: { name } } = this.props;
    $(`#distributionModalList-${name}`).on('show.bs.modal',
      () => {
        const { conn: { uq } } = this.props;
        console.log(`GET from props ${JSON.stringify(this.props)}`);
        const dists = DistributionModal._uqToState(uq);
        this.setState(dists);
        this.visible = true;
        for (let i = 0; i < dists.dists.length; i += 1) {
          $(`#${name}-${i}`).on('click', (e) => {
            this.setState({ selected: i });
          });
        }
      });
    $(`#distributionModalList-${name}`).on('hidden.bs.modal',
      () => {
        this.visible = false;
      });
    $(`#distributionModal-${name}`).on('show.bs.modal',
      (e) => {
        const coord = this.state.selected;
        $(`#distributionModal-${name} .modal-title`).text(`Distribution of ${name}[${coord}]`);
      });
    $(`#distributionModal-${name}`).on('hidden.bs.modal',
      () => {
        const { conn: { uq } } = this.props;
        const dists = DistributionModal._uqToState(uq);
        this.setState(dists);
      });
    console.log(`DIDMOUNT ${JSON.stringify(this.state)}`);
  }

  shouldComponentUpdate() {
    return this.visible;
  }

  getFormData() {
    // console.log(this.state);
    const { selected } = this.state;
    const taken = selected < 0 ? 0 : selected;
    const { dists: { [taken]: { kind, options_attributes } } } = this.state;
    const formData = { kind };
    if (options_attributes) {
      formData[`${kind.toLowerCase()}_options`] = {};
    }
    for (let i = 0; i < options_attributes.length; i += 1) {
      const opt = options_attributes[i];
      formData[`${kind.toLowerCase()}_options`][opt.name] = opt.value;
    }
    // console.log(`get FORMDATA= ${JSON.stringify(formData)}`);
    return formData;
  }

  handleChange(data) {
    const { selected } = this.state;

    if (selected < 0) {
      return;
    }
    const { formData } = data;
    console.log(`Change FORMDATA= ${JSON.stringify(formData)}`);
    const { kind } = formData;

    const { conn: { name } } = this.props;
    console.log(`${name}[${selected}]`);

    const newState = update(this.state, {
      dists: {
        [selected]: {
          kind: { $set: kind },
          options_attributes: { $set: [] },
        },
      },
    });
    console.log(`AGAIN FORMDATA= ${JSON.stringify(formData)}`);
    for (const k in formData) {
      if (k.startsWith(kind.toLowerCase())) {
        for (const name in formData[k]) {
          if (formData[k][name] !== undefined) { // Form bug: filter undefined data
            console.log('PUSH ', { name, value: formData[k][name] });
            newState.dists[selected].options_attributes.push({ name, value: formData[k][name] });
          } else {
            console.log(`Bug in jsonschema form: avoid pushing ${formData[k][name]}`);
          }
        }
      }
    }

    // distribution: check for updating/removing options
    const { conn } = this.props;
    const { uq: { [selected]: { options_attributes: prevOptAttrs } } } = conn;
    // console.log(`OLDCONNATTRS = ${JSON.stringify(prevOptAttrs)}`);
    const optIds = prevOptAttrs.map((opt) => opt.id);
    console.log(optIds);
    console.log(`NEW CONNATTRS = ${JSON.stringify(newState.dists[selected].options_attributes)}`);
    for (const optAttr of newState.dists[selected].options_attributes) {
      if (optIds.length) {
        optAttr.id = optIds.shift();
        console.log('NEW OPT ATT', optAttr);
      }
    }
    // console.log(`BEFORE CONATTRS = ${JSON.stringify(cAttrs)}`);
    // console.log("OPTIDS", optIds);
    // if (connAttrs.options_attributes) {  // needed in case, normally should be at least []
    optIds.forEach((id) => newState.dists[selected].options_attributes.push({ id, _destroy: '1' }));
    // }


    console.log(`SETSTATE ${JSON.stringify(newState)}`);
    this.setState(newState);
  }

  handleSave() {
    const { selected, dists } = this.state;
    if (selected < 0) {
      return;
    }
    const { conn: { id, name }, onConnectionChange } = this.props;
    console.log(`SAVE state= ${JSON.stringify(dists[selected])}`);
    onConnectionChange(id, { distributions_attributes: [dists[selected]] });
    $(`#distributionModal-${name}`).modal('hide');
  }

  render() {
    const { conn: { name, uq } } = this.props;
    const formData = this.getFormData();

    const distributionModalItems = uq.map(
      (dist, i) => (
        <li key={`${name}-${i}`}>
          {`${name}[${i}]`}
          {' '}
          {DistributionModal._uqLabelOf(uq[i])}
          <button
            type="button"
            id={`${name}-${i}`}
            data-varname={name}
            data-coord={i}
            data-toggle="modal"
            data-target={`#distributionModal-${name}`}
            className="btn btn-primary"
          >
            Edit
          </button>
        </li>
      ),
    );
    return (
      <div key={name}>
        <div className="modal" id={`distributionModalList-${name}`}>
          <div className="modal-dialog modal-lg">
            <div className="modal-content">
              <div className="modal-header">
                <h4 className="modal-title">
                  Distributions of
                  {' '}
                  {name}
                </h4>
                <button type="button" className="close" data-dismiss="modal" aria-hidden="true">×</button>
              </div>
              <div className="container" />
              <div className="modal-body">
                <ul>
                  {distributionModalItems}
                </ul>
              </div>
              <div className="modal-footer">
                <a href="#" data-dismiss="modal" className="btn">Close</a>
              </div>
            </div>
          </div>
        </div>
        <div className="modal fade" id={`distributionModal-${name}`} tabIndex="-1" role="dialog" aria-labelledby={`distributionModalLabel-${name}`} aria-hidden="true">
          <div className="modal-dialog" role="document">
            <div className="modal-content">
              <div className="modal-header">
                <h4 className="modal-title" id={`distributionModalLabel-${name}`}>
                  Distribution of variable
                  {' '}
                  {name}
                </h4>
                <button type="button" className="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">&times;</span>
                </button>
              </div>
              <div className="modal-body">
                <Form
                  schema={SCHEMA}
                  formData={formData}
                  onChange={this.handleChange}
                >
                  <button type="button" className="d-none" />
                </Form>
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="button" className="btn btn-primary" onClick={this.handleSave}>Save</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

DistributionModal.propTypes = {
  conn: PropTypes.shape({
    name: PropTypes.string.isRequired,
    uq: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
      kind: PropTypes.string.isRequired,
      options_attributes: PropTypes.array.isRequired,
    })),
  }).isRequired,
  onConnectionChange: PropTypes.func.isRequired,
};

class DistributionModals extends React.PureComponent {
  render() {
    const { db, onConnectionChange } = this.props;
    const connections = db.computeConnections().filter((c) => c.role === 'design_var' || c.role === 'parameter' || c.role === 'uncertain_var');
    const modals = connections.map(
      (conn) => {
        const { uq: dists } = conn;
        if (dists.length > 0) {
          return (<DistributionModal key={conn.id} conn={conn} onConnectionChange={onConnectionChange} />);
        }
        return null;
      },
    );
    return modals;
  }
}

DistributionModals.propTypes = {
  db: PropTypes.object.isRequired,
  onConnectionChange: PropTypes.func.isRequired,
};

export default DistributionModals;
