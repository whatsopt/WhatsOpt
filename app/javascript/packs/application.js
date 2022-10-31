import Rails from '@rails/ujs';
import AnalysesIndex from '../application_views/analyses_index';
import OperationsIndex from '../application_views/operations_index';
import OptimizationsIndex from '../application_views/optimizations_index';
import UserShow from '../application_views/users_show';

Rails.start();

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
