jQuery ->
  $('#user_username_name').autocomplete
    source: $('#user_username_name').data('autocomplete-source')