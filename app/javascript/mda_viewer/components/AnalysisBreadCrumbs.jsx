import React from 'react';
import PropTypes from 'prop-types';

class AnalysisBreadCrumbs extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    let crumbs = this.props.path.map((anc, i) => {
      let href = this.props.api.url(`/analyses/${anc.id}`);
      let klass = "breadcrumb-item";
      let name = <a href={href}>{anc.name}</a>;
      if (this.props.path.length-1===i) {
        klass += " active";
        name = anc.name;
      }
      return ( <li key={anc.id} className={klass}>{name}</li>);
    });

    return (
      <nav aria-label="breadcrumb">
        <ol className="breadcrumb">
          {crumbs}
        </ol>
      </nav>
    )
  }
}

AnalysisBreadCrumbs.propTypes = {
  api: PropTypes.object.isRequired,
  path: PropTypes.arrayOf({
    name: PropTypes.string,
    id: PropTypes.number,
  }),
};

export default AnalysisBreadCrumbs;