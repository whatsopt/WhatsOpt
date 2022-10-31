import $ from 'jquery';

class UserShow {
  constructor(relRoot, userId) {
    this.relRoot = relRoot;
    this.userId = userId;
  }

  start() {
    const { relRoot, userId } = this;
    $('#reset-api-key').on('click', () => {
      const api_key = $('#user-api-key').text();
      $.ajax({
        type: 'PATCH',
        xhrFields: {
          withCredentials: true,
        },
        headers: {
          Authorization: `Token ${api_key}`,
        },
        url: `${relRoot}/api/v1/users/${userId}/api_key`,
        success() {
          $.getScript(this.href);
          return false;
        },
      });
    });
  }
}

export default UserShow;
