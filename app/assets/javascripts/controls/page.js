Page = (function() {
  function Page() {
    this.controls = { }
  }

  Page.prototype.addControl = function(name, control) {
    this.controls[name] = control
  }

  Page.prototype.attach = function() {
    ko.applyBindings(this.controls)
  }

  return Page
})()