import $ from 'jquery';
import { Tooltip } from 'bootstrap';

class OptimizationsIndex {
  start() {
    $('#need_selected').hide();

    // Initialize tooltips BS5
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    const tooltipList = tooltipTriggerList.map((triggerEl) => new Tooltip(triggerEl));

    $('#selectAll').change(function () {
      checked = this.checked;

      $('.checkbox_child').map(function () {
        $(this).prop('checked', checked);
      });

      $('#selectStatus').prop('checked', checked);
      update_checkbox_count();
    });

    $('#selectStatus').change(function () {
      checked = this.checked;
      status = $('#status-select').val();

      $('.checkbox_child').map(function () {
        if (~$(this).attr('class').indexOf(status)) {
          $(this).prop('checked', checked);
        }
      });
      update_checkbox_count();
    });

    $('#status-select').change(() => {
      $('#selectStatus').prop('checked', false);
    });

    $('.checkbox_child').change(() => { update_checkbox_count(); });

    function update_checkbox_count() {
      $('#display_checkbox_count').text(($('.checkbox_child:checked').length === 0) ? `0/${$('.checkbox_child').length}` : `${$('.checkbox_child:checked').length}/${$('.checkbox_child').length}`);

      $('.checkbox_child').map(function () {
        $(this).parent().parent().removeClass((this.checked) ? '' : 'table-primary')
          .addClass((this.checked) ? 'table-primary' : '');
      });

      if ($('.checkbox_child:checked').length == $('.checkbox_child').length) {
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
  }
}

export default OptimizationsIndex;
