import $ from 'jquery';

class OperationsIndex {
  constructor(relRoot) {
    this.relRoot = relRoot;
  }

  start() {
    const relativeUrlRoot = this.relRoot;
    const opeEdit = {};
    const $modal = $('#editModal');
    const $input = $("input[name='operation[name]']");

    $modal.on('show.bs.modal', (e) => {
      opeEdit.invoker = $(e.relatedTarget);
      opeEdit.id = opeEdit.invoker.data('ope-id');
      opeEdit.name = opeEdit.invoker.data('ope-name');
      opeEdit.apiKey = opeEdit.invoker.data('api-key');
      $input.val(opeEdit.name);
      $input.on('focus');
    });

    $('button[data-save="true"]').on(
      'click',
      () => {
        const newName = $input.val();
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
          error(xhr) {
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

export default OperationsIndex;
