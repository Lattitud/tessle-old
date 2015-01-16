var bindChatForm = function(messageable_id, messageable_type) {
  var message_content = $('#' + messageable_type + '_message_content' + messageable_id);
  var send_button = $('#' + messageable_type + '_send_button' + messageable_id);
  var new_message = $('#new_' + messageable_type + '_message' + messageable_id);

  message_content.keypress(function (e) {
    send_button.css("background-position", "0 -295px");
    if (e.which == 13 && e.shiftKey){
      var content = this.value;
      var caret = getCaret(this);
      this.value = content.substring(0,caret)+"\n"+content.substring(caret,content.length);
      e.stopPropagation();
    }
    else if(e.which == 13 && !e.shiftKey) {
      e.preventDefault();
      if (this.value == "") {

      }
      else {
        new_message.submit();
      }
    }
  });

  message_content.focus();
}

var bindChatDock = function(messageable_id, messageable_type, presence_suffix) {
  var post_chat = $('#' + messageable_type + '_chat' + messageable_id);
  var message_content = $('#' + messageable_type + '_message_content' + messageable_id);

  var chat_li_post;
  if (messageable_type == 'post') {
    chat_li_post = $('#chat_li_' + messageable_type + '_' + messageable_id);
  }
  else if (messageable_type == 'private'){
    chat_li_post = $('#chat_li_' + messageable_type + '-' + messageable_id);
  }
  else {
    chat_li_post = $('#chat_li_' + messageable_type + '=' + messageable_id);
  }

  message_content.keyup(function (e) {
    if (e.which == 27){
      post_chat.hide();
      chat_li_post.css('width', '190px');
    }
  });


  $("#close_" + messageable_type + '_chat' + messageable_id).bind('click', function () {
    socket.unsubscribe('presence-' + messageable_type + '-' + presence_suffix);
  });

  $("#destroy_" + messageable_type + '_chat' + messageable_id).bind('click', function () {
    socket.unsubscribe('presence-' + messageable_type + '-' + presence_suffix);
  });

  $("#hide_" + messageable_type + '_chat' + messageable_id).bind('click', function () {
    post_chat.hide();
    chat_li_post.css('width', '190px');
  });

  $("#show_" + messageable_type + '_chat' + messageable_id).bind('click', function () {
    post_chat.show();
    chat_li_post.css('width', '325px');
  });
}