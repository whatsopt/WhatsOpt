import React from 'react';
import PropTypes from 'prop-types';
import Form from 'react-jsonschema-form-bs4';

const DETERMINIST = 'none';
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
      enum: [DETERMINIST, NORMAL, BETA, GAMMA, UNIFORM],
      enumNames: ['Determinist', NORMAL, BETA, GAMMA, UNIFORM],
      default: DETERMINIST,
    },
  },
  required: ['kind'],
  dependencies: {
    kind: {
      oneOf: [
        {
          properties: {
            kind: { enum: [DETERMINIST] },
          },
        },
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

function _uqToState(uq) {
  let state = { kind: DETERMINIST, options_attributes: [] };
  const { kind, options_attributes } = uq;
  state = { kind, options_attributes: [] };
  for (let i = 0; i < options_attributes.length; i += 1) {
    const opt = options_attributes[i];
    state.options_attributes.push({ ...opt });
  }
  return state;
}

function _notEqualOptions(opt1, opt2) {
  if (opt1.length != opt2.length) {
    return true;
  }
  for (let i = 0; i < opt1.length; i += 1) {
    let found = false;
    for (let j = 0; j < opt2.length; j += 1) {
      found = found || (opt1[i].name == opt2[j].name && opt1[i].value == opt2[j].value)
    }
    if (!found) {
      return true;
    }
  }
  return false;
}

class DistributionModal extends React.PureComponent {
  constructor(props) {
    super(props);
    const { conn: { uq } } = this.props;
    this.state = _uqToState(uq);

    this.getFormData = this.getFormData.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleSave = this.handleSave.bind(this);
  }

  getFormData() {
    // console.log(this.state);
    const { kind, options_attributes } = this.state;
    let formData = { kind };
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
    // console.log(`Change FORMDATA= ${JSON.stringify(formData)}`);
    const { kind } = formData
    const newState = { kind, options_attributes: [] };
    for (let k in formData) {
      if (k.startsWith(kind.toLowerCase())) {
        for (let name in formData[k]) {
          newState.options_attributes.push({ name, value: formData[k][name] });
        }
      }
    }
    // console.log(`SETSTATE ${JSON.stringify(newState)}`)
    this.setState(newState);
  }

  handleSave() {
    const { conn: { id, name }, onConnectionChange } = this.props;
    // console.log(`SAVE state= ${JSON.stringify(this.state)}`);
    onConnectionChange(id, { distribution_attributes: this.state });
    $(`#distributionModal-${name}`).modal('hide');
  }

  componentDidMount() {
    const { conn: { name } } = this.props;
    $(`#distributionModal-${name}`).on('shown.bs.modal',
      () => {
        const { conn: { uq } } = this.props;
        // console.log("GET from props " + JSON.stringify(this.props));
        this.setState(_uqToState(uq));
      }
    );
  }

  render() {
    const { conn: { name } } = this.props;
    const formData = this.getFormData();

    // console.log(`render FORMDATA= ${JSON.stringify(formData)}`);

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
  conn: PropTypes.object.isRequired,
  onConnectionChange: PropTypes.func.isRequired,
};

class DistributionModals extends React.PureComponent {
  render() {
    const { db, onConnectionChange } = this.props;
    const connections = db.computeConnections().filter((c) => c.role === 'design_var' || c.role === 'parameter');
    const modals = connections.map(
      (conn) => (<DistributionModal key={conn.id} conn={conn} onConnectionChange={onConnectionChange} />),
    );
    return modals;
  }
}

DistributionModals.propTypes = {
  db: PropTypes.object.isRequired,
  onConnectionChange: PropTypes.func.isRequired,
};

export default DistributionModals;
