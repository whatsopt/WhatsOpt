import $ from 'jquery';
import '@popperjs/core';
import 'bootstrap';
import Rails from '@rails/ujs';
import AnalysesIndex from '../application_views/analyses_index';
import OperationsIndex from '../application_views/operations_index';
import OptimizationsIndex from '../application_views/optimizations_index';
import UserShow from '../application_views/users_show';

// Views are used in corresponding views/**/*.html.erb files
// in document_ready section.
// Calling start() allow to attach js callbacks to DOM element
// specially for each views.
window.App = {
  AnalysesIndex,
  OperationsIndex,
  OptimizationsIndex,
  UserShow,
};

// Override default browser confirm dialog by bootstrap version
Rails.confirm = (message, element) => {
  const $element = $(element);
  const $dialog = $('#confirmModal');
  const $content = $dialog.find('#modal-content');
  const $ok = $dialog.find('#ok-button');
  $content.text(message);
  $ok.on('click', (event) => {
    event.preventDefault();
    $dialog.modal('hide');
    const old = Rails.confirm;
    Rails.confirm = () => true;
    $element.get(0).click();
    Rails.confirm = old;
  });
  $dialog.modal('show');
  return false;
};

Rails.start();
