define('modals', ['jquery', 'http'], function ($, http) {
  var modalTemplateHtml = '<div class="modal fade">' +
          '<div class="modal-dialog">' +
            '<div class="modal-content">' +
              '<div class="modal-header">' +
                '<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>' +
                '<h4 class="modal-title"></h4>' +
              '</div>' +
              '<div class="modal-body" />' +
              '<div class="modal-footer" />' +
            '</div>' +
          '</div>' +
        '</div>';
  var modalCommandTemplate = _.template('<button title="<%= command.title %>" type="button" class="btn <%= command.cssClass %>"><%= command.text %></button>');

  $(document).on('click', '[data-action=show-modal]', function (e) {
      var $this = $(this);
      var source = $this.attr('href') || $this.attr('data-modal-source');
      var title = $this.attr('data-modal-title');
      window.modals.showModal({
          source: source,
          title: title,
          element: $(this)
      });
      return false;
  });

  function show(options) {
    var source = options.source;
    if (typeof source != 'string') throw 'source options is required and must be string.';
    var success = false;
    http.request({
        url: source,
        data: options.data,
        success: function (resp) {
            var $modal = $(modalTemplateHtml);
            var $body = $modal.find('.modal-body').html(resp);
            $modal.find('.modal-title').html(options.title);
            var $modalFooter = $modal.find('.modal-footer');
            var modal = {
                bodyElement: $body,
                hide: function() {
                    $modal.modal('hide');
                }
            };
            _.each(options.commands, function(command) {
                var $command = $(modalCommandTemplate({ command: command }));
                $command.on('click', function() {
                    if (typeof command.action == "function") {
                        command.action(modal, $command);
                    } else if (typeof command.action == "string") {
                        if (command.action == "hide") {
                            modal.hide();
                        }
                    }
                });
                $command.appendTo($modalFooter);
            });
            $modal.appendTo('body');
            $modal.modal();
        },
        element: options.element,
        autoDisable: true,
        autoLoader: true
    });
  }

  // public api
  return {
    show: show
  }
});