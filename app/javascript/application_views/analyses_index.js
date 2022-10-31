import $ from 'jquery';

class AnalysesView {
  constructor(relRoot, apiKey, userId) {
    this.relRoot = relRoot;
    this.apiKey = apiKey;
    this.userId = userId;
    console.log(`constructor ${userId}`);
  }

  start() {
    const { relRoot, apiKey, userId } = this;
    const SPINNER_TIMEOUT = 1500; // ms
    function setAnalysesListSettings() {
      const query = $(this).data('analyses-query');
      const order = $(this).data('analyses-order');
      let timeout;
      $.ajax({
        type: 'PATCH',
        xhrFields: { withCredentials: true },
        headers: { Authorization: `Token ${apiKey}` },
        url: `${relRoot}/api/v1/users/${userId}`,
        data: { user: { settings: { analyses_query: query, analyses_order: order } } },
        beforeSend(xhr) {
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

    $('input[data-analyses-query]').on('click', setAnalysesListSettings);
    $('input[data-analyses-order]').on('click', setAnalysesListSettings);

    let current_design_project_id = '<%= current_user.analyses_scope_design_project_id %>';

    $('#designProjectScope').on('click', function (e) {
      const design_project_id = this.value;
      let timeout;
      if (design_project_id !== current_design_project_id) {
        $.ajax({
          type: 'PATCH',
          xhrFields: { withCredentials: true },
          headers: { Authorization: `Token ${apiKey}` },
          url: `${relRoot}/api/v1/users/${userId}`,
          data: { user: { settings: { analyses_scope_design_project_id: design_project_id } } },
          beforeSend(xhr) {
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

export default AnalysesView;
