import React from 'react';
import PropTypes from 'prop-types';

class AnalysisBreadCrumbs extends React.PureComponent {
  render() {
    const { path, api } = this.props;
    const crumbs = path.map((anc, i) => {
      const href = api.url(`/analyses/${anc.id}`);
      let klass = 'breadcrumb-item';
      let name = <a href={href}>{anc.name}</a>;
      if (path.length - 1 === i) {
        klass += ' active';
        name = anc.name;
      }
      return (<li key={anc.id} className={klass}>{name}</li>);
    });

    return (
      <nav aria-label="breadcrumb">
        <ol className="breadcrumb">
          {crumbs}
        </ol>
      </nav>
    );
  }
}

AnalysisBreadCrumbs.propTypes = {
  api: PropTypes.object.isRequired,
  path: PropTypes.arrayOf({
    name: PropTypes.string,
    id: PropTypes.number,
  }).isRequired,
};

export default AnalysisBreadCrumbs;
