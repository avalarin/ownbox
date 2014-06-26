//= require knockout
//= require modules/http
//= require modules/messages
//= require controls/page
//= require controls/datatable
//= require controls/modal
//= require controls/form_modal
//= require controls/browser
//= require typeahead
//= require settings/shares_values

(function() {
  var http = require('http')
  var messages = require('messages')
  var modals = require('messages')
  var $ = require('jquery')

  var page = new Page()
  var datatable = new Datatable(window.urls.shares)
  datatable.delete = function(item) {
    if (confirm(window.localization.confirmDeletion)) {
      http.request({
        url: window.urls.shares,
        type: 'DELETE',
        data: { id: item.id },
        success: function() {
          datatable.refresh()
          messages.warning(window.localization.shareDeleted)
        }
      })
    }
  }

  datatable.edit = function(item){
    editModal.edit(item)
    editModal.show()
  }

  datatable.editSecurity = function(item){
    securityModal.edit(item)
    securityModal.show()
  }

  var editModal = new FormModal($('#edit-modal'), { 
    properties : {
      mode: 'create',
      id: -1,
      name: '',
      path: ''
    },
    onSave: function(data) {
      http.request({
        url: window.urls.shares,
        data: { share: data },
        success: function() {
          datatable.refresh()
          if (editModal.mode() == 'create') {
            messages.success(window.localization.shareCreated)
          } else {
            messages.success(window.localization.shareUpdated)
          }
          editModal.close()
        },
        error: function(status, message, data) {
          if (message == 'validation_error') {
            errors = {}
            for(var key in data) {
              errors['share[' + key + ']'] = data[key][0]
            }
            console.log(errors)
            var validator = editModal.formElement.data('validator')
            validator.showErrors(errors)
          } else {
            http.defaultErrorHandler(status, message, data)
          }
        },
        type: editModal.mode() == 'create' ? 'POST' : 'PATCH'
      })
    }
  }) 
  editModal.getData = function() {
    return {
      id: editModal.id(),
      name: editModal.name,
      path: '/' + editModal.browser.currentItem().path
    }
  }
  editModal.browser = new Browser({ 
    filter: function(item) { return item.type == 'directory' } 
  })
  editModal.browser.goPath('/')
  var oldShow = editModal.show
  var oldReset = editModal.reset
  editModal.show = function() {
    oldShow()
  }
  editModal.reset = function() {
    editModal.browser.goPath('/')
    oldReset()
  }
  editModal.edit = function(item) {
    editModal.mode('edit')
    editModal.name(item.name)
    editModal.browser.goPath(item.path)
    editModal.id(item.id)
  }
  
  var securityModal = new Modal($('#security-modal'))
  securityModal.userNameInput = securityModal.element.find('#user-name')
  inititalizeUsersTypeahead(securityModal.userNameInput)

  securityModal.items = ko.observableArray([])
  securityModal.share = null
  securityModal.reset = function() {
      securityModal.share = null
      securityModal.items.removeAll()
  }
  securityModal.edit = function(share) {
    securityModal.share = share
    http.request({
      url: window.urls.sharePermissions.replace("{shareId}", share.id),
      success: function(data) {
        _.each(data, function(p) {
          securityModal.items.push(wrapSecurityModalItem(p))
        })
        securityModal.element.modal('show')
      }
    })
  }
  securityModal.addUser = function() {
    var userName = securityModal.userNameInput.val()
    if (!userName) return
    http.request({
      url: window.urls.user.replace("{userName}", userName),
      error: function(status, message, data) {
        if (status == 404) {
          alert(window.localization.userNotFound)
        } else {
          http.defaultErrorHandler(status, message, data)
        }
      },
      success: function(user) {
        if (_.find(securityModal.items(), function (u) { return u.name == user.name })) {
          alert(window.localization.itemAlreadyFound)
          return
        }
        securityModal.items.push(wrapSecurityModalItem({user: user, permission: "readonly"}))
        securityModal.userNameInput.val("")
      }
    })
  }
  securityModal.save = function() {
      http.request({
        url: window.urls.sharePermissions.replace("{shareId}", securityModal.share.id),
        type: 'PATCH',
        dataType: 'json',
        contentType: 'application/json',
        data: JSON.stringify({ permissions: _.map(securityModal.items(), function (p) { return { user: p.name, permission: p.mode() } }) }),
        success: function() {
          messages.success(window.localization.permissionsUpdated)
        }
      })
      securityModal.close() 
  }
  function inititalizeUsersTypeahead(input) {
    var usersList = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      limit: 10,
      prefetch: window.urls.users
    })
    usersList.initialize()
    input.typeahead({
        hint: true,
        highlight: true,
        minLength: 1
      },
      { name: 'users',
        displayKey: 'name',
        source: usersList.ttAdapter() 
    })
  }
  function wrapSecurityModalItem(item) {
    return {
      name: item.user.name,
      email: item.user.email,
      displayName: item.user.displayName,
      mode: ko.observable(item.permission),
      switchReadOnly: function() {
        this.mode("readonly")
      },
      switchReadWrite: function() {
        this.mode("readwrite")
      },
      remove: function() {
        securityModal.items.remove(this)
      }
    }
  }


  page.addControl('datatable', datatable)
  page.addControl('editModal', editModal)
  page.addControl('securityModal', securityModal)

  page.attach()
  datatable.refresh()
})()