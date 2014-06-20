//= require knockout
//= require modules/http
//= require modules/messages
//= require modules/modals
//= require controls/page
//= require registration_values
//= require captcha

$(function() {
  var http = require('http')
  var messages = require('messages')
  var page = new Page()
  var currentCaptcha = null

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
      updateValidation: function() {
        $('form').data('validator', null)
        $.validator.unobtrusive.parse(document)
      },
      checkInvite: function() {
        if (!$('form #invite, form .captcha-value').valid()) return false;
        var that = this
        http.request({
          url: window.urls.checkInvite,
          data: { invite: this.invite(), captcha: window.captcha.get() },
          type: 'POST',
          success: function() {
            currentCaptcha = window.captcha.get()
            that.inviteProvided(true)
          }, 
          error: function(status, message, data) {
            var validator = $("form").data('validator')
            if (message == 'invalid_captcha') {
              validator.showErrors({"captcha[value]": window.localization.invalidCaptcha})
            } else if (message == 'invalid_invite') {
              validator.showErrors({invite: window.localization.invalidInvite})
            } else {
              http.defaultErrorHandler(status, message, data)
            }
            window.captcha.update()
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
            captcha: window.captcha.get() || currentCaptcha,
            user: {
              name: this.name(), display_name: this.displayName(), email: this.email(), password: this.password()
            }
          },
          success: function() {
            location.href = window.urls.successRegistration
          }, 
          error: function(status, message, data) {
            if (message == 'invalid_captcha') {
              if (that.inviteRequired()) that.inviteProvided(false)
              validator.showErrors({"captcha[value]": window.localization.invalidCaptcha})
            } else if (message == 'invalid_invite') {
              that.inviteProvided(false)
              validator.showErrors({invite: window.localization.invalidInvite})
            } else if (message == 'validation_error') {
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