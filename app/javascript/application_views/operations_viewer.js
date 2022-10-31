import $ from 'jquery';

class OperationsView {
  constructor(relRoot) {
    this.relRoot = relRoot;
  }

  start() {
    const relativeUrlRoot = this.relRoot;
    const opeEdit = opeEdit || {};
    const $modal = $('#editModal');

    $modal.on('show.bs.modal', (e) => {
      opeEdit.invoker = $(e.relatedTarget);
      opeEdit.id = opeEdit.invoker.data('ope-id');
      opeEdit.name = opeEdit.invoker.data('ope-name');
      opeEdit.apiKey = opeEdit.invoker.data('api-key');
      $("input[name='operation[name]']").val(opeEdit.name);
    });

    $modal.on('shown.bs.modal', () => {
      $("input[name='operation[name]']").on('focus');
    });

    $('button[data-save="true"]').on(
      'click',
      () => {
        const newName = $("input[name='operation[name]']").val();
        $.ajax({
          type: 'PATCH',
          xhrFields: { withCredentials: true },
          headers: { Authorization: `Token ${opeEdit.apiKey}` },
          url: `${relativeUrlRoot}/api/v1/operations/${opeEdit.id}`,
          data: { operation: { name: newName } },
          success() {
            $(`a[id=${opeEdit.id}]`).text(newName);
            opeEdit.invoker.data('ope-name', newName);
            $modal.modal('hide');
          },
          error(xhr, status, error) {
            console.log(xhr.responseJSON.message);
            $('#errorPlaceHolder').html(
              `<div class="alert bg-warning" role="alert"><a href="#" data-dismiss="alert" class="close">×</a>${
                xhr.responseJSON.message
              }</div>`,
            );
            $modal.modal('hide');
          },
        });
      },
    );
  }
}

export default OperationsView;
