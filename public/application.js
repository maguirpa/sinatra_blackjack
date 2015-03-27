$(document).ready(function() {
  player_hits();
  player_stays();
  dealer_hits();
  });

function player_hits() {
  $(document).on("click", "form#hit_form", function() {
    $.ajax({
      type: 'POST',
      url: '/player_hit',
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });
    return false;
  });
}

function player_stays() {
  $(document).on("click", "form#stay_form", function() {
    $.ajax({
      type: 'POST',
      url: '/player_stay',
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });
    return false;
  });
}

function dealer_hits() {
  $(document).on("click", "form#dealer_hit_form", function() {
    $.ajax({
      type: 'POST',
      url: '/dealer_hit',
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });
    return false;
  });
}