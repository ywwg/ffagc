function toggle_all_fund_emails(event) {
  event.preventDefault();
  checkboxes = document.getElementsByName('send_email_checkbox');
  var toggle_to = !checkboxes[0].checked;
  for(var i=0, n=checkboxes.length; i<n; i++) {
    checkboxes[i].checked = toggle_to;
  }
  return false;
}

function confirm_selected(event) {
  event.preventDefault();
  checkboxes = document.getElementsByName('send_email_checkbox');
  var selected = [];
  for (var i=0, n=checkboxes.length; i<n; i++) {
    if (checkboxes[i].checked) {
      var id = checkboxes[i].id.split("-")[1];
      selected.push(id);
    }
  }
  if (selected.length == 0) {
    alert("Please select the grants you wish to finalize.");
    return false;
  }
  var send_email = document.getElementById('send_grant_fund_email_checkbox').checked;
  var msg = "Are you sure you want to finalize " + selected.length + " grants and";
  if (!send_email) {
    msg += " not";
  }
  msg += " send emails?";
  if (confirm(msg)) {
    // Replace with proper escape_javascript(send_fund_emails_admins_grant_submissions_path)
    // which may require js-routes gem.
    $.post("grant_submissions/send_fund_emails?ids=" + selected + "&send_email=" + send_email);
  }
  return false;
}

function notify_selected(event) {
  event.preventDefault();
  checkboxes = document.getElementsByName('send_email_checkbox');
  var selected = [];
  for (var i=0, n=checkboxes.length; i<n; i++) {
    if (checkboxes[i].checked) {
      var id = checkboxes[i].id.split("-")[1];
      selected.push(id);
    }
  }
  if (selected.length == 0) {
    alert("Please select the grants you want to notify.");
    return false;
  }
  if (confirm("Are you sure you want to notify " + selected.length +
              " grant submissions about questions (if any) by email?"))
  // Replace with proper escape_javascript(send_question_emails_admins_grant_submissions_path)
  // which may require js-routes gem.
  $.post("grant_submissions/send_question_emails?ids=" + selected);
  return false;
}