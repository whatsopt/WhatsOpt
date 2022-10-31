import React from 'react';
import PropTypes from 'prop-types';
import Form from '@rjsf/bootstrap-4';
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
  static _uqLabelOf(dist) {
    const { kind, options_attributes } = dist;
    const options = options_attributes.map((opt) => opt.value);
    return `${kind}(${options.join(', ')})`;
  }

  static _uqLabelListOf(uq) {
    return uq.map((dist) => DistributionModal._uqLabelOf(dist)).join(', ');
  }

  static _uqToState(uq) {
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
    this.state = { selected: -1, dists: DistributionModal._uqToState(uq).dists };
    this.visible = false;

    this.getFormData = this.getFormData.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleSave = this.handleSave.bind(this);
  }

  componentDidMount() {
    const { conn: { name } } = this.props;
    // eslint-disable-next-line no-undef
    $(`#distributionListModal-${name}`).on(
      'show.bs.modal',
      () => {
        const { conn: { uq } } = this.props;
        const dists = DistributionModal._uqToState(uq);
        this.setState(dists);
        this.visible = true;
        for (let i = 0; i < dists.dists.length; i += 1) {
          // eslint-disable-next-line no-undef
          $(`#${name}-${i}`).on('click', (/* e */) => {
            this.setState({ selected: i });
          });
        }
      },
    );
    // eslint-disable-next-line no-undef
    $(`#distributionListModal-${name}`).on(
      'hidden.bs.modal',
      () => {
        this.visible = false;
      },
    );
    // eslint-disable-next-line no-undef
    $(`#distributionModal-${name}`).on(
      'show.bs.modal',
      () => {
        const { conn: { uq } } = this.props;
        if (uq.length === 1) {
          const { dists } = DistributionModal._uqToState(uq);
          this.setState({ selected: 0, dists });
          this.visible = true;
          for (let i = 0; i < dists.length; i += 1) {
            // eslint-disable-next-line no-undef
            $(`#${name}-${i}`).on('click', () => {
              this.setState({ selected: i });
            });
          }
        }
        const { selected } = this.state;
        const varname = uq.length === 1 ? name : `${name}[${selected}]`;
        // eslint-disable-next-line no-undef
        $(`#distributionModal-${name} .modal-title`).text(`Distribution of ${varname}`);
      },
    );
    // eslint-disable-next-line no-undef
    $(`#distributionModal-${name}`).on(
      'hidden.bs.modal',
      () => {
        const { conn: { uq } } = this.props;
        const dists = DistributionModal._uqToState(uq);
        this.setState(dists);
      },
    );
  }

  shouldComponentUpdate() {
    return this.visible;
  }

  getFormData() {
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
    return formData;
  }

  handleChange(data) {
    const { selected } = this.state;

    if (selected < 0) {
      return;
    }
    const { formData } = data;
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
    for (const k in formData) {
      if (k.startsWith(kind.toLowerCase())) {
        for (const optname in formData[k]) {
          if (formData[k][optname] !== undefined) { // Form bug: filter undefined data
            // console.log('PUSH ', { name: optname, value: formData[k][optname] });
            newState.dists[selected].options_attributes.push(
              { name: optname, value: formData[k][optname] },
            );
          } else {
            console.log(`Bug in jsonschema form: avoid pushing ${k} ${optname} ${formData[k][optname]}`);
          }
        }
      }
    }

    // distribution: check for updating/removing options
    const { conn } = this.props;
    const { uq: { [selected]: { options_attributes: prevOptAttrs } } } = conn;
    const optIds = prevOptAttrs.map((opt) => opt.id);
    for (const optAttr of newState.dists[selected].options_attributes) {
      if (optIds.length) {
        optAttr.id = optIds.shift();
      }
    }
    optIds.forEach((id) => newState.dists[selected].options_attributes.push({ id, _destroy: '1' }));
    this.setState(newState);
  }

  handleSave() {
    const { selected, dists } = this.state;
    if (selected < 0) {
      return;
    }
    const { conn: { id, name }, onConnectionChange } = this.props;
    onConnectionChange(id, { distributions_attributes: [dists[selected]] });
    // eslint-disable-next-line no-undef
    $(`#distributionModal-${name}`).modal('hide');
  }

  /* eslint-disable jsx-a11y/control-has-associated-label */
  /* eslint-disable react/no-array-index-key */
  render() {
    const { conn: { name, uq } } = this.props;
    const formData = this.getFormData();

    const distributionModalItems = uq.map(
      (dist, i) => (
        <div className="row" key={`${name}-${i}`}>
          <div className="col-md-3">{`${name}[${i}]`}</div>
          <div className="col-md-5">{DistributionModal._uqLabelOf(uq[i])}</div>
          <div className="col-md-4">
            <button
              title="Edit"
              type="button"
              id={`${name}-${i}`}
              data-varname={name}
              data-coord={i}
              data-bs-toggle="modal"
              data-bs-target={`#distributionModal-${name}`}
              className="btn btn-sm"
            >
              <i className="fas fa-edit" />
            </button>
          </div>
        </div>
      ),
    );
    return (
      <div key={name}>
        <div className="modal distribution-list-modal" id={`distributionListModal-${name}`}>
          <div className="modal-dialog">
            <div className="modal-content">
              <div className="modal-header">
                <h4 className="modal-title">
                  Distributions of
                  {' '}
                  {name}
                </h4>
                <button type="button" className="btn-close" data-bs-dismiss="modal" aria-hidden="true">×</button>
              </div>
              <div className="container" />
              <div className="modal-body">
                <div className="container-fluid">
                  {distributionModalItems}
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-primary" data-bs-dismiss="modal">Close</button>
              </div>
            </div>
          </div>
        </div>
        <div className="modal fade distribution-modal" id={`distributionModal-${name}`} tabIndex="-1" role="dialog" aria-labelledby={`distributionModalLabel-${name}`} aria-hidden="true">
          <div className="modal-dialog" role="document">
            <div className="modal-content">
              <div className="modal-header">
                <h4 className="modal-title" id={`distributionModalLabel-${name}`}>
                  Distribution of variable
                  {' '}
                  {name}
                </h4>
                <button type="button" className="btn-close" data-bs-dismiss="modal" aria-label="Close" />
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
                <button type="button" className="btn btn-secondary" data-bs-dismiss="modal">Close</button>
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
    id: PropTypes.number.isRequired,
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
    const connections = db.computeConnections().filter(
      (c) => c.role === 'design_var' || c.role === 'parameter' || c.role === 'uncertain_var',
    );
    const modals = connections.map(
      (conn) => {
        const { uq: dists } = conn;
        if (dists.length > 0) {
          return (
            <DistributionModal
              key={conn.id}
              conn={conn}
              onConnectionChange={onConnectionChange}
            />
          );
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
