//= require knockout
//= require modules/http
//= require modules/messages
//= require modules/modals
//= require controls/page
//= require registration_values

$(function() {
  var http = require('http')
  var messages = require('messages')
  var page = new Page()
  
  $('form').validate({
        ignore: [],
        // any other options and/or rules
  });

  var form = (function() {
    return {
      invite: ko.observable(''),
      name: ko.observable(''),
      displayName: ko.observable(''),
      email: ko.observable(''),
      password: ko.observable(''),

      inviteRequired: ko.observable(window.values.inviteRequired),
      inviteProvided: ko.observable(false),

      submit: function() {
        if (this.inviteProvided()) {
          this.register()
        } else {
          this.checkInvite()
        }
        return false
      },

      checkInvite: function() {
        if (!$('form #invite').valid()) return false;
        var that = this
        http.request({
          url: window.urls.checkInvite + this.invite(),
          type: 'POST',
          success: function() {
            that.inviteProvided(true)
          }, 
          error: function() {
            var validator = $("form").data('validator')
            validator.showErrors({invite : window.localization.invalidInvite})
          }
        })
      },
      back: function() {
        this.inviteProvided(false)
      },
      register: function() {
        if (!$('form').valid()) return false;
        var that = this
        http.request({
          url: window.urls.register + '.json',
          type: 'POST',
          data: {
            invite: this.invite(),
            user: {
              name: this.name(), display_name: this.displayName(), email: this.email(), password: this.password()
            }
          },
          success: function() {
            location.href = window.urls.successRegistration
          }, 
          error: function(status, message, data) {
            if (message == 'validation_error') {
              errors = {}
              for(var key in data) {
                errors['user[' + key + ']'] = data[key][0]
              }
              var validator = $("form").data('validator')
              validator.showErrors(errors)
            }
            else {
              http.defaultErrorHandler(status, message, data)
            }
          }
        })
      }

    }
  })()

  page.addControl('form', form)
  page.attach()

})