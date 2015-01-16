$(function() {
  // This is the show more posts functionality
  if ($('.pagination').length) {
    $('#append_and_paginate').prepend('<a id="append_more_results" href="javascript:void(0);">Show more posts</a>');
    return $('#append_more_results').click(function() {
      var url;
      url = $('.pagination .next_page a').attr('href');
      if (url) {
        $('.pagination').text('Fetching more posts...');
        return $.getScript(url);
      }
    });
  }

  //Add more here
});
