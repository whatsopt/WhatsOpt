import React from 'react';
import PropTypes from 'prop-types';
import Form from 'react-jsonschema-form-bs4';

const SMT_KRIGING = "SMT_KRIGING";
const SMT_KPLS = "SMT_KPLS";
const SMT_KPLSK = "SMT_KPLSK";
const SMT_LS = "SMT_LS";
const SMT_QP = "SMT_QP";
const OPENTURNS_PCE = "OPENTURNS_PCE";

const SCHEMA = {
  type: 'object',
  properties: {
    meta_model: {
      title: 'Metamodel',
      type: 'object',
      properties: {
        kind: {
          type: 'string',
          title: 'Distribution Kind',
          enum: [SMT_KRIGING, SMT_KPLS, SMT_KPLSK, SMT_LS, SMT_QP, OPENTURNS_PCE],
          enumNames: ["Kriging", "KPLS (Kriging+PLS)", "KPLSK (Kriging+PLS+KPLS initial guess)",
            "Least-Squares Approximation", "Quadratic Polynomial Approximation",
            "Polynomial Chaos Expension"],
          default: SMT_KRIGING,
        },
        variables: {
          type: 'object',
          properties: {
            inputs: {
              type: 'array',
              items: {
                type: 'string',
              }
            },
            outputs: {
              type: 'array',
              items: {
                type: 'string',
              }
            },
          },
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
                  title: `PCE options`,
                  type: 'object',
                  properties: {
                    pce_degree: {
                      title: 'p - Degree of polynoms',
                      type: 'integer',
                      default: 3
                    },
                  },
                },
              },
            },
          ],
        },
      },
    },
  },
};

// const InputWidget = (props) => {
//   const { value } = props;
//   return (
//     <input type="text"
//       type="hidden"
//       id={`meta_model_variables_inputs_${value}`}
//       name="meta_model[variables][inputs][]"
//       value={value}
//     />
//   );
// }

// const OutputWidget = (props) => {
//   const { value } = props;
//   return (
//     <input
//       type="hidden"
//       id={`meta_model_variables_inputs_${value}`}
//       name="meta_model[variables][outputs][]"
//       value={value}
//     />
//   );
// }

// const SelectKindWidget = (props) => {
//   const { children, className } = props;
//   return (
//     <select
//       id="meta_model_kind"
//       name="meta_model[kind]"
//       className={className}>
//       {children}
//     </select>
//   );
// }

const UISCHEMA = {
  meta_model: {
    //kind: { "ui:widget": SelectKindWidget, },
    variables: {
      classNames: "d-none",
      inputs: {
        items: {
          "ui:widget": "hidden",
          // "ui:widget": InputWidget,
        },
        "ui:options": {
          orderable: false,
          addable: false,
          removable: false
        }
      },
      outputs: {
        items: {
          "ui:widget": "hidden",
          // "ui:widget": OutputWidget,
        },
        "ui:options": {
          orderable: false,
          addable: false,
          removable: false
        }
      },
    },
  },
};

class MetaModelManager extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      formData: {
        meta_model: {
          kind: SMT_KRIGING,
        }
      }
    }

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange() {
    console.log("change");
  }

  handleSubmit() {
    console.log("submit");
  }

  render() {
    const { api, opeId, selCases } = this.props;
    const metamodelUrl = api.url(`/operations/${opeId}/meta_models`);
    const outputs = [...new Set(selCases.o.map((c) => c.varname))].map((name) => (
      <span className="ml-5">
        {name}
        <input
          type="hidden"
          id={`meta_model_variables_outputs_${name}`}
          name="meta_model[variables][outputs][]"
          value={name}
        />
      </span>
    ));
    const inputs = [...new Set(selCases.i.map((c) => c.varname))].map((name) => (
      <span className="ml-5">
        {name}
        <input
          type="hidden"
          id={`meta_model_variables_inputs_${name}`}
          name="meta_model[variables][inputs][]"
          value={name}
        />
      </span>
    ));

    const { formData } = this.state;
    formData.meta_model.variables = {
      inputs: [...new Set(selCases.i.map((c) => c.varname))],
      outputs: [...new Set(selCases.o.map((c) => c.varname))],
    };

    console.log(formData);

    return (
      <div className="editor-section">
        <div>
          <legend>Inputs</legend>
          <div>{inputs}</div>
        </div>
        <div>
          <legend>Outputs</legend>
          <div>{outputs}</div>
        </div>
        <div>
          <Form
            acceptCharset="UTF-8"
            action={metamodelUrl}
            method="post"
            schema={SCHEMA}
            uiSchema={UISCHEMA}
            formData={formData}
            onChange={({ formData }) => this.setState({ formData })}
            onSubmit={this.handleSubmit}>
          </Form>
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
};

export default MetaModelManager;
