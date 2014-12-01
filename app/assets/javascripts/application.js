// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.timepicker.min.js
//= require bootstrap.js.coffee
//= require fullcalendar.js
//= require gcal.js
//= require modernizr.js
//= require angular.min.js
//= require angular-resource.min.js
//= require schedulerApp.js
//= require resources.js
//= require controllers.js
//= require services.js
//= require_self

(function( $ ) {
  $.widget( "custom.combobox", {
    _create: function() {
      this._customOnSelect = this.options.custom_on_select;
      this._textPlaceholder = this.options.text_placeholder;
      this.list = this.options.list;
      this.parent_div = this.options.parent_div;
      this.parent_div.prepend(this.wrapper);
      this.input = this.options.input;
      this.element.hide();
      this._createAutocomplete();
      this._createShowAllButton();
      this.parent_div.prepend(this.input);
    },
    _createAutocomplete: function() {
      var selected = this.element.children( ":selected" );
      var value = selected.val() ? selected.text() : "";
      var itemList = this.list;
      
      this.input.val( value ).autocomplete({
          delay: 0,
          minLength: 0,
          source: $.proxy( this, "_source" )
        });
      this._on( this.input, {
        autocompleteselect: function( event, ui ) {
          if (this._customOnSelect != null) {
            this._customOnSelect(ui.item.option);
          } else {
            this.list.val(ui.item.option.value);
          }
          this.parent_div.children("span.input-group-btn").children("button").focus();
        },
        blur: function() {
          this.input.val(this.list.find(":selected").text());
        }
      });
    },

    _createShowAllButton: function() {
      var input = this.input, wasOpen = false;
      this.parent_div.children("span.input-group-btn").children("button").click(function() {
        if ( wasOpen ) { return; }
        input.autocomplete( "search", "" );
      });
      this.parent_div.children("span.input-group-btn").children("button").blur(function() {
        input.blur();
      });
    },

    _source: function( request, response ) {
      var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
      response( this.element.children( "option" ).map(function() {
        var text = $( this ).text();
        if ( this.value && ( !request.term || matcher.test(text) ) )
          return {
            label: text,
            value: text,
            option: this
          };
      }) );
    },

    _removeIfInvalid: function( event, ui ) {

      // Selected an item, nothing to do
      if ( ui.item ) {
        return;
      }

      // Search for a match (case-insensitive)
      var value = this.input.val(),
        valueLowerCase = value.toLowerCase(),
        valid = false;
      this.element.children( "option" ).each(function() {
        if ( $( this ).text().toLowerCase() === valueLowerCase ) {
          this.selected = valid = true;
          return false;
        }
      });

      // Found a match, nothing to do
      if ( valid ) {
        return;
      }

      // Remove invalid value
      this.input
        .val( "" )
        .attr( "title", value + " didn't match any item" )
        .tooltip( "open" );
      this.element.val( "" );
      this._delay(function() {
        this.input.tooltip( "close" ).attr( "title", "" );
      }, 2500 );
      this.input.data( "ui-autocomplete" ).term = "";
    },

    _destroy: function() {
      this.wrapper.remove();
      this.element.show();
    }
  });
  
  Array.prototype.unique = function () {
      var arr = this;
      return $.grep(arr, function (v, i) {
          return $.inArray(v, arr) === i;
      });
  }
})( jQuery );

$(document).ready(function() {
  if (!Modernizr.input.placeholder) {
    $("input").each(function() {
      if ($(this).val() == "" && $(this).attr("placeholder") != "") {
        $(this).val($(this).attr("placeholder"));
        $(this).focus(function() {
          if($(this).val() == $(this).attr("placeholder"))
            $(this).val("");
        });
        $(this).blur(function() {
          if($(this).val()=="") $(this).val($(this).attr("placeholder"));
        });
      }
    });
    
    $("textarea").each(function() {
      if ($(this).val() == "" && $(this).attr("placeholder") != "") {
        $(this).val($(this).attr("placeholder"));
        $(this).focus(function() {
          if($(this).val() == $(this).attr("placeholder"))
            $(this).val("");
        });
        $(this).blur(function() {
          if($(this).val()=="") $(this).val($(this).attr("placeholder"));
        });
      }
    });
  }
});
