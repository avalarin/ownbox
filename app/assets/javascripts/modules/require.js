(function () {
  
  var definedModules = {};
  var initializedModules = {};

  function require(name, func) {
    
    if(Object.prototype.toString.call(name) === '[object Array]' ) {
      var deps = [];
      for (var i = 0; i < name.length; i++) {
        deps.push(get(name[i]));
      }
      if (func) {
        func.apply(null, deps);  
      }
      return deps;
    } else {
      var dep = get(name);
      if (func) {
        func.apply(null, [ dep ]);  
      }
      return dep;
    } 
  }

  function define(name, dep, func) {
    if (defined(name)) throw "Module " + name + " already defined.";
    if (typeof (dep) == "function") {
      func = dep;
    } else {
      var ofunc = func;
      func = function () {
        var resolvedDep = require(dep);
        return ofunc.apply(null, resolvedDep);
      }
    }
    definedModules[name] = func;
  }

  function defined(name) {
    return !!definedModules[name]
  }

  function get(name) {
    if (!defined(name)) throw "Module " + name + " not defined.";
    var i = initializedModules[name];
    if (!i) i = initializedModules[name] = definedModules[name]();
    return i;
  }

  window.require = require;
  window.define = define;

})();