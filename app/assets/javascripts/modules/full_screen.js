define('fullScreen', [], function () {

  function getPrefix() {
    if(document.fullscreenEnabled) {
      return ""
    } else if(document.mozFullScreenEnabled) {
      return "moz"
    } else if(document.webkitFullscreenEnabled) {
      return "webkit"
    } else if(document.msFullscreenEnabled) {
      return "ms"
    }
  }

  return {
    enter: function(element) {
      if(element.requestFullscreen) {
        element.requestFullscreen();
      } else if(element.mozRequestFullScreen) {
        element.mozRequestFullScreen();
      } else if(element.webkitRequestFullscreen) {
        element.webkitRequestFullscreen();
      } else if(element.msRequestFullscreen) {
        element.msRequestFullscreen();
      }
    },
    exit: function() {
      if (document.exitFullscreen) {
        document.exitFullscreen();
      } else if (document.msExitFullscreen) {
        document.msExitFullscreen();
      } else if (document.mozCancelFullScreen) {
        document.mozCancelFullScreen();
      } else if (document.webkitExitFullscreen) {
        document.webkitExitFullscreen();
      }
    },
    isFullscreenMode: function() {
      return (document.fullscreenElement || document.mozFullScreenElement || 
             document.webkitFullscreenElement ||document.msFullscreenElement) ? true : false
    },
    onChanged: function(callback) {
      var fs = this
      var p = getPrefix();
      document.addEventListener(p + "fullscreenchange", function(event) {
        callback(event, fs.isFullscreenMode())
      })
    }
  }

})

