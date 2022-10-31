/*
 * Implements a user-facing modal confirmation when link has a
 * "data-confirm" attribute using Bootstrap's modals. MIT license.
 *
 *   - vjt@openssl.it  Tue Jul  2 18:45:15 CEST 2013
 */

/**
 * Builds the markup for a [Bootstrap modal](https://getbootstrap.com/docs/4.6/components/modal/)
 * for the given `element`. Uses the following `data-` parameters to
 * customize it:
 *
 *  * `data-confirm`: Contains the modal body text. HTML is allowed.
 *                    Separate multiple paragraphs using \n\n.
 *
 *  * `data-commit`: The 'confirm' button text. "Confirm" by default.
 *
 *  * `data-cancel`: The 'cancel' button text. "Cancel" by default.
 *
 *  * `data-verify`: Adds a text input in which the user has to input
 *                   the text in this attribute value for the 'confirm'
 *                   button to be clickable. Optional.
 *
 *  * `data-verify-text`: Adds a label for the data-verify input. Optional
 *
 *  * `data-focus`: Define focused input. Supported values are
 *                  'cancel' or 'commit', 'cancel' is default for
 *                  data-method DELETE, 'commit' for all others.
 *
 * You can set global setting using `dataConfirmModal.setDefaults`, for example:
 *
 *    dataConfirmModal.setDefaults({
 *      title: 'Confirm your action',
 *      commit: 'Continue',
 *      cancel: 'Cancel',
 *      fade:   false,
 *      verifyClass: 'form-control'
 *    })
 *
 */

import jQuery from 'jquery';
import Rails from '@rails/ujs';
import { onDOMContentLoaded } from 'bootstrap/js/src/util/index';

onDOMContentLoaded(() => {
  // Detect Bootstrap version, or bail out.
  if (jQuery.fn.modal === undefined) {
    throw new Error('The Bootstrap modal plugin does not appear to be loaded.');
  }

  if (jQuery.fn.modal.Constructor === undefined) {
    throw new Error('The Bootstrap modal plugin does not have a Constructor ?!?');
  }

  if (jQuery.fn.modal.Constructor.VERSION === undefined) {
    throw new Error('The Bootstrap modal plugin does not have its version defined ?!?');
  }

  const versionString = jQuery.fn.modal.Constructor.VERSION;
  const match = versionString.match(/^(\d)\./);
  if (!match) {
    throw new Error(`Cannot identify Bootstrap version. Version string: ${versionString}`);
  }

  const bootstrapVersion = parseInt(match[1]);
  if (bootstrapVersion !== 3 && bootstrapVersion !== 4 && bootstrapVersion !== 5) {
    throw new Error(`Unsupported Bootstrap version: ${bootstrapVersion}. data-confirm-modal supports version 3 and 4.`);
  }

  const DEFAULTS = {
    title: 'Are you sure?',
    commit: 'Confirm',
    commitClass: 'btn-danger',
    cancel: 'Cancel',
    cancelClass: 'btn-default',
    fade: true,
    verifyClass: 'form-control',
    elements: ['a[data-confirm]', 'button[data-confirm]', 'input[type=submit][data-confirm]'],
    focus: 'commit',
    zIndex: 1050,
    modalClass: '',
    modalCloseLabel: 'Close',
    modalCloseContent: '<span aria-hidden="true">&times;</span>',
  };

  let bsDataPrefix = 'data';

  if (bootstrapVersion >= 5) {
    bsDataPrefix = 'data-bs';
  }

  let settings;

  const dataConfirmModal = {
    setDefaults(newSettings) {
      settings = jQuery.extend(settings, newSettings);
    },

    restoreDefaults() {
      settings = jQuery.extend({}, DEFAULTS);
    },

    confirm(options) {
      // Build an ephemeral modal
      const modal = buildModal(options);

      modal.spawn();

      modal.find('.commit').on('click', () => {
        if (options.onConfirm && options.onConfirm.call) { options.onConfirm.call(); }

        modal.modal('hide');
      });

      modal.find('.cancel').on('click', () => {
        if (options.onCancel && options.onCancel.call) { options.onCancel.call(); }

        modal.modal('hide');
      });

      modal.on('hidden.bs.modal', () => {
        if (options.onHide && options.onHide.call) { options.onHide.call(); }

        modal.remove();
      });
    },
  };

  dataConfirmModal.restoreDefaults();

  const buildElementModal = (element) => {
    const options = {
      title: element.data('title') || element.attr('title') || element.data('original-title'),
      text: element.data('confirm'),
      focus: element.data('focus'),
      method: element.data('method'),
      modalClass: element.data('modal-class'),
      modalCloseContent: element.data('modal-close-content'),
      commit: element.data('commit'),
      commitClass: element.data('commit-class'),
      cancel: element.data('cancel'),
      cancelClass: element.data('cancel-class'),
      remote: element.data('remote'),
      verify: element.data('verify'),
      verifyRegexp: element.data('verify-regexp'),
      verifyLabel: element.data('verify-text'),
      verifyRegexpCaseInsensitive: element.data('verify-regexp-caseinsensitive'),
      backdrop: element.data('backdrop'),
      keyboard: element.data('keyboard'),
    };

    const modal = buildModal(options);

    modal.find('.commit').on('click', () => {
      // Call the original event handler chain
      element.get(0).click();

      modal.modal('hide');
    });

    return modal;
  };

  const buildModal = (options) => {
    const modalId = `confirm-modal-${String(Math.random()).slice(2, -1)}`;
    const fade = settings.fade ? 'fade' : '';
    const modalClass = options.modalClass ? options.modalClass : settings.modalClass;

    const modalCloseLabel = options.modalCloseLabel ? options.modalCloseLabel : settings.modalCloseLabel;
    const modalCloseContent = options.modalCloseContent ? options.modalCloseContent : settings.modalCloseContent;
    const modalClose = `<button type="button" class="close" ${bsDataPrefix}-dismiss="modal" aria-hidden="true" aria-label="${modalCloseLabel}">${modalCloseContent}</button>`;

    const modalTitle = `<h5 id="${modalId}-title" class="modal-title"></h5>`;
    let modalHeader = modalTitle + modalClose;

    switch (bootstrapVersion) {
      case 5:
        modalHeader = `${modalTitle}<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="${modalCloseLabel}"></button>`;
        break;
      case 3:
        modalHeader = modalClose + modalTitle;
        break;
    }

    const modal = jQuery(`
       <div id="${modalId}" class="modal ${modalClass} ${fade}" tabindex="-1" role="dialog" aria-labelledby="${modalId}-title" aria-hidden="true">
         <div class="modal-dialog" role="document">
           <div class="modal-content">
             <div class="modal-header">${modalHeader}</div>
             <div class="modal-body"></div>
             <div class="modal-footer">
               <button class="btn cancel" ${bsDataPrefix}-dismiss="modal" aria-hidden="true"></button>
               <button class="btn commit"></button>
             </div>
           </div>
         </div>
       </div>
     `);

    // Make sure it's always the top zindex
    let highest;

    let current;
    highest = current = settings.zIndex;
    jQuery('.modal.in').not(`#${modalId}`).each(function () {
      current = parseInt(jQuery(this).css('z-index'), 10);
      if (current > highest) {
        highest = current;
      }
    });
    modal.css('z-index', parseInt(highest) + 1);

    modal.find('.modal-title').text(options.title || settings.title);

    const body = modal.find('.modal-body');

    jQuery.each((options.text || '').split(/\n{2}/), (i, piece) => {
      body.append(jQuery('<p/>').html(piece));
    });

    const commit = modal.find('.commit');
    commit.text(options.commit || settings.commit);
    commit.addClass(options.commitClass || settings.commitClass);

    const cancel = modal.find('.cancel');
    cancel.text(options.cancel || settings.cancel);
    cancel.addClass(options.cancelClass || settings.cancelClass);

    if (options.remote) {
      commit.attr(`${bsDataPrefix}-dismiss`, 'modal');
    }

    if (options.verify || options.verifyRegexp) {
      commit.prop('disabled', true);

      let isMatch;
      if (options.verifyRegexp) {
        const caseInsensitive = options.verifyRegexpCaseInsensitive;
        const regexp = options.verifyRegexp;
        const re = new RegExp(regexp, caseInsensitive ? 'i' : '');

        isMatch = (input) => input.match(re);
      } else {
        isMatch = (input) => options.verify === input;
      }

      const verification = jQuery('<input/>', { type: 'text', class: settings.verifyClass }).on('keyup', function () {
        commit.prop('disabled', !isMatch(jQuery(this).val()));
      });

      modal.on('shown.bs.modal', () => {
        verification.focus();
      });

      modal.on('hidden.bs.modal', () => {
        verification.val('').trigger('keyup');
      });

      if (options.verifyLabel) { body.append(jQuery('<p>', { text: options.verifyLabel })); }

      body.append(verification);
    }

    let focusElement;
    if (options.focus) {
      focusElement = options.focus;
    } else if (options.method === 'delete') {
      focusElement = 'cancel';
    } else {
      focusElement = settings.focus;
    }
    focusElement = modal.find(`.${focusElement}`);

    modal.on('shown.bs.modal', () => {
      focusElement.focus();
    });

    jQuery('body').append(modal);

    modal.spawn = () => {
      modal.modal(jQuery.extend({}, {
        backdrop: options.backdrop,
        keyboard: options.keyboard,
      }));

      modal.modal('show');
    };

    return modal;
  };

  /**
    * Returns a modal already built for the given element or builds a new one,
    * caching it into the element's `confirm-modal` data attribute.
    */
  jQuery.fn.getConfirmModal = function () {
    const element = jQuery(this);
    let modal = element.data('confirm-modal');

    if (!modal) {
      modal = buildElementModal(element);
      element.data('confirm-modal', modal);
    }

    return modal;
  };

  jQuery.fn.confirmModal = function () {
    const modal = jQuery(this).getConfirmModal();

    modal.spawn();

    return modal;
  };

  /**
    * Override `Rails.confirm` dialog.
    *
    * If the modal is visible, it means that the handler is being called by the
    * modal commit button click handler, as such the user has successfully
    * clicked on the confirm button.
    *
    * If the modal is not visible, then it is spawned and the default Rails
    * confirmation dialog is canceled.
    *
    */
  Rails.confirm = function (message, el) {
    const modal = jQuery(el).getConfirmModal();

    if (modal.is(':visible')) {
      return true;
    }
    modal.spawn();
    return false;
  };

  // TODO: use expose for this
  window.dataConfirmModal = dataConfirmModal;
});
