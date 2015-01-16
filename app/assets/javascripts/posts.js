$(function() {
  var $uploader = $("#post-s3-uploader");
  var $side_chat = $('.side-chat');
  var $post_tessles = $('#post_tessles');
  var $post_url = $("#post_url");
  var $show_mid_span = $('#show-mid-span');
  var $current_users = $('#current-users');
  var $stats_box = $('#stats-box');
  var $new_post = $('#new_post');

  if($new_post.length) {
    $new_post.bind('keydown', function(e) {
      var code = e.keyCode || e.which; 
      if (code == 13) {               
        e.preventDefault();
        return false;
      }
    });
  }

  if($uploader.length) {
    $uploader.S3Uploader({
      remove_completed_progress_bar: false,
      allow_multiple_files: false,
      progress_bar_target: $('#posts_container')
    });

    $uploader.bind('s3_upload_failed', function(e, content) {
      return alert(content.filename + ' failed to upload');
    });

    $uploader.bind("s3_upload_complete", function(e, content) {
      var remote = $('#post_direct_upload_url');
      remote.val(content.url);
      $('#post_url').val(content.url);
      $("#preview_img").html("<label>Thumbnail Preview</label><img id='inner_preview_img' style='margin-bottom: 10px;'>");
      $('#inner_preview_img').attr('src', content.url);
    });
  }

  if($post_tessles.length) {
    $post_tessles.tokenInput("/posts/tags.json", {
      theme: 'facebook',
      prePopulate: $post_tessles.data('load'),
      noResultsText: "No results press enter to create new tag.",
      animateDropdown: false,
      hintText: "Type up to 5 tags.",
      tokenLimit: 5
    });    
  }

  if($post_url.length) {
    $post_url.bind('paste', function(e) {
      var el = $(this);
      setTimeout(function() {
        var text = $(el).val();
        // console.log(text);
        $.ajax('/posts/preview', {
          type: 'POST',
          data: { url: text },
          success: function(data, textStatus, jqXHR ) {
            // handle received data
            $("#post_title").val(data['title']);

            if(data['image_url'] != '') {
              $("#preview_img").html("<label>Thumbnail Preview</label><img src='" + data['image_url'] + "' style='margin-bottom: 10px;'>");
              $("#post_remote_image_url").val(data['image_url']);
              $("#post_image").hide();
            }

            $("#post_description").val(data['description']);
          },
          error: function() { alert("Please enter a valid URL."); }
        });

      }, 100);
    });
  }


  //Maybe make this a function call
  if($("#top_chats").length) {
    var total_likes = 0;
    $.each($("#top_chats li div span"), function () {
      total_likes += parseInt($(this).text());
    });

    $.each($("#top_chats li div span"), function () {
      var likes = parseInt($(this).text());
      $(this).parent().parent().parent().css("width", (likes/total_likes * 100) + "%");
    });
  }
  
  if($stats_box.length){
    $stats_box.css('width', $show_mid_span.width());
  }

  if($current_users.length) {
    $current_users.css('width', $show_mid_span.width());
  }
  
  

  if($side_chat.length) {
    $side_chat.css('height', $(window).height() - 100);
    $side_chat.css('width', $('#side-span').width());
    $('#side-chat-body').css('height', $side_chat.height() - 103);
  }


});
