//= require knockout
//= require modules/full_screen

ImageViewer = (function() {
  var fullScreen = require('fullScreen')

  function ImageViewer(element) {
    var viewer = this
    var minIndex = 0
    var maxIndex = 0

    viewer.items = ko.observable([])
    viewer.current = ko.observable({ url: '' })
    viewer.currentIndex = ko.observable(0);
    viewer.loading = ko.observable(false)
    viewer.fullScreen = ko.observable(false)

    viewer.setItems = function(items) {
      viewer.items = ko.observable(items)
      maxIndex = items.length - 1
    }

    viewer.show = function(index) {
      viewer.currentIndex(index)
      updateCurrent()

      $(document).on('keydown.imageViewer', onKeyPress)
      element.modal('show')
    }

    viewer.close = function() {
      if (fullScreen.isFullscreenMode()) {
        viewer.exitFullScreen()
      }
      $(document).off('keydown.imageViewer')
      element.modal('hide')
    }

    viewer.download = function() {
      location.href = viewer.current().url
    }

    viewer.next = function() {
      var i = viewer.currentIndex()
      viewer.currentIndex(i < maxIndex ? i + 1 : minIndex)
      updateCurrent()
    }

    viewer.prev = function() {
      var i = viewer.currentIndex()
      viewer.currentIndex(i > minIndex ? i - 1 : maxIndex)
      updateCurrent()
    }

    viewer.loaded = function() {
      viewer.loading(false)
    }

    viewer.enterFullScreen = function() {
      var o = element.find('.modal-body')[0] 
      fullScreen.enter(o)
    }


    viewer.exitFullScreen = function() {
      fullScreen.exit()
    }

    function onKeyPress(e) {
      if (e.keyCode == 37) {
        viewer.prev()
      }
      else if (e.keyCode == 39) {
        viewer.next()
      }
    }

    function updateCurrent() {
      viewer.loading(true)
      var index = viewer.currentIndex()
      viewer.current(viewer.items()[index])
    }

    fullScreen.onChanged(function(e, status) {
      viewer.fullScreen(status)
    })

  }

  return ImageViewer
})()