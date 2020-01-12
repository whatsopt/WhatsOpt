import React from 'react';
import Form from 'react-jsonschema-form-bs4';

import PropTypes from 'prop-types';

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
            options: {
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
            options: {
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
            options: {
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
            options: {
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

class DistributionModal extends React.PureComponent {
  constructor(props) {
    super(props);
    const { conn } = this.props;
    this.conn = conn;
    this.resetFormData = this.resetFormData.bind(this);
    const formData = this.resetFormData();
    this.state = {
      formData,
    };
    this.ref = React.createRef();
    this.handleChange = this.handleChange.bind(this);
    this.handleSave = this.handleSave.bind(this);
  }

  componentDidMount() {
    const { conn: { name } } = this.props;
    $(`#distributionModal-${name}`).on('hidden.bs.modal', () => {
      console.log(`Before reset FORMDATA= ${JSON.stringify(this.state.formData)}`);
      const formData = this.resetFormData();
      console.log(`resetting FORMDATA= ${JSON.stringify(formData)}`);
      this.setState({ formData });
      console.log(`After FORMDATA= ${JSON.stringify(formData)}`);
    });
  }

  resetFormData() {
    let formData = { kind: DETERMINIST };
    const { uq } = this.conn;
    if (uq) {
      const { kind, options_attributes } = uq;
      formData = { kind };
      if (options_attributes) {
        for (let i = 0; i < options_attributes.length; i += 1) {
          const opt = options_attributes[i];
          formData.options[opt.name] = opt.value;
        }
      }
    }
    return formData;
  }

  handleChange(data) {
    const { formData } = data;
    console.log(`Change FORMDATA= ${JSON.stringify(formData)}`);
    this.setState({ ...formData });
  }

  handleSave() {
    const { onConnectionChange } = this.props;
    const { formData } = this.state;
    console.log(`Save FORMDATA= ${JSON.stringify(formData)}`);

    const distribution = { kind: formData.kind, options_attributes: [] };
    if (formData.options) {
      for (const k in formData.options) {
        if (Object.prototype.hasOwnProperty.call(formData.options, k)) {
          distribution.options_attributes.push({ name: k, value: formData.options[k] });
        }
      }
    } else {
      distribution._destroy = true;
    }
    onConnectionChange(this.conn.id, { distribution_attributes: distribution });
  }

  render() {
    const { conn: { name } } = this.props;
    const { formData } = this.state;

    console.log(`render FORMDATA= ${JSON.stringify(formData)}`);

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
