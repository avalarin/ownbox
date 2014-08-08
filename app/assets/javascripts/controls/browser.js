//= require knockout
//= require modules/http
//= require modules/messages
//= require utils/human_size
//= require controls/browser_values

Browser = (function() {
  var http = require('http')
  var messages = require('messages')

  function Browser(options) {
    var browser = this
    options = options || {}
    var filter = options.filter || function(item) { return true }
    var changeHistory = options.history == true

    if (typeof UploaderModal !== 'undefined') {
      browser.uploaderModal = new UploaderModal({
        onUpload: function(files) {
          _.each(files, uploadFile)
        }
      })
    }
   
    if (typeof ImageViewer !== 'undefined') {
      browser.imageViewer = new ImageViewer($('#image-viewer-modal'))
    }

    browser.currentItem = ko.observable(BrowserItem.empty)
    browser.items = ko.observableArray([])
    browser.path = ko.observableArray([])
    browser.selected = ko.observableArray([])

    this.stat = {
      allHumanSize : ko.observable(''),
      allSize : ko.observable(0),
      allCount : ko.observable(''),
      allHumanCount : ko.observable('')
    }
    
    browser.editable = ko.observable(options.hasOwnProperty('editable') ? options['editable'] : true)
    browser.isLoading = ko.observable(false)

    this.uploadingFiles = ko.observableArray([])

    if (changeHistory) {
      window.history.replaceState(currentItem, currentItem.name)
      window.onpopstate = function() { browser.go(history.state); }
    }

    browser.refresh = function() {
      browser.go(browser.currentItem())
    }

    browser.go = function(item, event) {
      if (event) event.stopPropagation();
      if (!item) {
        if (typeof (this) == 'BrowserItem') {
          item = this
        } else {
          throw "item required"
        }
      }

      if (item.type != 'directory') {
        if (item.type == 'image') {
          var imageItems = _.filter(browser.items(), function (file) {
            return file.type == 'image'
          })
          browser.imageViewer.setItems(imageItems)
          var index = imageItems.indexOf(item)
          browser.imageViewer.show(index)
          return
        } else {
          return browser.goFile(item)
        }
      }

      browser.browseUrl(item.url)
    }

    browser.browsePath = function(path) {
      if (path[0] == '/') path = path.substr(1)
      var url = Browser.baseUrl + '/' + path
      browser.browseUrl(url)
    }

    browser.browseUrl = function(url) {
      browser.isLoading(true)
      http.request({
        url: url,
        success: function(data) {
          browser.isLoading(false)
          browser.items.removeAll()
          browser.selected.removeAll()
          var items = _.filter(_.map(data.items, BrowserItem.wrap), filter)

          var oneCount = 50
          var oneTimeout = 100
          for (var i = 0; i < Math.ceil(items.length / oneCount); i++) {
            var f = function() {
              for (var z = i * oneCount; z < Math.min(items.length, (i + 1) * oneCount); z++) {
                browser.items.push(items[z])
              }
            }
            var timeout = oneTimeout * i;
            if (timeout > 0) {
              setTimeout(f, timeout)
            } else {
              f()
            }
          }


          browser.path.removeAll()
          var path = data.path
          for (var i = 0; i < path.length; i++) {
            browser.path.push(BrowserItem.wrap(path[i]))
          }
          currentItem = BrowserItem.wrap(data.currentItem)
          if (changeHistory){
            if (currentItem.url != history.state.url) {
              history.pushState(currentItem.historyState, currentItem.name, currentItem.url)
            }
            $('title').text(currentItem.name)
          }
          browser.stat.allSize(data.stat.allSize)
          browser.stat.allHumanSize(data.stat.allHumanSize)
          browser.stat.allHumanCount(data.stat.allHumanCount)
          browser.stat.allCount(data.stat.allCount)
          browser.currentItem(currentItem)
        }
      })
    }

    // directory creating
    this.canCreateDir = ko.observable(true)
    this.createDir = function(data, event) {
      browser.canCreateDir(false)
      var newDirectory = $('#new-directory')
      var input = newDirectory.find('input[name=name]')
      newDirectory.removeClass('hidden')
      var validate = function() {
        var value = input.val()
        if (value.trim() == '') {
          messages.danger(window.localization.directoryNameCannotBeEmpty)
          return false
        }
        return true
      }
      var save = function () {
        if (!validate()) return
        http.request({
          url: '/directory/create',
          type: 'POST',
          data: {
            user_name: browser.currentItem().owner,
            path: browser.currentItem().path,
            name: input.val()
          },
          success: function() {
            browser.refresh()
            messages.success(window.localization.directoryCreated)
          }
        })
        close()
      }
      var close = function () {
        input.val('')
        newDirectory.addClass('hidden')
        input.off('.createdir')
        browser.canCreateDir(true)
      }
      input.on('keyup.createdir', function (e) {
        var code = e.keyCode || e.which
        if(code == 13) {
          save()
        } else if (code == 27) {
          close()
        }
      }).on('blur.createdir', function (e) {
        if (input.val().trim() == '') {
          close()
        } else {
          save()
        }
      })
      input.focus()
    }    

    this.upload = function () {
      browser.uploaderModal.show()
    }

    function uploadFile(file) {
      var uploadingFile = {
        name: file.name,
        size: file.size,
        humanSize: window.humanSize(file.size),
        type: file,
        uploaded: ko.observable(0),
        uploadedPercentage: ko.observable(0),
        isError: ko.observable(false),
        delete: function() {
          browser.uploadingFiles.remove(this)
          if (this.xhr && this.xhr.readystate != 4) {
              this.xhr.abort();
          }
        }
      }
      browser.uploadingFiles.push(uploadingFile)
      uploadingFile.xhr = FileAPI.upload({
        url: '/file/upload',
        files: { file: file.original },
        data: {
          path: browser.currentItem().path,
          user_name: browser.currentItem().owner,
        },
        headers: {
          "X-CSRF-Token": $('meta[name=csrf-token]').attr('content')
        },
        progress: function (evt){
          uploadingFile.uploaded(evt.loaded)
          uploadingFile.uploadedPercentage(Math.ceil(evt.loaded/evt.total*100))
        },
        complete: function (err, xhr) {
          if (err) {
            uploadingFile.isError(true)
          } else {
            browser.uploadingFiles.remove(uploadingFile)
            if (browser.uploadingFiles().length == 0) browser.refresh()
          }
        }
      })
    }

    // deletion
    this.deleteItem = function(data, event) {
      var selected = _.clone(browser.selected());
      if (confirm(window.localization.confirmDeletion)) {
        http.request({
          url: '/directory/destroy',
          type: 'POST',
          data: {
            user_name: browser.currentItem().owner,
            path: browser.currentItem().path,
            name: _.map(selected, function(item) { return item.name; }).join('|')
          },
          success: function() {
            browser.refresh()
            messages.warning(window.localization.itemDeleted)
          }
        })
      }
      browser.unselectAll()
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
        browser.lastSelectId = selectUnselectItem(this) ? browser.items.indexOf(this) : null
      } else {
        var selected = this.isSelected()
        browser.unselectAll()
        if (!selected) {
          selectItem(item)
          browser.lastSelectId = browser.items.indexOf(this)
        } else {
          browser.lastSelectId = null
        }
      }
    }

    function unselectItem(item) {
      if (item.isSelected()) {
        browser.selected.remove(item)
        item.isSelected(false)
      }
    }

    function selectItem(item) {
      if (!item.isSelected()) {
        browser.selected.push(item)
        item.isSelected(true)
      }
    }

    function selectUnselectItem(item) {
      if (item.isSelected()) {
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
    this.humanSize = options.human_size,
    this.shared = options.shared,

    this.isSelected = ko.observable(false)
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