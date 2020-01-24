import React from 'react';
import PropTypes from 'prop-types';
import Form from 'react-jsonschema-form-bs4';

import Error from '../../utils/components/Error';
import LoadingIndicator from '../../utils/components/LoadingIndicator';

const SMT_KRIGING = 'SMT_KRIGING';
const SMT_KPLS = 'SMT_KPLS';
const SMT_KPLSK = 'SMT_KPLSK';
const SMT_LS = 'SMT_LS';
const SMT_QP = 'SMT_QP';
const OPENTURNS_PCE = 'OPENTURNS_PCE';

const MODE_OPTIMISATION = 'MODE_OPTIMISATION'
const MODE_UQ = 'MODE_UQ'

const MODES = {
  SMT_KRIGING: MODE_OPTIMISATION,
  SMT_KPLS: MODE_OPTIMISATION,
  SMT_KPLSK: MODE_OPTIMISATION,
  SMT_LS: MODE_OPTIMISATION,
  SMT_QP: MODE_OPTIMISATION,
  OPENTURNS_PCE: MODE_UQ,
};

const SCHEMA = {
  type: 'object',
  properties: {
    kind: {
      type: 'string',
      title: 'Distribution Kind',
      enum: [SMT_KRIGING, SMT_KPLS, SMT_KPLSK, SMT_LS, SMT_QP, OPENTURNS_PCE],
      enumNames: ['Kriging', 'KPLS (Kriging+PLS)', 'KPLSK (Kriging+PLS+KPLS initial guess)',
        'Least-Squares Approximation', 'Quadratic Polynomial Approximation',
        'Polynomial Chaos Expension'],
      default: SMT_KRIGING,
    },
  },
  required: ['kind'],
  dependencies: {
    kind: {
      oneOf: [
        {
          properties: {
            kind: { enum: [SMT_KRIGING, SMT_KPLS, SMT_KPLSK, SMT_LS, SMT_QP] },
          },
        },
        {
          properties: {
            kind: { enum: [OPENTURNS_PCE] },
            openturns_pce_options: {
              title: 'Options',
              type: 'object',
              properties: {
                pce_degree: {
                  title: 'p - Degree of polynoms',
                  type: 'integer',
                  default: 3,
                },
              },
            },
          },
        },
      ],
    },
  },
};

const UISCHEMA = {
};

class MetaModelManager extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      formData: {
        kind: SMT_KRIGING,
      },
      errors: [],
    };

    this.btnSubmit = React.createRef();

    this.handleErrorClose = this.handleErrorClose.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleErrorClose(index) {
    const newState = update(this.state, { errors: { $splice: [[index, 1]] } });
    this.setState(newState);
  }

  handleChange(data) {
    // console.log(`CHANGE ${JSON.stringify(data.formData)}`);
    const { formData } = data;
    const { kind } = this.state;
    let varMode = MODES[kind];
    this.setState({ formData });
    if (MODES[formData.kind] !== varMode) {
      const { onUqModeActive } = this.props;
      onUqModeActive(MODES[formData.kind] === MODE_UQ);
    }
  }

  handleSubmit(data) {
    console.log(`SUBMIT ${JSON.stringify(data.formData)}`);
    this.btnSubmit.setAttribute("disabled", "disabled");

    const { api, opeId } = this.props;
    const { formData } = data;
    const { kind, variables } = formData;
    const mmAttrs = { kind, variables, options: [] };
    for (const k in formData) {
      if (Object.prototype.hasOwnProperty.call(formData, k)
        && (k !== 'kind' || k !== 'variables')
        && k.startsWith(`${kind.toLowerCase()}_`)) {
        for (const opt in formData[k]) {
          if (Object.prototype.hasOwnProperty.call(formData[k], opt)) {
            mmAttrs.options.push({ name: opt, value: formData[k][opt] });
          }
        }
      }
    }
    console.log(`CREATE with ${JSON.stringify(mmAttrs)}`);
    api.createMetaModel(opeId, mmAttrs,
      (response) => {
        console.log(`Metamodel created ${JSON.stringify(response.data)}`);
        const { data: { id } } = response;
        window.location.replace(api.url(`/meta_models/${id}`));
      },
      (error) => {
        console.log(error);
        const message = error.response.data.message || 'Error: Creation failed';
        const newState = update(this.state, { errors: { $set: [message] } });
        this.setState(newState);
        this.btnSubmit.removeAttribute("disabled");
      }
    );
  }

  render() {
    const { selCases } = this.props;
    const outputs = [...new Set(selCases.o.map((c) => c.varname))].map((name) => (
      <span key={name} className="ml-5">
        {name}
      </span>
    ));
    const inputs = [...new Set(selCases.i.map((c) => c.varname))].map((name) => (
      <span key={name} className="ml-5">
        {name}
      </span>
    ));

    const { formData } = this.state;
    formData.variables = {
      inputs: [...new Set(selCases.i.map((c) => c.varname))],
      outputs: [...new Set(selCases.o.map((c) => c.varname))],
    };

    const { errors } = this.state;
    const errs = errors.map(
      // eslint-disable-next-line react/no-array-index-key
      (message, i) => (<Error key={i} msg={message} onClose={() => this.handleErrorClose(i)} />),
    );
    console.log(formData);

    return (
      <div className="editor-section col-4">
        <legend>MetaModel</legend>
        {errs}
        <div className="editor-section">
          <div>Inputs</div>
          <div>{inputs}</div>
        </div>
        <div className="editor-section">
          <div>Outputs</div>
          <div>{outputs}</div>
        </div>
        <div className="editor-section">
          <Form
            schema={SCHEMA}
            uiSchema={UISCHEMA}
            formData={formData}
            onChange={this.handleChange}
            onSubmit={this.handleSubmit}
          >
            <div>
              <button className="btn btn-primary" type="submit" ref={btn => { this.btnSubmit = btn; }} >Submit</button>
            </div>
          </Form>
          <LoadingIndicator />
        </div>

      </div>
    );
  }
}

MetaModelManager.propTypes = {
  api: PropTypes.object.isRequired,
  opeId: PropTypes.number.isRequired,
  selCases: PropTypes.shape({
    i: PropTypes.array.isRequired,
    o: PropTypes.array.isRequired,
    c: PropTypes.array.isRequired,
  }).isRequired,
  onUqModeActive: PropTypes.func.isRequired,
};

export default MetaModelManager;
