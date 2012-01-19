var DataRetrievalService = {
Models: {}, Collections: {}, Router: {}, Views: {}
};

DataRetrievalService.Models.StatusMessage = Backbone.Model.extend({
  url: '/drs/status.json'
});

DataRetrievalService.Models.Source = Backbone.Model.extend({
  defaults: {
    hub: null,
    hub_name: null,
    nodename: null,
    longitude: null,
    latitude: null,
    netmask: null
  }
});

DataRetrievalService.Collections.Sources = Backbone.Collection.extend({
  model: DataRetrievalService.Models.Source,
  url: '/drs/source.json'
});

DataRetrievalService.Views.SourceList = Backbone.View.extend({
  el: $('#main'),
  initialize: function() {
    this.collection = new DataRetrievalService.Collections.Sources();
  },
  render: function() {
    this.collection.fetch({
      success: _.bind(function(obj, data) {
        this.el.html('<pre>' + JSON.stringify(data, undefined, 4) + '</pre>');
      }, this)
    });
    return this;
  }
});

DataRetrievalService.Views.StatusView = Backbone.View.extend({
  el: $('#main'),
  initialize: function() {
    this.model = new DataRetrievalService.Models.StatusMessage();
    this.model.bind('change', this.render, this);
    _.bindAll(this, 'update');
    this.update();

  },
  render: function() {
    var attr = this.model.toJSON();
    this.el.html('<pre>'+ JSON.stringify(attr, undefined, 4) +'</pre>');
    return this;
  },

  update: function() {
    this.model.fetch({ success: _.bind(function() {
      setTimeout(this.update, 10000);
    }, this)});  
  }
});
    
DataRetrievalService.Router = Backbone.Router.extend({
  routes: {
    ""        : "index",
    "status"  : "status_page",
    "sources" : "sources",
    "query"   : "query"
  },

  index: function() {
    $('#main').html('home');
    // Yes! We have Drupal's cookies.
    //console.log(document.cookie.split(';'));
  },

  status_page: function() {
    var status_view = new DataRetrievalService.Views.StatusView();
    status_view.render();
  },
  
  sources: function() {
    var sources = new DataRetrievalService.Views.SourceList;
    sources.render();
  },

  query: function() {
    $('#main').html('query'); 
  }

});

var app = new DataRetrievalService.Router();
Backbone.history.start();

(function($) {

function Resize() {
  var header_height = $('#header').height(),
      window_height = $(window).height();
  $('body').css({
    'overflow' : 'hidden',
    'height' : window_height +'px'
  });
  $('#main-wrapper').css({
    'height' : window_height - header_height +'px',
    'top' : header_height +'px',
    'width' : $(window).width()
  });
}

//Resize();

$(window).on("load resize", function(e) {
    Resize();
  }
);

})(jQuery);
