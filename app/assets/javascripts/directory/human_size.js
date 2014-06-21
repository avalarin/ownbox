window.humanSize = (function() {
  var units = { ru : ['байт', 'КБ', 'МБ', 'ГБ', 'ТБ'] }
  var language = 'ru'
  var base = 1024

  function exponent(number) {
    var max = units[language].length - 1
    var exp = Math.log(number) / Math.log(base)
    if (exp > max) exp = max 
    return exp
  }

  function format(number, u) {
    return number.toFixed(2) + " " + units[language][u]
  }

  return function(number) {
    var formatted = 0;
    if (number < base){
      return format(number, 0)
    }
    else {
      var e = Math.floor(exponent(number))
      formatted = number / Math.pow(base, e)
      return format(formatted, Math.floor(e))
    }
  }
})()