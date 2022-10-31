import 'jquery';
import 'bootstrap';
import Rails from '@rails/ujs';
import AnalysesView from '../application_views/analyses_index';
import OperationsView from '../application_views/operations_index';

Rails.start();

window.App = {
  AnalysesView,
};
