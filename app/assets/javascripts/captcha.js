//= require modules/http

window.captcha = (function() {
  var http = require('http')

  function generateNew(callback) {
    http.request({
      url: '/captcha/new',
      type: 'POST',
      success: callback
    })
  }

  function update(elements) {
    if (!elements) elements = $('.captcha')
    elements.each(function(i, element) {
      var block = $(element)
      var image = block.find('img')
      var codeInput = block.find('.captcha-code')
      var valueInput = block.find('.captcha-value')
      valueInput.val('');
      block.addClass('loading')
      captcha.generateNew(function(newCaptcha) {
        image.attr('src', newCaptcha.url)
        codeInput.val(newCaptcha.code)
        block.removeClass('loading')
      })
    })
  }

  function get(element) {
    if (!element) element = $('.captcha')[0]
    block = $(element)
    if (!block.length) return null
    var codeInput = block.find('.captcha-code')
    var valueInput = block.find('.captcha-value')
    return { code: codeInput.val(), value: valueInput.val() }
  }

  function check(code, value, callback) {
    http.request({
      url: '/captcha/new',
      type: 'POST',
      contentType: 'application/json',
      data: { code: code, value: value },
      success: function() {
        callback(true)
      },
      error: function(status, message, data) {
        if (message == 'invalid_captcha') {
          callback(false)
        } else {
          http.defaultErrorHandler(status, message, data)
        }
      }
    })
  }

  return {
    generateNew: generateNew,
    check: check,
    update: update,
    get: get
  }

})()

$(function() {
  $(document).on('click', '.captcha > img', function() {
    window.captcha.update($(this).closest('.captcha'))
  })
})