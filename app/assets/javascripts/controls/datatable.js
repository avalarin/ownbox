Datatable = (function() {
  var http = require('http')

  function getVisiblePages(max, current, count) {
    var d = Math.floor(max / 2)
    var minVisiblePage, maxVisiblePage
    if (current - d < 1) {
      minVisiblePage = 1
      maxVisiblePage = Math.min(count, max)
    }
    else if (current + d > count) {
      minVisiblePage = Math.max(1, count - max + 1)
      maxVisiblePage = count
    }
    else {
      minVisiblePage = current - d
      maxVisiblePage = current + d
    }
    return { min: minVisiblePage, max: maxVisiblePage }
  }

  function Datatable(source, options) {
    var sourceUrl = source
    var maxVisiblePagesCount = 5
    var that = this

    options = options || {}

    var wrapItem = options.wrapper || function(item) {
      return item
    }

    var refreshCallback = function(data) {
      this.currentPage(data.page)
      this.pagesCount(data.pages)
      this.allCount(data.count)
      this.perPage(data.perPage)
      this.filter(data.filter || 'all')
      visiblePages = getVisiblePages(maxVisiblePagesCount, this.currentPage, this.pagesCount)
      this.pages.removeAll()
      for (var i = visiblePages.min; i <= visiblePages.max; i++) {
        this.pages.push(i)
      }
      this.items.removeAll()
      for (var i = 0; i < data.items.length; i++) {
        this.items.push(wrapItem(data.items[i]))
      }
    }

    this.items = ko.observableArray([])
    this.currentPage = ko.observable(0)
    this.pagesCount = ko.observable(0)
    this.allCount = ko.observable(0)
    this.perPage = ko.observable(50)
    this.pages = ko.observableArray([])
    this.filter = ko.observable('all')
    this.search = ko.observable('')

    this.refresh = function(options) {
      options = options || {}
      http.request({
        url: sourceUrl,
        data: { 
          page: options['page'] || this.currentPage(),
          per_page: options['perPage'] || this.perPage(),
          filter: options['filter'] || this.filter(),
          search: options['search'] || this.search(),
        },
        success: function(data) { refreshCallback.call(that, data) }
      })
    }

    this.changePage = function(page) {
      this.refresh({ page: page })
    }

    this.changeFilter = function(filter) {
      this.refresh({ filter: filter })
    }

    // this.extend = function(obj) {
    //   for (var key in obj) { if (obj.hasOwnProperty(key)) this[key] = obj[key] }
    //   return this
    // }

  }
  return Datatable
})()