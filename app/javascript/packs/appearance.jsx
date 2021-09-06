import 'channels';
import React from 'react';
import PropTypes from 'prop-types';
import ReactDOM from 'react-dom';
import AppearanceChannel from 'channels/appearance_channel';
import WhatsOptApi from '../utils/WhatsOptApi';

class AppearanceBoard extends React.Component {
  constructor(props) {
    super(props);
    this.state = { usersAppearance: [] };
  }

  componentDidMount() {
    AppearanceChannel.received = (data) => {

    };
  }

  render() {
    const { coOwners } = this.props;
    const { usersAppearance } = this.state;
    const users = coOwners.map((user) => {
      let klass = 'badge';
      if (usersAppearance.indexOf(user.id) >= 0) {
        klass += ' bg-primary';
      } else {
        klass += ' bg-secondary';
      }
      return (
        <li>
          <span className={klass}>o</span>
          {user.id}
        </li>
      );
    });

    return (
      <ul>
        { users }
      </ul>
    );
  }
}

AppearanceBoard.propTypes = {
  coOwners: PropTypes.array.isRequired,
};

document.addEventListener('DOMContentLoaded', () => {
  const csrfToken = document.getElementsByName('csrf-token')[0].getAttribute('content');
  const relativeUrlRoot = document.getElementsByName('relative-url-root')[0].getAttribute('content');

  // eslint-disable-next-line no-undef
  const appearBoard = $('#appearance-board');
  const apiKey = appearBoard.data('api-key');
  const coOwners = appearBoard.data('co-owners');
  const currentUser = appearBoard.data('current-user');
  const api = new WhatsOptApi(csrfToken, apiKey, relativeUrlRoot);

  ReactDOM.render(<AppearanceBoard
    api={api}
    coOwners={coOwners}
    currentUser={currentUser}
  />, appearBoard[0]);
});
