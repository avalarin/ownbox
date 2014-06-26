//= require utils
//= require controls/modal

FormModal = (function() {

  function FormModal(element, options) {
    var modal = this
    var parent = new Modal(element)
    var properties = options.properties
    var onSave = options.onSave
    extend(modal, parent)

    modal.formElement = modal.element.find('form')
    for (var key in properties) {
      var value = properties[key]
      if (typeof(value) == 'object') {
        if (!value.array) {
          modal[key] = ko.observable(value.defaultValue)
        } else {
          modal[key] = ko.observableArray(value.defaultValue)
        }
      } else {
        modal[key] = ko.observable(value)
        properties[key] = { defaultValue : value }
      }
      
    }

    modal.reset = function() {
      for (var key in properties) {
        var value = properties[key]
        if (!value.array) {
          modal[key](value.defaultValue)
        } else {
          modal[key](value.defaultValue)
        }
      }
    }

    modal.close = function() {
      modal.reset()
      parent.close()
    }

    modal.valid = function() {
      return modal.formElement.valid()
    }

    modal.getData = function() {
      var o = {}
      for (var key in properties) {
        o[key] = modal[key]()
      }
      return o
    }

    modal.save = function() {
      if (!modal.valid()) return
      var data = modal.getData()
      onSave(data)
    }

  }
  return FormModal
})()