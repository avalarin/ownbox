//= require bootstrap-growl

define('messages', ['jquery'], function ($) {

  function show (options) {
    $.growl(options.message, $.extend({
        position : {
            from: 'bottom',
            align: 'right'
        },
        delay: 2000
    }, options));
  }

  function info (message) {
    show({
        message: message
    });
  }

  function success (message) {
    show({
        type: 'success',
        message: message
    });
  }

  function warning (message) {
    show({
        type: 'warning',
        message: message
    });
  }

  function danger (message) {
    show({
        type: 'danger',
        message: message
    });
  }

  // public api
  return {
    show: show,
    info: info,
    success: success,
    danger: danger,
    warning: warning
  }

});