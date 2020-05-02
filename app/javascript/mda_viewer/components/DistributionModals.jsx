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
  static _uqToState(uq) {
    console.log('UQTOSTATE ', uq);
    const state = { dists: [] };
    for (let k = 0; k < uq.length; k += 1) {
      const { id, kind, options_attributes } = uq[k];
      state.dists.push({ id, kind, options_attributes: [] });
      for (let i = 0; i < options_attributes.length; i += 1) {
        const opt = options_attributes[i];
        state.dists[0].options_attributes.push({ ...opt });
      }
    }
    return state;
  }

  constructor(props) {
    super(props);
    const { conn: { uq } } = this.props;
    console.log('CONSTRUCT ', uq);
    this.state = DistributionModal._uqToState(uq);
    this.visible = false;

    this.getFormData = this.getFormData.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleSave = this.handleSave.bind(this);
  }

  componentDidMount() {
    const { conn: { name } } = this.props;
    $(`#distributionModal-${name}`).on('show.bs.modal',
      () => {
        const { conn: { uq } } = this.props;
        console.log(`GET from props ${JSON.stringify(this.props)}`);
        const dists = DistributionModal._uqToState(uq);
        this.setState(dists);
        this.visible = true;
      });
    $(`#distributionModal-${name}`).on('hidden.bs.modal',
      () => {
        const { conn: { uq } } = this.props;
        this.visible = false;
      });
  }

  shouldComponentUpdate() {
    return this.visible;
  }

  getFormData() {
    // console.log(this.state);
    const { dists: { 0: { kind, options_attributes } } } = this.state;
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
    const { formData } = data;
    console.log(`Change FORMDATA= ${JSON.stringify(formData)}`);
    const { kind } = formData;
    const newState = update(this.state, {
      dists: {
        0: {
          kind: { $set: kind },
          options_attributes: { $set: [] },
        },
      },
    });
    console.log(`AGAIN FORMDATA= ${JSON.parse(JSON.stringify(formData))}`);
    for (const k in formData) {
      if (k.startsWith(kind.toLowerCase())) {
        console.log(formData[k]);
        for (const name in formData[k]) {
          if (formData[k][name] !== undefined) { // Form bug: filter undefined data
            console.log('PUSH ', { name, value: formData[k][name] });
            newState.dists[0].options_attributes.push({ name, value: formData[k][name] });
          } else {
            console.log(`Bug in jsonschema form: avoid pushing ${formData[k][name]}`);
          }
        }
      }
    }

    // distribution: check for updating/removing options
    const { conn } = this.props;
    const { uq: [{ options_attributes: prevOptAttrs }] } = conn;
    // console.log(`OLDCONNATTRS = ${JSON.stringify(prevOptAttrs)}`);
    const optIds = prevOptAttrs.map((opt) => opt.id);
    console.log(optIds);
    console.log(`NEW CONNATTRS = ${JSON.stringify(newState.dists[0].options_attributes)}`);
    for (const optAttr of newState.dists[0].options_attributes) {
      if (optIds.length) {
        optAttr.id = optIds.shift();
        console.log('NEW OPT ATT', optAttr);
      }
    }
    // console.log(`BEFORE CONATTRS = ${JSON.stringify(cAttrs)}`);
    // console.log("OPTIDS", optIds);
    // if (connAttrs.options_attributes) {  // needed in case, normally should be at least []
    optIds.forEach((id) => newState.dists[0].options_attributes.push({ id, _destroy: '1' }));
    // }


    // console.log(`SETSTATE ${JSON.stringify(newState)}`)
    this.setState(newState);
  }

  handleSave() {
    const { conn: { id, name }, onConnectionChange } = this.props;
    console.log(`SAVE state= ${JSON.stringify(this.state)}`);
    const { dists } = this.state;
    onConnectionChange(id, { distributions_attributes: dists });
    $(`#distributionModal-${name}`).modal('hide');
  }


  render() {
    const { conn: { name } } = this.props;
    const formData = this.getFormData();

    return (
      <div className="modal fade" id={`distributionModal-${name}`} tabIndex="-1" role="dialog" aria-labelledby={`distributionModalLabel-${name}`} aria-hidden="true">
        <div className="modal-dialog" role="document">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title" id={`distributionModalLabel-${name}`}>
                Distribution of variable
                {' '}
                {name}
              </h5>
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
    );
  }
}

DistributionModal.propTypes = {
  conn: PropTypes.shape({
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
