//= require utils
//= require controls/modal

ExportModal = (function() {

  function ExportModal(element, options) {
    var modal = this
    var parent = new Modal(element)
    var onStart = options.onStart
    extend(modal, parent)

    modal.item = ko.observable({ name: "" })
    modal.filter = ko.observable("")

    modal.show = function(item, filter) {
      modal.item(item)
      modal.filter(filter)
      parent.show()
    }

    modal.close = function() {
      modal.item({ name: "" })
      parent.close()
    }

    modal.start = function() {
      if (onStart) onStart(modal.item(), modal.filter())
      modal.close()
    }

  }
  return ExportModal
})()