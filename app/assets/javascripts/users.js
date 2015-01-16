var AvatarCropper,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

$(function() {
  var $s3uploader = $("#s3-uploader");
  if ($s3uploader.length) {
    $s3uploader.S3Uploader({
      remove_completed_progress_bar: false,
      allow_multiple_files: false,
      progress_bar_target: $('#users_container')
    });

    $s3uploader.bind('s3_upload_failed', function(e, content) {
      return alert(content.filename + ' failed to upload');
    });

    $s3uploader.bind("s3_upload_complete", function(e, content) {
      $('#right_edit').html("<div class='absolute-center' id='gif_loader'><img src='/assets/gif_loader.gif'></div>");
    });
  }
});

AvatarCropper = (function() {

  function AvatarCropper() {
    this.updatePreview = __bind(this.updatePreview, this);

    this.update = __bind(this.update, this);
    $('#cropbox').Jcrop({
      aspectRatio: 1,
      setSelect: [0, 0, 600, 600],
      onSelect: this.update,
      onChange: this.update
    });
  }

  AvatarCropper.prototype.update = function(coords) {
    $('#user_crop_x').val(coords.x);
    $('#user_crop_y').val(coords.y);
    $('#user_crop_w').val(coords.w);
    $('#user_crop_h').val(coords.h);
    return this.updatePreview(coords);
  };

  AvatarCropper.prototype.updatePreview = function(coords) {
    return $('#preview').css({
      width: Math.round(100 / coords.w * $('#cropbox').width()) + 'px',
      height: Math.round(100 / coords.h * $('#cropbox').height()) + 'px',
      marginLeft: '-' + Math.round(100 / coords.w * coords.x) + 'px',
      marginTop: '-' + Math.round(100 / coords.h * coords.y) + 'px'
    });
  };

  return AvatarCropper;

})();