//= require knockout
//= require modules/http
//= require modules/messages
//= require utils/human_size
//= require controls/export_modal

Exporter = (function() {
  var http = require('http')
  var messages = require('messages')

  function Exporter() {
    var exporter = this
    
    exporter.items = ko.observableArray([])

    exporter.start = function(orig, filter) {
      var item = new ExporterItem(orig, filter, exporter)
      exporter.items.push(item)
      item.start()
    }

    exporter.modal = new ExportModal($('#export-modal'), { onStart: exporter.start })
  }

  function ExporterItem(orig, filter, exporter) {
    var item = this
    var stop = false

    item.filter = filter
    item.exporter = exporter
    item.original = orig
    item.name = orig.name
    item.resultName = ko.observable('')
    item.path = orig.path
    item.owner = orig.owner
    item.status = ko.observable('new')
    item.progress = ko.observable(0)
    item.id = null

    item.isProgress = ko.observable(true)
    item.isError = ko.observable(false)
    item.isCompleted = ko.observable(false)

    item.start = function() {
      http.request({
        url: '/export',
        type: 'POST',
        data: { path: item.path, user_name: item.owner, filter: item.filter },
        success: function(resp) {
          item.id = resp.id
          item.resultName(resp.name)
          item.status('progress')
          updateStatus()
        }
      })
    }

    item.delete = function() {
      stop = true
      item.exporter.items.remove(item)
      http.request({
        url: '/export/delete',
        data: { id: item.id }
      })
    }

    item.download = function() {
      http.downloadURL('/export/result?id=' + item.id)
    }

    function updateStatus() {
      if (stop) return;
      http.request({
        url: '/export/status',
        data: { id: item.id },
        success: function(resp) {
          if (stop) return;
          item.status(resp.status)
          item.progress(resp.progress)
          if (item.status() == "completed") {
            item.isProgress(false)
            item.isCompleted(true)
            item.progress(100)
            item.download()
          } else if (item.status() == "error" || item.status() == "not_found") {
            item.isProgress(false)
            item.isError(true)
            item.progress(100)
            return;
          } else if (item.status() == "progress") {
            setTimeout(updateStatus, 500)
          } else {
            throw "Unknown status received on exporting: " + item.status()
          }
        }
      })
    }

  }

  return Exporter
})();