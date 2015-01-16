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
//
//= require jquery_ujs
//= require jquery.tokeninput
//= require jquery.Jcrop.min
//= require jquery.titlealert
//= require jquery.jplayer.min
//= require jquery.transit
//= require nprogress.js
//= require s3_direct_upload
//= require bootstrap/affix
//= require bootstrap/alert
//= require bootstrap/button
//= require bootstrap/carousel
//= require bootstrap/collapse
//= require bootstrap/dropdown
//= require bootstrap/modal
//= require bootstrap/tooltip
//= require bootstrap/popover
//= require bootstrap/scrollspy
//= require bootstrap/tab
//= require bootstrap/transition
//= require_tree .
$(function() {
  NProgress.start();

    var $plus = $('#plus'),
    $items = $('.item'),
    isExpanded = true,
    coordinates = {
      collapsed: [],
      expanded: []
    },
    radius = 220,
    duration = 300;

  if ($plus.length) {
    $items.each(function(i, el) {
      coordinates.collapsed.push({
        x: $('#frame').height() - $plus.height(),
        y: $plus.width() / 3
      });
      
      coordinates.expanded.push({
        x: -parseInt(radius * Math.cos(((90 / $items.length) * i) * (Math.PI / 180)) + $plus.position().left - $plus.width() / 2, 10) + $plus.position().top,
        y: parseInt(radius * Math.sin(((90 / $items.length) * i) * (Math.PI / 180)) + $plus.position().top + $plus.height() / 2, 10) - $plus.position().top
      });      
    });
     
    $plus.click(function() {
      $plus.toggleClass('open')
           .children()
           .transition({ rotate: !isExpanded ? '0deg' : '135deg' }, duration);
      
      isExpanded = !isExpanded;
      
      $items.each(function(i, el) {
        $(el).transition(
          { top: isExpanded ? coordinates.collapsed[i].x : coordinates.expanded[i].x,
            left: isExpanded ? coordinates.collapsed[i].y : coordinates.expanded[i].y,
            rotate: isExpanded ? '0deg' : '360deg',
            opacity: isExpanded ? 0 : 100 },
          duration + 50 * i,
          isExpanded ? 'easeOutQuint' : 'cubic-bezier(.44, 1.5, .44, 1)'
        )

        if (!isExpanded) {
          $(el).css("z-index", 2001);
        } else {
          $(el).css("z-index", 1999);
        }
      });
    });
  }
});

$(window).load(function() {
  NProgress.done();
});