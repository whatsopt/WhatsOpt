import $ from 'jquery';

class AnalysesIndex {
  constructor(relRoot, apiKey, userId) {
    this.relRoot = relRoot;
    this.apiKey = apiKey;
    this.userId = userId;
  }

  start() {
    const { relRoot, apiKey, userId } = this;
    const SPINNER_TIMEOUT = 1500; // ms
    function setAnalysesListSettings() {
      const query = $(this).data('analyses-query');
      const order = $(this).data('analyses-order');
      const filter = $('#user_settings_analyses_filter').val();
      console.log('filter');
      let timeout;
      $.ajax({
        type: 'PATCH',
        xhrFields: { withCredentials: true },
        headers: { Authorization: `Token ${apiKey}` },
        url: `${relRoot}/api/v1/users/${userId}`,
        data: {
          user: {
            settings: {
              analyses_query: query,
              analyses_order: order,
              analyses_filter: filter,
            },
          },
        },
        beforeSend() {
          timeout = setTimeout(() => {
            $('.spinner').show();
          }, SPINNER_TIMEOUT);
        },
        success() {
          $.getScript(this.href, () => {
            if (timeout) { clearTimeout(timeout); }
            $('.spinner').hide();
          });
        },
      });
    }

    console.log('ATTACH EVENT');
    $('input[data-analyses-query]').on('click', setAnalysesListSettings);
    $('input[data-analyses-order]').on('click', setAnalysesListSettings);
    $('#analyses-filter').on(
      'keypress',
      (event) => {
        console.log('Keypress');
        if (event.key === 'Enter') {
          setAnalysesListSettings();
          // Cancel the default action, if needed
          event.preventDefault();
        }
      },
    );
    $('#analyses-filter').on('click', setAnalysesListSettings);

    let current_design_project_id = '<%= current_user.analyses_scope_design_project_id %>';

    $('#designProjectScope').on('click', function select_project() {
      const design_project_id = this.value;
      let timeout;
      if (design_project_id !== current_design_project_id) {
        $.ajax({
          type: 'PATCH',
          xhrFields: { withCredentials: true },
          headers: { Authorization: `Token ${apiKey}` },
          url: `${relRoot}/api/v1/users/${userId}`,
          data: { user: { settings: { analyses_scope_design_project_id: design_project_id } } },
          beforeSend() {
            timeout = setTimeout(() => {
              $('.spinner').show();
            }, SPINNER_TIMEOUT);
          },
          success() {
            $.getScript(this.href, () => {
              if (timeout) { clearTimeout(timeout); console.log('CLEAR'); }
              $('.spinner').hide();
            });
          },
        }).always(() => {
          current_design_project_id = design_project_id;
        });
      }
    });

    // hide spinner
    $('.spinner').hide();
  }
}

export default AnalysesIndex;
