define('http', ['jquery'], function ($) {
  $(document).ajaxStart(function () {

  });
  
  $(document).ajaxStop(function () {
      $('.site-loader').hide();
  });

  $(document).ajaxError(function (event, xhr, ajaxOptions, thrownError) {
      //if (xhr.status == 401) {
      //    var eModal = $('#loginModal');
      //    if (eModal.size() == 0) {
      //        $.get('/account/loginmodal', { redirect: location.pathname + location.search }, function (modal) {
      //            $('body').append(modal);
      //            $('#loginModal').modal('show');
      //        });
      //    } else {
      //        eModal.modal('show');
      //    }
      //}
      $('#errorModal').modal('show');
  });

  $(document).ajaxComplete(function () {
    
  });

  $(document).on('click', 'a[data-action=load-html]', function (e) {
      var $this = $(this);
      var target = $this.attr('data-target');
      if (target) {
          ajax({
              loader: $this.attr('data-loader'),
              url: $this.attr('href') || $this.attr('data-source'),
              success: function (html) {
                  $(target).html(html);
              }
          });
      }
      e.preventDefault();
  });

  $(document).on('click', '[data-action=go]', function (e) {
      var $this = $(this);
      var href = $this.attr('href') || $this.data('data-link');
      if (href) {
          location.href = href;
      }
      e.preventDefault();
  });

  function request(data) {
    var loaderHtml = '<i class="fa fa-spin fa-spinner loader" />';

    data = $.extend({}, {
        autoDisable: true,
        autoLoader: true
    }, data);

    var origSuccess = data.success || function () { };
    var origError = data.error || function () { };
    var origComplete = data.complete || function () { };
    var origBeforeSend = data.beforeSend;
    var origHtml;
    var hasLoaderElement = false;
    var hasSourceElement = false;
    var loaderElement;
    var sourceElement;
    var isCompleted;
    

    if (data.loader) {
        if (typeof (data.loader) == "string") {
            loaderElement = $(data.loader);
        } else {
            loaderElement = data.loader;
        }
        hasLoaderElement = true;
    }
    if (data.element) {
        if (typeof (data.element) == "string") {
            sourceElement = $(data.element);
        } else {
            sourceElement = data.element;
        }
        hasSourceElement = true;
        if (!hasLoaderElement) {
            loaderElement = sourceElement.find('.loader');
            hasLoaderElement = loaderElement.size() > 0;
        }
    }

    data.success = function(resp) {
        if (resp.hasOwnProperty('status')) {
            if (resp.status == '200') {
                origSuccess(resp.data);
            } else {
                origError(resp.status, resp.data);
            }
        } else {
            origSuccess(resp);
        }
    };

    data.complete = function (xhr, resp) {
        isCompleted = true;
        if (hasLoaderElement) {
            loaderElement.hide();
        } else if (hasSourceElement && data.autoLoader) {
            sourceElement.html(origHtml).css({ width: 'auto', height: 'auto' });
        }
        if (hasSourceElement && data.autoDisable) {
            sourceElement.removeClass('disabled');
        }
        if (resp.hasOwnProperty('status')) {
            origComplete(resp.status, resp.data, xhr);
        } else {
            origComplete('ok', resp, xhr);
        }
    };

    data.error = function(xhr, textStatus) {
        origError(textStatus, textStatus, null);
    };

    data.beforeSend = function (xhr) {
        setTimeout(function () {
            if (isCompleted) return false;
            if (hasLoaderElement) {
                loaderElement.show();
            } else if (hasSourceElement && data.autoLoader) {
                origHtml = sourceElement.html();
                sourceElement.css({ width: sourceElement.outerWidth(), height: sourceElement.outerHeight() }).html(loaderHtml);
            } else {
                $('.site-loader').show();
            }
            return false;
        }, 200);
        if (data.autoDisable && hasSourceElement) {
            sourceElement.addClass('disabled');
        }
        if (origBeforeSend) origBeforeSend(xhr);
    };

    $.ajax(data);
  }

  // public api
  return {
    request: request
  }

});