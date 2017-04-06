// TODO: make this take a form element name and just submit that
//       single thing instead of the whole form.
function ajax_submit(id, form_name) {
  var valuesToSubmit = $('form[name=' + form_name + ']').serialize();
  $.ajax({
    type: "PUT",
    url: "/votes", //submits it to the given url of the form
    data: valuesToSubmit,
    dataType: "JSON", // you want a difference between normal and ajax-calls, and json is standard
  })
  .done(function(){
    if (saved_messages_shown < wacky_message_threshold) {
      msg = "saved";
      saved_messages_shown++;
    } else {
      msg = success_messages[Math.floor(Math.random() * success_messages.length)];
    }
    flash_element(id, msg);
  })
  .fail(function(){
    flash_element(id, "failed");
  });
  return false; // prevents normal behaviour
}

function flash_element(id, msg) {
  $(id).css({ opacity: 0.0 });
  $(id).text(msg);
  $(id).animate({
    opacity: 1.0,
  }, {
    duration: 200,
    complete: function() {
      $(id).animate({
        opacity: 0.0,
      }, {
        duration: 200,
        complete: function() {
          $(id).text("");
        }
      });
    }
  });
}

var success_messages = ["saved", "ok", "yup", "love it", "sweet", "crushed",
                        "right", "swell", "sure"];

var saved_messages_shown = 0;
var wacky_message_threshold = 3;
