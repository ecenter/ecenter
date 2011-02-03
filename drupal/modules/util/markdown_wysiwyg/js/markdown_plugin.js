/**
 * @file markdown_plugin.js
 *
 * @TODO relies too much on hardcoded values from
 * Drupal integration -- make more configurable.
 */

(function() {
  tinymce.create('tinymce.plugins.MarkdownPlugin', {
    init : function(ed, url) {
      var t = this;

      ed.onBeforeSetContent.add(function(ed, o) {
        o.content = t._markdown2html(o.content);
      });

      ed.onPostProcess.add(function(ed, o) {
        if (o.set) {
          o.content = t._markdown2html(o.content);
        }

        if (o.get) {
          o.content = t._html2markdown(o.content);
        }
      });
    },

    getInfo : function() {
      return {
        longname : 'Markdown Plugin',
        author : 'David Eads',
        authorurl : 'http://fnal.gov',
        infourl : '',
        version : tinymce.majorVersion + "." + tinymce.minorVersion
      };
    },

    // Private methods

    _html2markdown : function(s) {
      s = tinymce.trim(s);

      $.ajax({
        url: Drupal.settings.basePath + 'html2markdown',
        data: {input: s, token: Drupal.settings.markdownWysiwygToken},
        type: 'POST',
        dataType: 'json',
        async: false,
        success: function(response) {
          s = response.output;
        },
        error: function(request) {
          s = Drupal.ahahError(request, this.url);
        }
      });

      return s;
    },

    _markdown2html : function(s) {
      s = tinymce.trim(s);
      $.ajax({
        url: Drupal.settings.basePath + 'markdown2html',
        data: {input: s, token: Drupal.settings.markdownWysiwygToken},
        type: 'POST',
        dataType: 'json',
        async: false,
        success: function(response) {
          s = response.output;
        },
        error: function(request) {
          s = Drupal.ahahError(request, this.url);
        }
      });

      return s;
    }
  });

  // Register plugin
  tinymce.PluginManager.add('markdown', tinymce.plugins.MarkdownPlugin);
})();
