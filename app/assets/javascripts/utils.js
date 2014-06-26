(function() {
  
  window.extend = function(target, base) {
    for (var p in base) {
      if (!base.hasOwnProperty(p)) continue;
      target[p] = base[p]
    }
    target.__base = base
  }

})()