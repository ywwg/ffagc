function do_verify(event, id) {
  event.preventDefault();
  var send_email = document.getElementById('send_verify_email_checkbox').checked;
  $.post("/voters/"+ id +"/verify?send_email=" + send_email);
  return false;
}
