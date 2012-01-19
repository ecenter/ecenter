var DataRetrievalService = {
Models: {}, Collections: {}, Router: {}, Views: {}
};

DataRetrievalService.Models.StatusMessage = Backbone.Model.extend({
  url: '/drs-status/status.json'
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
   
    this.chart = d3.select("#main").append("svg")
      .attr("class", "chart")

    this.chart.w = 14,
    this.chart.h = 100;
    
    this.chart
      .attr("width", this.chart.w * 80)
      .attr("height", this.chart.h);
    
    this.chart.x = d3.scale.linear()
        .domain([0, 1])
        .range([0, this.chart.w]);
   
    this.chart.y = d3.scale.linear()
        .domain([0, 28])
        .rangeRound([0, this.chart.h]); 
  
    this.chart.data = [];
  },
  render: function() {
    var gearman = this.model.get('gearman') || null;
    return this;
  },

  update: function() {
    this.model.fetch({ success: _.bind(function(obj, data) {
      setTimeout(this.update, 3000);
      var now = new Date();
      var time = now.getTime() / 1000;
      console.log(data['gearman']['drs']['xenmon.fnal.gov']['10121']['dispatch_data']['running']);
      this.chart.data.push({'time' : time, 'value' : data['gearman']['drs']['xenmon.fnal.gov']['10121']['dispatch_data']['running']});
      /*[
        {'time' : time, 'value' : data['gearman']['drs']['xenmon.fnal.gov']['10121']['dispatch_data']['available']},
        {'time' : time, 'value' : data['gearman']['drs']['xenmon.fnal.gov']['10121']['dispatch_data']['running']},
        {'time' : time, 'value' : data['gearman']['drs']['xenmon.fnal.gov']['10121']['dispatch_data']['queued']},
      ]);*/
      var rect = this.chart.selectAll("rect")
        .data(this.chart.data, function(d) { return d.time; });
   
      rect.enter().insert("rect", "line")
        .attr("x", _.bind(function(d, i) { return this.x(i + 1) - .5; }, this.chart))
        .attr("y", _.bind(function(d) { return this.h - this.y(d.value) - .5; }, this.chart))
        .attr("width", this.chart.w)
        .attr("height", _.bind(function(d) { return this.y(d.value); }, this.chart))
      .transition()
        .duration(500)
        .attr("x", _.bind(function(d, i) { return this.x(i) - .25; }, this.chart));
      
      rect.transition()
       .duration(500)
       .attr("x", _.bind(function(d, i) { return this.x(i) - .25; }, this.chart));

      rect.exit().transition()
        .duration(500)
        .attr("x", _.bind(function(d, i) { return this.x(i - 1) - .25; }, this.chart))
        .remove();

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
    sources.collection.fetch({success: function() {
      sources.render();
    }});
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
