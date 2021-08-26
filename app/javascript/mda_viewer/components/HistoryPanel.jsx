import React from 'react';
import PropTypes from 'prop-types';

class DaylyChangeLog extends React.PureComponent {
  render() {
    const { changelog } = this.props;
    const list = changelog.map((change) => {
      const text = `By ${change.author} at ${change.at.substring(0, 8)}: `;
      const { details } = change;
      const changes = details.map((elt, i) => {
        let chg = '';
        if (elt.action === 'add' || elt.action === 'copy') {
          chg += `${elt.action} new ${elt.entity_type} ${elt.value}`;
        }
        if (elt.action === 'remove') {
          chg += `remove ${elt.entity_type} ${elt.old_value}`;
        }
        if (elt.action === 'change') {
          let oldval = elt.old_value;
          let newval = elt.value;
          if (elt.old_value === 'analysis') { // Use consistent terminology
            oldval = 'discipline';
          }
          if (elt.old_value === 'mda') { // Use consistent terminology
            oldval = 'sub-analysis';
          }
          if (elt.value === 'analysis') { // Use consistent terminology
            newval = 'discipline';
          }
          if (elt.value === 'mda') { // Use consistent terminology
            newval = 'sub-analysis';
          }

          chg += `change ${elt.entity_type} ${elt.entity_name} ${elt.entity_attr} from ${oldval} to ${newval}`;
        }
        return (
          <span key={change.at + chg}>
            { i > 0 ? ', ' : '' }
            <em>{chg}</em>
          </span>
        );
      });
      return (
        <li key={change.at}>
          {text}
          {changes}
        </li>
      );
    });

    return (
      <ul>
        { list }
      </ul>
    );
  }
}

DaylyChangeLog.propTypes = {
  changelog: PropTypes.array.isRequired,
};

function formatByDate(history) {
  const byDate = {};
  for (const item of history) {
    const date = item.created_on.substring(0, 10);
    const hour = item.created_on.substring(11);
    const elt = { author: item.author, at: hour, details: item.details };
    if (byDate[date]) {
      byDate[date].push(elt);
    } else {
      byDate[date] = [elt];
    }
  }
  const changelog = [];
  for (const date of Object.keys(byDate).sort().reverse()) {
    const change = { date, details: byDate[date] };
    changelog.push(change);
  }

  return changelog;
}

class HistoryPanel extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      history: [],
    };
  }

  componentDidMount() {
    const { mdaId, api } = this.props;
    api.getAnalysisHistory(mdaId, (response) => {
      const history = response.data;
      this.setState({ history });
    });
  }

  render() {
    const { history } = this.state;

    const histByDate = formatByDate(history);

    const items = histByDate.map((elt) => (
      <li key={elt.date}>
        {'On '}
        {elt.date}
        <DaylyChangeLog changelog={elt.details} />
      </li>
    ));

    return (
      <div className="editor-section">
        <div className="editor-section-label">Changes</div>
        <ul className="editor-section">
          {items}
        </ul>
      </div>
    );
  }
}

HistoryPanel.propTypes = {
  api: PropTypes.object.isRequired,
  mdaId: PropTypes.number.isRequired,
};

export default HistoryPanel;
