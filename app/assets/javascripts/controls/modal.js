Modal = (function() {

  function Modal(element) {
    var that = this
    this.element = element

    this.reset = function() { }

    this.show = function() {
      that.element.modal('show')
    }

    this.close = function() {
      that.element.modal('hide')
      that.reset()
    }

    this.extend = function(obj) {
      for (var key in obj) { if (obj.hasOwnProperty(key)) that[key] = obj[key] }
      return that
    }
    
  }
  return Modal
})()