//= require knockout
//= require fileapi
//= require modules/http
//= require modules/messages
//= require controls/page
//= require controls/datatable
//= require controls/modal
//= require admin/users_localization

(function() {

  var usersPath = '/admin/users'
  var http = require('http')
  var messages = require('messages')
  var page = new Page()
  var datatable = new Datatable(usersPath + ".json")
  var createModal = new Modal($('#create-modal'))

  datatable.sendActivationEmail = function(){
    http.request({
      url: usersPath + "/" + this.name + "/send_email.json",
      success: function() {
        datatable.refresh()
        messages.success(window.localization.activationEmailSended)
      },
      type: 'POST'
    })
  }

  datatable.lockUser = function(){
    http.request({
      url: usersPath + "/" + this.name + ".json",
      data: { user: { locked: true } },
      success: function() {
        datatable.refresh()
        messages.danger(window.localization.userLocked)
      },
      type: 'PATCH'
    })
  }

  datatable.unlockUser = function(){
    http.request({
      url: usersPath + "/" + this.name + ".json",
      data: { user: { locked: false } },
      success: function() {
        datatable.refresh()
        messages.success(window.localization.userUnlocked)
      },
      type: 'PATCH'
    })
  }

  createModal.formElement = createModal.element.find('form')
  createModal.name = ko.observable('')
  createModal.displayName = ko.observable('')
  createModal.email = ko.observable('')
  createModal.password = ko.observable('')
  createModal.passwordConfirmation = ko.observable('')
  createModal.reset = function() {
    createModal.name('')
    createModal.displayName('')
    createModal.email('')
    createModal.password('')
    createModal.passwordConfirmation('')
    createModal.formElement[0].reset()
  }
  createModal.reset()
  createModal.valid = function() {
    return this.formElement.valid()
  }
  createModal.getData = function() {
    return this.formElement.serialize()
  }
  createModal.save = function() {
    if (!this.valid()) return
    var data = this.getData()
    http.request({
      url: usersPath + ".json",
      data: data,
      success: function() {
        datatable.refresh()
      },
      type: 'POST'
    })
    this.close()
  }

  page.addControl('datatable', datatable)
  page.addControl('createModal', createModal)

  page.attach()
  datatable.refresh()

})()