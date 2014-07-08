//= require knockout
//= require fileapi
//= require utils/human_size

UploaderModal = (function() {
  function UploaderModal(options) {
    var uploader = this
    options = options || {}
    var element = $('#uploader-modal')
    var onUpload = options['onUpload'] || function (files) { }

    uploader.files = ko.observableArray([])

    uploader.show = function(argument) {
      element.modal('show')
    }

    uploader.upload = function(argument) {
      onUpload(uploader.files())
      uploader.files.removeAll()
    }

    uploader.close = function(argument) {
      element.modal('hide')
    }

    element.find('input[type=file]').on('change', function(e) {
      var files = FileAPI.getFiles(this);
      for (var i = 0; i < files.length; i++) {
        var file = files[i]
        uploader.files.push({
          original: file,
          name: file.name,
          size: file.size,
          humanSize: window.humanSize(file.size),
          type: file.type,
          delete: function() {
            uploader.files.remove(this)
          }
        })
      }
      FileAPI.reset(this)
    })
  }
  return UploaderModal
})()