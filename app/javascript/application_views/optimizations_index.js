import $ from 'jquery';
import { Tooltip } from 'bootstrap';

function update_checkbox_count() {
  $('#display_checkbox_count').text(($('.checkbox_child:checked').length === 0) ? `0/${$('.checkbox_child').length}` : `${$('.checkbox_child:checked').length}/${$('.checkbox_child').length}`);

  $('.checkbox_child').each(function () {
    $(this).parent().parent().removeClass((this.checked) ? '' : 'table-primary')
      .addClass((this.checked) ? 'table-primary' : '');
  });

  if ($('.checkbox_child:checked').length === $('.checkbox_child').length) {
    $('#selectAll').prop('checked', true);
  } else {
    $('#selectAll').prop('checked', false);
  }

  if ($('.checkbox_child:checked').length > 0) {
    $('#need_selected').show();
  } else {
    $('#need_selected').hide();
  }
}
class OptimizationsIndex {
  start() {
    $('#need_selected').hide();

    // Initialize tooltips BS5
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map((triggerEl) => new Tooltip(triggerEl));

    $('#selectAll').on('change', (e) => {
      const { checked } = e.target;
      $('.checkbox_child').each(function () {
        $(this).prop('checked', checked);
      });

      $('#selectStatus').prop('checked', checked);
      update_checkbox_count();
    });

    $('#selectStatus').on('change', (e) => {
      const { checked } = e.target;
      const status = $('#status-select').val();

      $('.checkbox_child').each(function () {
        console.log(this);
        if ($(this).attr('class').indexOf(status) > 0) {
          $(this).prop('checked', checked);
        }
      });
      update_checkbox_count();
    });

    $('#status-select').on('change', () => {
      $('#selectStatus').prop('checked', false);
    });

    $('.checkbox_child').on('change', () => { update_checkbox_count(); });
  }
}

export default OptimizationsIndex;
