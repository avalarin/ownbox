//= require knockout
//= require modules/http

Browser = (function() {
  var http = require('http')

  function Browser(options) {
    var browser = this
    options = options || {}
    var filter = options.filter || function(item) { return true }

    browser.items = ko.observableArray([])
    browser.selected = ko.observableArray([])
    browser.path = ko.observableArray([])
    browser.currentItem = ko.observable(BrowserItem.empty)
    browser.isLoading = ko.observable(false)

    browser.refresh = function() {
      browser.go(browser.currentItem())
    }

    browser.go = function(item) {
      if (!item) {
        if (typeof (this) == 'BrowserItem') {
          item = this
        } else {
          throw "item required"
        }
      }
      browser.goUrl(item.url)
    }

    browser.goPath = function(path) {
      if (path[0] == '/') path = path.substr(1)
      var url = Browser.baseUrl + '/' + path
      browser.goUrl(url)
    }

    browser.goUrl = function(url) {
      browser.isLoading(true)
      http.request({
        url: url,
        success: function(data) {
          browser.items.removeAll()
          browser.selected.removeAll()
          var items = data.items
          for (var i = 0; i < items.length; i++) {
            var item = BrowserItem.wrap(items[i])
            if (!filter(item)) continue
            browser.items.push(item)
          }
          browser.path.removeAll()
          var path = data.path
          for (var i = 0; i < path.length; i++) {
            browser.path.push(BrowserItem.wrap(path[i]))
          }
          currentItem = BrowserItem.wrap(data.currentItem)
          // if (currentItem.url != history.state.url) {
          //   history.pushState(currentItem.historyState, currentItem.name, currentItem.url)
          // }
          // $('title').text(currentItem.name)
          browser.currentItem(currentItem)
          browser.isLoading(false)
        }
      })
    }

    // selection
    browser.unselectAll = function() {
      var items = browser.items()
      for (var i = 0; i < browser.items().length; i++) {
        unselectItem(items[i])
      }
    }

    browser.selectUnselect = function(item, event) {
      if (event.shiftKey) {
        if (typeof(browser.lastSelectId) !== "undefined" && browser.lastSelectId != null) {
          browser.unselectAll()
          var currentIndex = browser.items.indexOf(this)
          var min = Math.min(browser.lastSelectId, currentIndex)
          var max = Math.max(browser.lastSelectId, currentIndex)
          var localItems = browser.items()
          for (var i = min; i <= max; i++) {
            selectItem(localItems[i])
          }
          return
        }
      }
      if (event.ctrlKey) {
        browser.lastSelectId = this.selectUnselect() ? browser.items.indexOf(this) : null
      } else {
        var selected = this.isSelected()
        browser.unselectAll()
        if (!selected) {
          this.select()
          browser.lastSelectId = browser.items.indexOf(this)
        } else {
          browser.lastSelectId = null
        }
      }
    }

    function unselectItem(item) {
      if (item.selected()) {
        browser.selected.remove(item)
        item.selected(false)
      }
    }

    function selectItem(item) {
      if (!item.selected()) {
        browser.selected.push(item)
        item.selected(true)
      }
    }

    function selectUnselectItem(item) {
      if (item.selected()) {
        unselectItem(item)
        return false
      } else {
        selectItem(item)
        return true
      }
    }

  }

  Browser.baseUrl = '/home'
  return Browser
})()

BrowserItem = (function() {
  function BrowserItem(options) {
    this.path = options.path
    this.name = options.name
    this.size = options.size
    this.url = options.url

    this.historyState = options
    this.owner = options.owner
    this.previewUrl = options.preview_url
    this.type = options.type
    this.permission = options.permission
    this.humanSize = options.human_size
    this.directoryType = options.directory_type

    this.selected = ko.observable(false)
  }

  BrowserItem.wrap = function(item) {
    return new BrowserItem(item)
  }

  BrowserItem.empty = new BrowserItem({
    name: '',
    size: 0,
    path: '/',
    url: Browser.baseUrl
  })

  return BrowserItem
})();