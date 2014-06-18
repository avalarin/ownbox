//= require knockout
//= require fileapi
//= require modules/http
//= require modules/messages
//= require modules/modals
//= require controls/page
//= require controls/datatable
//= require controls/modal
//= require admin/invites_localization

(function() {

  var invitesPath = '/admin/invites'

  var http = require('http')
  var messages = require('messages')
  var modals = require('modals')

  var page = new Page()
  var datatable = new Datatable(invitesPath + ".json")
  
  datatable.create = function() {
    http.request({
      url: invitesPath + ".json",
      type: "POST",
      success: function(data) {
        datatable.refresh()
        messages.success(window.localization.inviteCreated)
      }
    })
  }

  datatable.delete = function() {
    http.request({
      url: invitesPath + "/" + this.code + ".json",
      type: "DELETE",
      success: function(data) {
        datatable.refresh()
        messages.success(window.localization.inviteDeleted)
      }
    })
  }

  page.addControl('datatable', datatable)

  page.attach()
  datatable.refresh()

})()