var levels_json = {};

function validate() {
  errors = 0;

  if (document.getElementById('grant_submission_name').value == '') {
    errors++;
    alert('Error: Please choose a name for your proposal');
    document.getElementById('grant_submission_name').style.border =
        '1px solid red';
  }

  var chosen_grant = get_chosen_grant();
  if (chosen_grant === -1) {
    errors++;
    alert('Error: Please select a grant for your proposal');
    document.getElementById('grant_submission_grant_selectors').style.border =
        '1px solid red';
  } else {
    if (!validate_funding_levels()) {
      errors++;
      alert('Error: one or more of your specified funding levels is invalid.');
      document.getElementById('funding_levels').style.border = '1px solid red';
    }
  }

  if (document.getElementById('grant_submission_proposal').value != '') {
    if (errors === 0) {
      // Ask for confirmation if they are uploading a new document, but only if
      // there are no other errors.
      var anon = confirm(
          'Did you make sure your proposal is anonymous and DOES NOT include any identifying information?');
      if (!anon) {
        errors++;
      }
    }
  } else if (
      document.getElementById('grant_submission_proposal_original_doc') ==
      null) {
    // If they didn't specify a new doc and there wasn't an existing doc,
    // then it's an error.
    errors++;
    alert('Error: Please select your application PDF');
    document.getElementById('grant_submission_proposal').style.border =
        '1px solid red';
  }
  return errors === 0;
}

function get_chosen_grant() {
  var grantRadios =
      document.querySelectorAll('[id^=grant_submission_grant_id]');
  var chosen_grant = -1;
  for (var i in grantRadios) {
    if (grantRadios[i].checked) {
      chosen_grant = grantRadios[i].value;
    }
  }
  return chosen_grant;
}

// loads the funding levels for the provided grant into the global levels_json
// object.
function load_funding_levels(chosen_grant) {
  $.ajax({
    type: 'GET',
    url: '/grants/levels',
    dataType: 'json',
    data: {id: chosen_grant},
    success: function(levels) {
      var msg = 'Available funding levels: ' + levels.csv;
      $('#funding_level_text').text(msg);
      levels_json = levels;
    }
  })
}

// validates that the requested grant levels are all valid according to the
// levels_json object.  Returns false if levels_json is unset.
function validate_funding_levels() {
  if (levels_json === null) {
    return false;
  }
  var valid = true;
  $('#funding_levels').children().each(function(index) {
    if ($(this).is('input:text')) {
      level_str = $(this).val();
      if (level_str === '') {
        // skip empty, because we don't have a delete button (yet?)
        return true;
      }
      var level = parseInt(level_str);
      if (isNaN(level) || level === 0) {
        valid = false;
        return false;
      }
      if (!validate_level(level, levels_json.levels)) {
        valid = false;
        return false;
      }
    }
  });
  return valid;
}

function validate_level(level, levels_array) {
  for (var i = 0; i < levels_array.length; i++) {
    var lower = levels_array[i][0];
    var upper = levels_array[i][1];
    if (level >= lower && level <= upper) {
      return true;
    }
  }
  return false;
}

// Appends another entry box for funding levels
function addLevel(nextLevel) {
  if (nextLevel > 0) {
    $('#add_level_button_' + (nextLevel - 1)).remove();
  }
  $('#funding_levels')
      .append(
          '<br/>\
    <input type="text" name="funding_levels[]" id="' +
          nextLevel + '" />\
    <button name="button" type="button" id="add_level_button_' +
          nextLevel + '" onclick="addLevel(' + (nextLevel + 1) +
          ')" class="btn btn-default">+</button>');
}

$(document).ready(function() {
  addLevel(0);
});