define('http', ['jquery'], function ($) {

  var requestsCount = 0;

  function showLoader() {
    var element = $('.site-loader');
    element.removeClass('hiding').addClass('visible');
  } 

  function hideLoader() {
    var element = $('.site-loader');
    element.removeClass('visible').addClass('hiding');
    setTimeout(function() {
      element.removeClass('hiding');
    }, 2000);
  }

  function defaultErrorHandler(status, message, data) {
    var modal = $('#unhandled-error');
    modal.find('.details').text(message);
    modal.modal('show');
  }

  $(document).ajaxStart(function () {
    requestsCount++;
  });
  
  $(document).ajaxStop(function () {
    if (--requestsCount == 0) {
      hideLoader();
    }
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
    var origError = data.error || defaultErrorHandler;
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
                origError(resp.status, resp.message, resp.data);
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
            origComplete(resp.status, resp.message, resp.data, xhr);
        } else {
            origComplete('200', 'ok', resp, xhr);
        }
    };

    data.error = function(xhr, textStatus) {
      var resp = xhr.responseJSON;
      if (resp && resp.hasOwnProperty('status')) {
            origError(resp.status, resp.message, resp.data);
      } else {
          origError(xhr.status, textStatus, null);
      }
    };

    data.beforeSend = function (xhr) {
        setTimeout(function () {
            if (isCompleted) return false;
            if (hasLoaderElement) {
                loaderElement.show();
            } else if (hasSourceElement && data.autoLoader) {
                origHtml = sourceElement.html();
                sourceElement.css({ width: sourceElement.outerWidth(), height: sourceElement.outerHeight() }).html(loaderHtml);
            } else if (!data.disableLoader) {
                showLoader();
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

  function downloadURL(url) {
      var hiddenIFrameID = 'hiddenDownloader',
          iframe = document.getElementById(hiddenIFrameID);
      if (iframe === null) {
          iframe = document.createElement('iframe');
          iframe.id = hiddenIFrameID;
          iframe.style.display = 'none';
          document.body.appendChild(iframe);
      }
      iframe.src = url;
  }

  // public api
  return {
    downloadURL: downloadURL,
    request: request,
    defaultErrorHandler: defaultErrorHandler
  }

});