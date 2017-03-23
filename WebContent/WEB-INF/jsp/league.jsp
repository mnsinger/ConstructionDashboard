<!DOCTYPE html>
<html>
  <head>
    <title>NBA Fantasy Tools</title>

    <link rel="stylesheet" type="text/css" href="CSS/style.css"/>
    <link rel="stylesheet" type="text/css" href="CSS/tablesorter.default.css" />
    <style>
      .wrapper {
        width: 75%;
        position: relative;
        padding: 0 5px;
        margin: auto;
        height: 525px;
        overflow-y: auto;
      }
    </style>
    <script type="text/javascript" src="JS/nba.js"></script>
    <script type="text/javascript" src="JS/jquery-2.1.4.min.js"></script>
    <script type="text/javascript" src="JS/jquery.tablesorter.js"></script>
    <script type="text/javascript" src="JS/jquery.dropdownPlain.js"></script>
    <script type="text/javascript" src="JS/jquery.tablesorter.widgets.js"></script>
    <script type="text/javascript" src="JS/spin.min.js"></script>

<script>

var addedrows = new Array();
var teams = 0;
// var global_duration = '<?php echo $duration; ?>';
// var global_stat = '<?php echo $stat; ?>';
// var global_ignore = '<?php echo $ignore; ?>';

// Add ability to remove list of strings from array
if (!Array.prototype.remove) {
  Array.prototype.remove = function(vals, all) {
    var i, removedItems = [];
    if (!Array.isArray(vals)) vals = [vals];
    for (var j=0;j<vals.length; j++) {
      if (all) {
        for(i = this.length; i--;){
          if (this[i] === vals[j]) removedItems.push(this.splice(i, 1));
        }
      }
      else {
        i = this.indexOf(vals[j]);
        if(i>-1) removedItems.push(this.splice(i, 1));
      }
    }
    return removedItems;
  };
}

function radio(v) {
  document.getElementById('radio' + v).checked=true;
  for (t = 1; t <= teams; t++) {
    color = "transparent";
    if (t == v) { color = "lime"; }
    $("#divhilite" + t).css( "background-color", color ); 
  }
}

function shade_value(val, qual) {

  var stattype = "";
    
  selected = $("input[type='radio'][name='stat_type']:checked");
  if (selected.length > 0) {
      stattype = selected.val();
  }

  if (stattype == 2) {
    if (qual == 'N') { return "#ffffff"; }
    if (val <= 50) { return '#009900'; }
    else if (val <= 100) { return '#99ff33'; }
    else if (val <= 150) { return '#ffff00'; }
    else if (val <= 200) { return '#ff704d'; }
    else { return '#ff3300'; }
  }
  else {
    if (qual == 'N') { return "#ffffff"; }
    else if (val >= 80) { return "#009900"; }
    else if (val >= 60) { return "#99ff33"; }
    else if (val >= 40) { return "#FFFF00"; }
    else if (val >= 20) { return "#ff704d"; }
    else { return "#ff3300"; }
  }
}

function team_import(table_num) {
  $("#team_import_div" + table_num).toggle(1000);
  $('#radio' + table_num).trigger("click");
}

function scrollToTeam(div_num) {
  //$('body').scrollTo('#div' + div_num + ",{duration:'slow', offsetTop : '50'}");
  radio(div_num);
  $('html, body').animate({
        scrollTop: $("#div" + div_num).offset().top
    }, 1000);
  return false;
}

function team_import_spin(table_num) {
     var opts = {
      lines: 13 // The number of lines to draw
    , length: 28 // The length of each line
    , width: 14 // The line thickness
    , radius: 42 // The radius of the inner circle
    , scale: 1 // Scales overall size of the spinner
    , corners: 1 // Corner roundness (0..1)
    , color: '#000' // #rgb or #rrggbb or array of colors
    , opacity: 0.25 // Opacity of the lines
    , rotate: 0 // The rotation offset
    , direction: 1 // 1: clockwise, -1: counterclockwise
    , speed: 1 // Rounds per second
    , trail: 60 // Afterglow percentage
    , fps: 20 // Frames per second when using setTimeout() as a fallback for CSS
    , zIndex: 2e9 // The z-index (defaults to 2000000000)
    , className: 'spinner' // The CSS class to assign to the spinner
    , top: '50%' // Top position relative to parent
    , left: '50%' // Left position relative to parent
    , shadow: false // Whether to render a shadow
    , hwaccel: false // Whether to use hardware acceleration
    , position: 'absolute' // Element positioning
    }
    var target = document.getElementById('spinnerContainer');
    var spinner = new Spinner(opts).spin(target);
 
  setTimeout(function(){ team_import_search(table_num, spinner); }, 10);
}

function team_import_search(table_num, spinner) {

  var text = $("#team_import" + table_num).val();
  var punctRE = /[\u2000-\u206F\u2E00-\u2E7F\\'!"#$%&()*+,\-.\/:;<=>?@\[\]^_`{|}~]/g;
  text = text.replace(punctRE, ''); // Strip all punctuation from the string.
  text = text.replace(/[0-9]/g, ''); // Strip all numbers from the string.
  var team_players_arr = text.match(/\S+/g); // Return array separated on whitespace

  if (!team_players_arr) { team_players_arr = []; }

  console.log("team_players_arr length: " + team_players_arr.length);

  var remove_arr = [
    'PG', 'SG', 'PGSG', 'G', 'SF', 'SGSF', 'SFPF', 'PF', 'F', 'PFC', 'C', 'MIN', 'FGMFGA', 'FG%', '3PM', 'REB', 'AST', 'STL', 'BLK', 'PTS',
    'Players', 'roster', 'for', 'Details', 'Rankings', 'Fantasy', 'Field', 'Goals', 'Free', 'Throws', 'PT', 'Edit',
    'Opp', 'Status', 'ORank', 'Rank', 'Started', 'FGMA', 'FG', 'FTMA', 'FT', 'PTM', 'ST', 'TO', 'Video', 'Playlist', 'New', 'Player', 'Note',
    'Injured'
  ];

  team_players_arr.remove(remove_arr, true);

  //NAME TRANSFORMATIONS
  var found = $.inArray( "JJ", team_players_arr);
  if (team_players_arr[found + 1] == 'Barea') { team_players_arr[found] = 'Jose Juan'; }

  var curr_team_arr = [];
  var new_team_arr = [];
  var delete_before_import_flag = 0;
  if ($("#team_import_checkbox" + table_num).is(':checked')) {
    delete_before_import_flag = 1;
  }
  // GET ALL PLAYERS ON CURRENT TEAM
  $('#destinationtable' + table_num + ' tbody tr ').each(function(i, e) {
    curr_team_arr.push( $(e).attr('id').replace('dest','') );
  });

  if (!delete_before_import_flag) {
    new_team_arr = curr_team_arr.slice();
  }

  var new_players = 0;
  $.each(team_players_arr, function( index, value ) {
    $('#sourcetable tbody tr').each(function (i, el) {
      var first_word = String($('td:eq(0)', el).text().replace(/\./g, "").replace(/-/, ""));
      var second_word = String($('td:eq(1)', el).text().replace(/-/, ""));
      if (index < team_players_arr.length) {
        // MATCH ON FIRST AND LAST NAMES
        if (first_word === String(value) && second_word === String(team_players_arr[index + 1])) {
            new_team_arr.push($(el).attr('id'));
        }
      }
    });
  });

  // IF OLD NOT IN NEW, DELETE
  $.each(curr_team_arr, function( index, value ) {
    var found = $.inArray( value, new_team_arr ) > -1; 
    // DELETE FROM TEAM
    if (!found) {
      console.log("import - deleting former player");
      player_delete(table_num, value); 
    }
  });

  // IF NEW NOT IN OLD, ADD
  $.each(new_team_arr, function( index, value ) {
    var found = $.inArray( value, curr_team_arr ) > -1;
    // ADD TO TEAM
    if (!found) {
      console.log("ADDING PLAYER: " + value);
      player_add(table_num, value);
    }
  });

  $("#destinationtable" + table_num).trigger("update");
  $( '#team_count' + table_num ).val( new_team_arr.length );

  // BULK UPDATE TEAM BY CLEARING OUT ALL MEMBERS IN DB AND ADDING IN FRESH
  // ON DUPLICATE UPDATE WILL POINT PLAYERS ON OTHER TEAMS OVER TO CURR TEAM
  team_update_save(table_num, new_team_arr); 

  spinner.stop();

}

function shade_scoreboard() {

  console.log('shading scoreboard');

  if ( $( '#scoreboard tbody tr:eq(0) td:eq(5)').css("background-color") == 'rgb(255, 51, 0)')   { $( '#scoreboard tbody tr td').css("background-color", "transparent"); return; }
  if ( $( '#scoreboard tbody tr:eq(0) td:eq(5)').css("background-color") == 'rgb(153, 255, 51)') { $( '#scoreboard tbody tr td').css("background-color", "transparent"); return; }
  if ( $( '#scoreboard tbody tr:eq(0) td:eq(5)').css("background-color") == 'rgb(0, 153, 0)')    { $( '#scoreboard tbody tr td').css("background-color", "transparent"); return; }
  if ( $( '#scoreboard tbody tr:eq(0) td:eq(5)').css("background-color") == 'rgb(255, 112, 77)') { $( '#scoreboard tbody tr td').css("background-color", "transparent"); return; }
  if ( $( '#scoreboard tbody tr:eq(0) td:eq(5)').css("background-color") == 'rgb(255, 255, 0)')  { $( '#scoreboard tbody tr td').css("background-color", "transparent"); return; }

  var fg_pct_max = 0;
  var fg3m_max = 0;
  var ft_pct_max = 0;
  var reb_max = 0;
  var ast_max = 0;
  var tov_max = 0;
  var stl_max = 0;
  var blk_max = 0;
  var pts_max = 0;

  var fg_pct_min = 100;
  var fg3m_min = 100;
  var ft_pct_min = 100;
  var reb_min = 100;
  var ast_min = 100;
  var tov_min = 100;
  var stl_min = 100;
  var blk_min = 100;
  var pts_min = 100;

  $('#scoreboard tbody tr').each(function(i, e) { 
    if ($('td:eq(5)',  e).text().replace(/\(.*\)/, '') > fg_pct_max) { fg_pct_max = $('td:eq(5)',  e).text().replace(/\(.*\)/, ''); }
    if ($('td:eq(5)',  e).text().replace(/\(.*\)/, '') < fg_pct_min) { fg_pct_min = $('td:eq(5)',  e).text().replace(/\(.*\)/, ''); }

    if ($('td:eq(6)',  e).text().replace(/\(.*\)/, '') > fg3m_max)   { fg3m_max   = $('td:eq(6)',  e).text().replace(/\(.*\)/, ''); }
    if ($('td:eq(6)',  e).text().replace(/\(.*\)/, '') < fg3m_min)   { fg3m_min   = $('td:eq(6)',  e).text().replace(/\(.*\)/, ''); }

    if ($('td:eq(11)', e).text().replace(/\(.*\)/, '') > ft_pct_max) { ft_pct_max = $('td:eq(11)', e).text().replace(/\(.*\)/, ''); }
    if ($('td:eq(11)', e).text().replace(/\(.*\)/, '') < ft_pct_min) { ft_pct_min = $('td:eq(11)', e).text().replace(/\(.*\)/, ''); }

    if ($('td:eq(12)', e).text().replace(/\(.*\)/, '') > reb_max)    { reb_max    = $('td:eq(12)', e).text().replace(/\(.*\)/, ''); }
    if ($('td:eq(12)', e).text().replace(/\(.*\)/, '') < reb_min)    { reb_min    = $('td:eq(12)', e).text().replace(/\(.*\)/, ''); }

    if ($('td:eq(13)', e).text().replace(/\(.*\)/, '') > ast_max)    { ast_max    = $('td:eq(13)', e).text().replace(/\(.*\)/, ''); }
    if ($('td:eq(13)', e).text().replace(/\(.*\)/, '') < ast_min)    { ast_min    = $('td:eq(13)', e).text().replace(/\(.*\)/, ''); }

    if ($('td:eq(14)', e).text().replace(/\(.*\)/, '') > tov_max)    { tov_max    = $('td:eq(14)', e).text().replace(/\(.*\)/, ''); }
    if ($('td:eq(14)', e).text().replace(/\(.*\)/, '') < tov_min)    { tov_min    = $('td:eq(14)', e).text().replace(/\(.*\)/, ''); }

    if ($('td:eq(15)', e).text().replace(/\(.*\)/, '') > stl_max)    { stl_max    = $('td:eq(15)', e).text().replace(/\(.*\)/, ''); }
    if ($('td:eq(15)', e).text().replace(/\(.*\)/, '') < stl_min)    { stl_min    = $('td:eq(15)', e).text().replace(/\(.*\)/, ''); }

    if ($('td:eq(16)', e).text().replace(/\(.*\)/, '') > blk_max)    { blk_max    = $('td:eq(16)', e).text().replace(/\(.*\)/, ''); }
    if ($('td:eq(16)', e).text().replace(/\(.*\)/, '') < blk_min)    { blk_min    = $('td:eq(16)', e).text().replace(/\(.*\)/, ''); }

    if ($('td:eq(17)', e).text().replace(/\(.*\)/, '') > pts_max)    { pts_max    = $('td:eq(17)', e).text().replace(/\(.*\)/, ''); }
    if ($('td:eq(17)', e).text().replace(/\(.*\)/, '') < pts_min)    { pts_min    = $('td:eq(17)', e).text().replace(/\(.*\)/, ''); }
  });

  // local func
  function shade_value(val, qual) {
  
      if (qual == 'N') { return "ffffff"; }
      else if (val >= 80) { return "#009900"; }
      else if (val >= 60) { return "#99ff33"; }
      else if (val >= 40) { return "#FFFF00"; }
      else if (val >= 20) { return "#ff704d"; }
      else { return "#ff3300"; }
  }

  // DON'T SHADE SCOREBOARD IF THERE'S ONLY ONE TEAM IN THE LEAGUE
  if (fg_pct_max != fg_pct_min && fg3m_max != fg3m_min) {
    $('#scoreboard tbody tr').each(function(i, e) { 
      if (!$("#ignore0").is(':checked')) { 
        $('td:eq(5)',  e).css("background-color", shade_value( ( $('td:eq(5)' , e).text().replace(/\(.*\)/, '') - fg_pct_min) / (fg_pct_max - fg_pct_min) * 100, 'Y' ));
      }
      if (!$("#ignore1").is(':checked')) { 
        $('td:eq(6)',  e).css("background-color", shade_value( ( $('td:eq(6)' , e).text().replace(/\(.*\)/, '') - fg3m_min) / (fg3m_max - fg3m_min) * 100, 'Y' ));
      }
      if (!$("#ignore2").is(':checked')) { 
        $('td:eq(11)', e).css("background-color", shade_value( ( $('td:eq(11)', e).text().replace(/\(.*\)/, '') - ft_pct_min) / (ft_pct_max - ft_pct_min) * 100, 'Y' ));
      }
      if (!$("#ignore3").is(':checked')) { 
        $('td:eq(12)', e).css("background-color", shade_value( ( $('td:eq(12)', e).text().replace(/\(.*\)/, '') - reb_min) / (reb_max - reb_min) * 100, 'Y' ));
      }
      if (!$("#ignore4").is(':checked')) { 
        $('td:eq(13)', e).css("background-color", shade_value( ( $('td:eq(13)', e).text().replace(/\(.*\)/, '') - ast_min) / (ast_max - ast_min) * 100, 'Y' ));
      }
      if (!$("#ignore5").is(':checked')) { 
        $('td:eq(14)', e).css("background-color", shade_value( 100 - ( ( $('td:eq(14)', e).text().replace(/\(.*\)/, '') - tov_min) / (tov_max - tov_min) * 100 ), 'Y' ));
      }
      if (!$("#ignore6").is(':checked')) { 
        $('td:eq(15)', e).css("background-color", shade_value( ( $('td:eq(15)', e).text().replace(/\(.*\)/, '') - stl_min) / (stl_max - stl_min) * 100, 'Y' ));
      }
      if (!$("#ignore7").is(':checked')) { 
        $('td:eq(16)', e).css("background-color", shade_value( ( $('td:eq(16)', e).text().replace(/\(.*\)/, '') - blk_min) / (blk_max - blk_min) * 100, 'Y' ));
      }
      if (!$("#ignore8").is(':checked')) { 
        $('td:eq(17)', e).css("background-color", shade_value( ( $('td:eq(17)', e).text().replace(/\(.*\)/, '') - pts_min) / (pts_max - pts_min) * 100, 'Y' ));
      }
    });
  }
}

function shade_table(table_name, no_toggle) {

  // don't toggle the shading; incremental changes
  if (!no_toggle) {
    if ( $( table_name + ' tbody tr:eq(0) td:eq(12)').css("background-color") == 'rgb(255, 51, 0)')   { $( table_name + ' tbody tr td').css("background-color", "transparent"); return; }
    if ( $( table_name + ' tbody tr:eq(0) td:eq(12)').css("background-color") == 'rgb(153, 255, 51)') { $( table_name + ' tbody tr td').css("background-color", "transparent"); return; }
    if ( $( table_name + ' tbody tr:eq(0) td:eq(12)').css("background-color") == 'rgb(0, 153, 0)')    { $( table_name + ' tbody tr td').css("background-color", "transparent"); return; }
    if ( $( table_name + ' tbody tr:eq(0) td:eq(12)').css("background-color") == 'rgb(255, 112, 77)'){ $( table_name + ' tbody tr td').css("background-color", "transparent"); return; }
    if ( $( table_name + ' tbody tr:eq(0) td:eq(12)').css("background-color") == 'rgb(255, 255, 0)') { $( table_name + ' tbody tr td').css("background-color", "transparent"); return; }

    if (table_name.substring(0, 17) == '#destinationtable') { 
      $('#radio' + table_name.replace('#destinationtable','')).trigger("click"); 
    }
  }

  var stattype = "";
    
  selected = $("input[type='radio'][name='stat_type']:checked");
  if (selected.length > 0) {
      stattype = selected.val();
  }

  $( table_name + ' tbody tr').each(function(i, e) {

    fg_pct_qual = 'N';
    ft_pct_qual = 'N';

    if ($('td:eq(4)', e).prop('title') > 5.0) { fg_pct_qual = 'Y'; }
    if ($('td:eq(10)', e).prop('title') > 2)  { ft_pct_qual = 'Y'; }

    fg3m_qual = 'Y';
    reb_qual = 'Y';
    ast_qual = 'Y';
    tov_qual = 'Y';
    stl_qual = 'Y';
    blk_qual = 'Y';
    pts_qual = 'Y';

    if ($("#ignore0").is(':checked')) { fg_pct_qual = 'N'; }
    if ($("#ignore1").is(':checked')) { fg3m_qual = 'N'; }
    if ($("#ignore2").is(':checked')) { ft_pct_qual = 'N'; }
    if ($("#ignore3").is(':checked')) { reb_qual = 'N'; }
    if ($("#ignore4").is(':checked')) { ast_qual = 'N'; }
    if ($("#ignore5").is(':checked')) { tov_qual = 'N'; }
    if ($("#ignore6").is(':checked')) { stl_qual = 'N'; }
    if ($("#ignore7").is(':checked')) { blk_qual = 'N'; }
    if ($("#ignore8").is(':checked')) { pts_qual = 'N'; }

    // select proper value from cells for shading
    if (stattype == 0) { //average
      $('td:eq(5)',  e).css("background-color", shade_value($('td:eq(5)' , e).prop('title'), fg_pct_qual));
      $('td:eq(6)',  e).css("background-color", shade_value($('td:eq(6)' , e).prop('title'), fg3m_qual));
      $('td:eq(11)', e).css("background-color", shade_value($('td:eq(11)', e).prop('title'), ft_pct_qual));
      $('td:eq(12)', e).css("background-color", shade_value($('td:eq(12)', e).prop('title'), reb_qual));
      $('td:eq(13)', e).css("background-color", shade_value($('td:eq(13)', e).prop('title'), ast_qual));
      $('td:eq(14)', e).css("background-color", shade_value($('td:eq(14)', e).prop('title'), tov_qual));
      $('td:eq(15)', e).css("background-color", shade_value($('td:eq(15)', e).prop('title'), stl_qual));
      $('td:eq(16)', e).css("background-color", shade_value($('td:eq(16)', e).prop('title'), blk_qual));
      $('td:eq(17)', e).css("background-color", shade_value($('td:eq(17)', e).prop('title'), pts_qual));
    }
    else { //rating or ranking
      $('td:eq(5)',  e).css("background-color", shade_value($('td:eq(5)' , e).text(), fg_pct_qual));
      $('td:eq(6)',  e).css("background-color", shade_value($('td:eq(6)' , e).text(), fg3m_qual));
      $('td:eq(11)', e).css("background-color", shade_value($('td:eq(11)', e).text(), ft_pct_qual));
      $('td:eq(12)', e).css("background-color", shade_value($('td:eq(12)', e).text(), reb_qual));
      $('td:eq(13)', e).css("background-color", shade_value($('td:eq(13)', e).text(), ast_qual));
      $('td:eq(14)', e).css("background-color", shade_value($('td:eq(14)', e).text(), tov_qual));
      $('td:eq(15)', e).css("background-color", shade_value($('td:eq(15)', e).text(), stl_qual));
      $('td:eq(16)', e).css("background-color", shade_value($('td:eq(16)', e).text(), blk_qual));
      $('td:eq(17)', e).css("background-color", shade_value($('td:eq(17)', e).text(), pts_qual));
    }

  });

}
 
function player_del_save(dest_table_num, theid, skip_scoreboard_update_flag) {

    team_id = $("#team_id" + dest_table_num).val();

    console.log("in player del for team_id " + team_id + " and pid " + theid);

    $.ajax({
       url: 'player_del_save.php',
       datatype: 'text',
       async: true,
       type: 'post',
       data: { team_id: JSON.stringify(team_id), player_id: JSON.stringify(theid) },
       success: function(data, status) {
         console.log(data);
         if (!skip_scoreboard_update_flag) {
           load_scoreboard($("input[type='radio'][name='data_type']:checked").val(), $("input[type='radio'][name='stat_type']:checked").val());
         }
       },
       error: function(data, status) {
         console.log(data);
         //alert(data);
       }
    });

}

function delete_team(dest_table_num) {

  var r = confirm('delete team: "' + $("#team_name" + dest_table_num).val() + '"?');
  if (r == true) {

    team_id = $("#team_id" + dest_table_num).val();

    console.log("in delete_team for team_id " + team_id);

    $.ajax({
       url: 'team_delete.php',
       datatype: 'text',
       async: true,
       type: 'post',
       data: { team_id: JSON.stringify(team_id) },
       success: function(data, status) {
         console.log(data);
         $("#div" + dest_table_num).hide('slow', function(){ $("#div" + dest_table_num).remove(); });
         load_scoreboard($("input[type='radio'][name='data_type']:checked").val(), $("input[type='radio'][name='stat_type']:checked").val());
       },
       error: function(data, status) {
         console.log(data);
         //alert(data);
       }
    });

  }

}

function player_delete(tablenum, theid, skip_scoreboard_update_flag) {

  var ok = 0;
  var newaddedrows = new Array();

  // check if player exists on a team already, if so remove
  for (index = 0; index < addedrows.length; ++index) {
      if (addedrows[index] == theid) {
          $( '#' + theid ).css( "background-color", "#ffffff" );
          // remove from dest table :
          var tr = $( "#dest" + theid );
          // if row to be removed is only row in table - add dummy
          if ( (typeof tr.prev().attr('id') == 'undefined') && (typeof tr.next().attr('id') == 'undefined') ) {
              tr.after('<tr id="dummyNeededForTableSorter"><td colspan="18"></td></tr>');
          }
          tr.css("background-color","#FF3700");
          tr.fadeOut(400, function(){
              tr.remove();
          });
          //the boolean
          ok = 1;
      }
      else {
          // add row to array
          newaddedrows.push(addedrows[index]);
      }
  }
  addedrows = newaddedrows;

}

function player_add(tablenum, theid, skip_scoreboard_update_flag) {

  console.log('in player_add: tablenum = ' + tablenum + ', theid = ' + theid + ', skip_scoreboard_update_flag = ' + skip_scoreboard_update_flag);

  var ok = 0;
  var newaddedrows = new Array();

  // check if player exists on a team already, if so remove
  for (index = 0; index < addedrows.length; ++index) {
      if (addedrows[index] == theid) {
          $( '#' + theid ).css( "background-color", "#ffffff" );
          // remove from dest table :
          var tr = $( "#dest" + theid );
          // if row to be removed is only row in table - add dummy
          if ( (typeof tr.prev().attr('id') == 'undefined') && (typeof tr.next().attr('id') == 'undefined') ) {
              tr.after('<tr id="dummyNeededForTableSorter"><td colspan="18"></td></tr>');
          }
          tr.css("background-color","#FF3700");
          tr.fadeOut(400, function(){
              console.log(tr.closest('table').attr('id'));
              var tablename = tr.closest('table').attr('id');
              console.log("tablename = " + tablename);
              var other_tablenum = tr.closest('table').attr('id').replace( /^\D+/g, '');
              console.log("other_tablenum = " + other_tablenum);
              console.log('#' + tablename + ' tr');
              console.log($('#' + tablename + ' tr').length);
              //$("#destinationtable" + table_num).trigger("update");
              $( '#team_count' + other_tablenum ).val( $('#' + tablename + ' tr').length - 2 );

              // NO NEED TO DELETE AT DB LEVEL BECAUSE IT'S HANDLED IN IMPORT
              tr.remove();
          });
          //the boolean
          ok = 1;
      }
      else {
          // add row to array
          newaddedrows.push(addedrows[index]);
      }
  }
  addedrows = newaddedrows;

  // add the row to current team :
      addedrows.push( theid );
      $( '#' + theid ).css( "background-color", "#cacaca" );
      // if table is empty and this is the first row being added set flag to remove dummy row
      f = 'O';
      if ( $('#destinationtable' + tablenum + ' tr:last').attr('id') == 'dummyNeededForTableSorter' ) { f = 'D'; rtd = $('#destinationtable' + tablenum + ' tr:last'); }
      $('#destinationtable' + tablenum + ' tr:last').after('<tr id="dest' + theid + '"><td>'
                                     + $('#' + theid).find("td").eq(0).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(1).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(2).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(3).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(4).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(5).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(6).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(7).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(8).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(9).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(10).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(11).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(12).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(13).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(14).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(15).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(16).html() + '</td><td>'
                                     + $('#' + theid).find("td").eq(17).html() + '</td><td style=\'color:red;\'>'
                                     + 'drop' + '</td></tr>');
 
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(2).prop('title', $('#' + theid).find("td").eq(2).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(3).prop('title', $('#' + theid).find("td").eq(3).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(4).prop('title', $('#' + theid).find("td").eq(4).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(5).prop('title', $('#' + theid).find("td").eq(5).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(6).prop('title', $('#' + theid).find("td").eq(6).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(7).prop('title', $('#' + theid).find("td").eq(7).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(8).prop('title', $('#' + theid).find("td").eq(8).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(9).prop('title', $('#' + theid).find("td").eq(9).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(10).prop('title', $('#' + theid).find("td").eq(10).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(11).prop('title', $('#' + theid).find("td").eq(11).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(12).prop('title', $('#' + theid).find("td").eq(12).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(13).prop('title', $('#' + theid).find("td").eq(13).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(14).prop('title', $('#' + theid).find("td").eq(14).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(15).prop('title', $('#' + theid).find("td").eq(15).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(16).prop('title', $('#' + theid).find("td").eq(16).prop('title'));
      $('#destinationtable' + tablenum + ' tr:last').find("td").eq(17).prop('title', $('#' + theid).find("td").eq(17).prop('title'));
 
      // remove dummy row
      if ( f == 'D' ) { rtd.remove(); f = 'O'; }
 
      // drop a player from existing team
      $("#dest" + theid).find("td").eq(18).on( "click", function( event ) {
          $('#radio' + tablenum).trigger('click');
          $( '#' + theid ).trigger('click');
          $( '#team_count' + tablenum ).val( $('#destinationtable' + tablenum + ' tr').length - 2 );
      });

}


function team_update_save(tablenum, new_team_arr) {

    team_id = $("#team_id" + tablenum).val();

    $.ajax({
       url: 'team_update_save.php',
       datatype: 'text',
       async: true,
       type: 'post',
       data: { team_id: JSON.stringify(team_id), team_arr: new_team_arr },
       success: function(data, status) {
         load_scoreboard($("input[type='radio'][name='data_type']:checked").val(), $("input[type='radio'][name='stat_type']:checked").val());
         shade_table('#destinationtable' + tablenum, true);
       },
       error: function(data, status) {
         console.log(data);
         //alert(data);
       }
    });

}

function player_add_save(dest_table_num, theid, skip_scoreboard_update_flag) {

    team_id = $("#team_id" + dest_table_num).val();

    $.ajax({
       url: 'player_add_save.php',
       datatype: 'text',
       async: true,
       type: 'post',
       data: { team_id: JSON.stringify(team_id), player_id: JSON.stringify(theid) },
       success: function(data, status) {
         console.log(data);
         if (!skip_scoreboard_update_flag) {
           load_scoreboard($("input[type='radio'][name='data_type']:checked").val(), $("input[type='radio'][name='stat_type']:checked").val());
         }
         shade_table('#destinationtable' + dest_table_num, true);
       },
       error: function(data, status) {
         console.log(data);
         //alert(data);
       }
    });

}

function load_existing_teams() {

    var opts = {
      lines: 13 // The number of lines to draw
    , length: 28 // The length of each line
    , width: 14 // The line thickness
    , radius: 42 // The radius of the inner circle
    , scale: 1 // Scales overall size of the spinner
    , corners: 1 // Corner roundness (0..1)
    , color: '#000' // #rgb or #rrggbb or array of colors
    , opacity: 0.25 // Opacity of the lines
    , rotate: 0 // The rotation offset
    , direction: 1 // 1: clockwise, -1: counterclockwise
    , speed: 1 // Rounds per second
    , trail: 60 // Afterglow percentage
    , fps: 20 // Frames per second when using setTimeout() as a fallback for CSS
    , zIndex: 2e9 // The z-index (defaults to 2000000000)
    , className: 'spinner' // The CSS class to assign to the spinner
    , top: '50%' // Top position relative to parent
    , left: '50%' // Left position relative to parent
    , shadow: false // Whether to render a shadow
    , hwaccel: false // Whether to use hardware acceleration
    , position: 'absolute' // Element positioning
    }
    var target = document.getElementById('spinnerContainer');
    var spinner = new Spinner(opts).spin(target);
    
    var selected = $("input[type='radio'][name='data_type']:checked");
    if (selected.length > 0) {
        timeframe = selected.val();
    }

    var stattype = -1;
    selected = $("input[type='radio'][name='stat_type']:checked");
    if (selected.length > 0) {
        stattype = selected.val();
    }

    var ignore = "";
    for (i = 0; i < 9; i++) { 
      if ($("#ignore" + i).is(':checked')) { ignore += i + ","; }
    }

    if (ignore.length > 0) { ignore = ignore.substring(0, ignore.length - 1); }

    $.ajax({
       url: 'load_existing_teams.php',
       datatype: 'text',
       async: true,
       type: 'post',
       data: { timeframe: JSON.stringify(timeframe), stattype: JSON.stringify(stattype) },
       success: function(data, status) {
         //console.log(data);

         value_prefix = ""; title_prefix = "";
         if (stattype == 0) { value_prefix = "a_"; }
         if (stattype == 1) { title_prefix = "a_"; }
         if (stattype == 2) { title_prefix = "a_"; }
    
         $.each(JSON.parse(data), function(i, player_info) {

           //console.log(player_info);
           if ( $('#dest' + player_info.pid).length > 0 ) { 
             //console.log(player_info.fname + ' ' + player_info.lname + ' exists'); 
             $("#dest" + player_info.pid + " td:eq(2)").html(player_info[value_prefix + "gp"]);
             $("#dest" + player_info.pid + " td:eq(2)").attr('title', player_info[title_prefix + "gp"]);

             $("#dest" + player_info.pid + " td:eq(3)").html(player_info[value_prefix + "fgm"]);
             $("#dest" + player_info.pid + " td:eq(3)").attr('title', player_info[title_prefix + "fgm"]);

             $("#dest" + player_info.pid + " td:eq(4)").html(player_info[value_prefix + "fga"]);
             $("#dest" + player_info.pid + " td:eq(4)").attr('title', player_info[title_prefix + "fga"]);

             $("#dest" + player_info.pid + " td:eq(5)").html(player_info[value_prefix + "fg_pct"]);
             $("#dest" + player_info.pid + " td:eq(5)").attr('title', player_info[title_prefix + "fg_pct"]);

             $("#dest" + player_info.pid + " td:eq(6)").html(player_info[value_prefix + "fg3m"]);
             $("#dest" + player_info.pid + " td:eq(6)").attr('title', player_info[title_prefix + "fg3m"]);

             $("#dest" + player_info.pid + " td:eq(7)").html(player_info[value_prefix + "fg3a"]);
             $("#dest" + player_info.pid + " td:eq(7)").attr('title', player_info[title_prefix + "fg3a"]);

             $("#dest" + player_info.pid + " td:eq(8)").html(player_info[value_prefix + "fg3_pct"]);
             $("#dest" + player_info.pid + " td:eq(8)").attr('title', player_info[title_prefix + "fg3_pct"]);

             $("#dest" + player_info.pid + " td:eq(9)").html(player_info[value_prefix + "ftm"]);
             $("#dest" + player_info.pid + " td:eq(9)").attr('title', player_info[title_prefix + "ftm"]);

             $("#dest" + player_info.pid + " td:eq(10)").html(player_info[value_prefix + "fta"]);
             $("#dest" + player_info.pid + " td:eq(10)").attr('title', player_info[title_prefix + "fta"]);

             $("#dest" + player_info.pid + " td:eq(11)").html(player_info[value_prefix + "ft_pct"]);
             $("#dest" + player_info.pid + " td:eq(11)").attr('title', player_info[title_prefix + "ft_pct"]);

             $("#dest" + player_info.pid + " td:eq(12)").html(player_info[value_prefix + "reb"]);
             $("#dest" + player_info.pid + " td:eq(12)").attr('title', player_info[title_prefix + "reb"]);

             $("#dest" + player_info.pid + " td:eq(13)").html(player_info[value_prefix + "ast"]);
             $("#dest" + player_info.pid + " td:eq(13)").attr('title', player_info[title_prefix + "ast"]);

             $("#dest" + player_info.pid + " td:eq(14)").html(player_info[value_prefix + "tov"]);
             $("#dest" + player_info.pid + " td:eq(14)").attr('title', player_info[title_prefix + "tov"]);

             $("#dest" + player_info.pid + " td:eq(15)").html(player_info[value_prefix + "stl"]);
             $("#dest" + player_info.pid + " td:eq(15)").attr('title', player_info[title_prefix + "stl"]);

             $("#dest" + player_info.pid + " td:eq(16)").html(player_info[value_prefix + "blk"]);
             $("#dest" + player_info.pid + " td:eq(16)").attr('title', player_info[title_prefix + "blk"]);

             $("#dest" + player_info.pid + " td:eq(17)").html(player_info[value_prefix + "pts"]);
             $("#dest" + player_info.pid + " td:eq(17)").attr('title', player_info[title_prefix + "pts"]);

           }

           $("#" + player_info.pid + " td:eq(2)").html(player_info[value_prefix + "gp"]);
           $("#" + player_info.pid + " td:eq(2)").attr('title', player_info[title_prefix + "gp"]);

           $("#" + player_info.pid + " td:eq(3)").html(player_info[value_prefix + "fgm"]);
           $("#" + player_info.pid + " td:eq(3)").attr('title', player_info[title_prefix + "fgm"]);

           $("#" + player_info.pid + " td:eq(4)").html(player_info[value_prefix + "fga"]);
           $("#" + player_info.pid + " td:eq(4)").attr('title', player_info[title_prefix + "fga"]);

           $("#" + player_info.pid + " td:eq(5)").html(player_info[value_prefix + "fg_pct"]);
           $("#" + player_info.pid + " td:eq(5)").attr('title', player_info[title_prefix + "fg_pct"]);

           $("#" + player_info.pid + " td:eq(6)").html(player_info[value_prefix + "fg3m"]);
           $("#" + player_info.pid + " td:eq(6)").attr('title', player_info[title_prefix + "fg3m"]);

           $("#" + player_info.pid + " td:eq(7)").html(player_info[value_prefix + "fg3a"]);
           $("#" + player_info.pid + " td:eq(7)").attr('title', player_info[title_prefix + "fg3a"]);

           $("#" + player_info.pid + " td:eq(8)").html(player_info[value_prefix + "fg3_pct"]);
           $("#" + player_info.pid + " td:eq(8)").attr('title', player_info[title_prefix + "fg3_pct"]);

           $("#" + player_info.pid + " td:eq(9)").html(player_info[value_prefix + "ftm"]);
           $("#" + player_info.pid + " td:eq(9)").attr('title', player_info[title_prefix + "ftm"]);

           $("#" + player_info.pid + " td:eq(10)").html(player_info[value_prefix + "fta"]);
           $("#" + player_info.pid + " td:eq(10)").attr('title', player_info[title_prefix + "fta"]);

           $("#" + player_info.pid + " td:eq(11)").html(player_info[value_prefix + "ft_pct"]);
           $("#" + player_info.pid + " td:eq(11)").attr('title', player_info[title_prefix + "ft_pct"]);

           $("#" + player_info.pid + " td:eq(12)").html(player_info[value_prefix + "reb"]);
           $("#" + player_info.pid + " td:eq(12)").attr('title', player_info[title_prefix + "reb"]);

           $("#" + player_info.pid + " td:eq(13)").html(player_info[value_prefix + "ast"]);
           $("#" + player_info.pid + " td:eq(13)").attr('title', player_info[title_prefix + "ast"]);

           $("#" + player_info.pid + " td:eq(14)").html(player_info[value_prefix + "tov"]);
           $("#" + player_info.pid + " td:eq(14)").attr('title', player_info[title_prefix + "tov"]);

           $("#" + player_info.pid + " td:eq(15)").html(player_info[value_prefix + "stl"]);
           $("#" + player_info.pid + " td:eq(15)").attr('title', player_info[title_prefix + "stl"]);

           $("#" + player_info.pid + " td:eq(16)").html(player_info[value_prefix + "blk"]);
           $("#" + player_info.pid + " td:eq(16)").attr('title', player_info[title_prefix + "blk"]);

           $("#" + player_info.pid + " td:eq(17)").html(player_info[value_prefix + "pts"]);
           $("#" + player_info.pid + " td:eq(17)").attr('title', player_info[title_prefix + "pts"]);

         }); // END LOOP OF ALL PLAYERS

         for (c=1; c <= teams; c++) {
           $('#destinationtable' + c).trigger('update');
         }
         $('#sourcetable').trigger('update');

         console.log("global_duration = " + global_duration + ", duration = " + timeframe);
         console.log("global_stat = " + global_stat + ", stattype = " + stattype);
         console.log("global_ignore = " + global_ignore + ", ignore = " + ignore);

         var reshade_flag = 0;
         // RESHADE - SWITCH FROM/TO RANK
         if ((global_stat==2 || stattype==2) && (global_stat != stattype)) {
           reshade_flag = 1;
           console.log("need to reshade since switch from/to rank");
         }
         // RESHADE - IGNORE FLAGS SWITCHED
         else if (String(global_ignore).localeCompare(String(ignore)) != 0) {
           reshade_flag = 1;
           console.log("need to reshade since switch from/to rank");
         }
         // RESHADE - SWITCHED DURATION
         else if (global_duration != timeframe) {
           reshade_flag = 1;
           console.log("need to reshade since switch of duration");
         }


         if (reshade_flag) {
           for (x=1; x <= teams; x++) {
             shade_table('#destinationtable' + x, true);
           }
           shade_table('#sourcetable', true);
         }

         global_stat = stattype;
         global_ignore = ignore;
         global_duration = timeframe;

         spinner.stop();

       },
       error: function(data, status) {
         console.log(data);
         //alert(data);
       }
    });

}

function update_league_prefs(timeframe, stattype) {

    var league_name = $('#league_name').val();
    var ignore_vals = "";

    for (i = 0; i < 9; i++) { 
      if ($("#ignore" + i).is(':checked')) { ignore_vals += i + ","; }
    }

    if (ignore_vals.length > 0) { ignore_vals = ignore_vals.substring(0, ignore_vals.length - 1); }

    $.ajax({
       url: 'update_league_prefs.php',
       dataType: "json",       
       async: true,
       type: 'post',
       data: { league_name: JSON.stringify(league_name), timeframe: timeframe, stattype: stattype, ignore: ignore_vals },
       success: function(data, status) {

       },
       error: function(data, status) {
       }
    });
}

function load_scoreboard(timeframe, stattype) {

    var categories = 9;
    for (i = 0; i < 9; i++) { 
      if ($("#ignore" + i).is(':checked')) { categories--; }
    }

    $.ajax({
       url: 'load_scoreboard.php',
       dataType: "json",       
       async: true,
       type: 'post',
       data: { timeframe: JSON.stringify(timeframe) },
       success: function(data, status) {
           $( "#scoreboard_tbody" ).empty();
           var tbody_str = "";
           var fg_pct_arr = []; fg3m_arr = []; ft_pct_arr = []; reb_arr = []; ast_arr = []; tov_arr = []; stl_arr = []; blk_arr = []; pts_arr = [];
           $.each(data, function(i, team_score) {

             fg_pct_arr.push(team_score.fg_pct);
             fg3m_arr.push(team_score.fg3m);
             ft_pct_arr.push(team_score.ft_pct);
             reb_arr.push(team_score.reb);
             ast_arr.push(team_score.ast);
             tov_arr.push(team_score.tov);
             stl_arr.push(team_score.stl);
             blk_arr.push(team_score.blk);
             pts_arr.push(team_score.pts);

           });

           console.log(pts_arr);
 
           // sort values in arrays
           fg_pct_ranks = fg_pct_arr.sort(function(a, b){return b-a});
           fg3m_ranks = fg3m_arr.sort(function(a, b){return b-a});
           ft_pct_ranks = ft_pct_arr.sort(function(a, b){return b-a});
           reb_ranks = reb_arr.sort(function(a, b){return b-a});
           ast_ranks = ast_arr.sort(function(a, b){return b-a});
           tov_ranks = tov_arr.sort();
           stl_ranks = stl_arr.sort(function(a, b){return b-a});
           blk_ranks = blk_arr.sort(function(a, b){return b-a});
           pts_ranks = pts_arr.sort(function(a, b){return b-a});

           $.each(data, function(i, team_score) {

             fg_pct_rank = $.inArray(team_score.fg_pct, fg_pct_ranks)+1;
             fg3m_rank = $.inArray(team_score.fg3m, fg3m_ranks)+1;
             ft_pct_rank = $.inArray(team_score.ft_pct, ft_pct_ranks)+1;
             reb_rank = $.inArray(team_score.reb, reb_ranks)+1;
             ast_rank = $.inArray(team_score.ast, ast_ranks)+1;
             tov_rank = $.inArray(team_score.tov, tov_ranks)+1;
             stl_rank = $.inArray(team_score.stl, stl_ranks)+1;
             blk_rank = $.inArray(team_score.blk, blk_ranks)+1;
             pts_rank = $.inArray(team_score.pts, pts_ranks)+1;

             if ($("#ignore0").is(':checked')) { fg_pct_rank = 0; }
             if ($("#ignore1").is(':checked')) { fg3m_rank = 0; }
             if ($("#ignore2").is(':checked')) { ft_pct_rank = 0; }
             if ($("#ignore3").is(':checked')) { reb_rank = 0; }
             if ($("#ignore4").is(':checked')) { ast_rank = 0; }
             if ($("#ignore5").is(':checked')) { tov_rank = 0; }
             if ($("#ignore6").is(':checked')) { stl_rank = 0; }
             if ($("#ignore7").is(':checked')) { blk_rank = 0; }
             if ($("#ignore8").is(':checked')) { pts_rank = 0; }

             avg_rank = ((fg_pct_rank + fg3m_rank + ft_pct_rank + reb_rank + ast_rank + tov_rank + stl_rank + blk_rank + pts_rank) / categories).toFixed(2);

             j = i + 1;
             tbody_str += "<tr><td title='Team Name (Roster Size)'><a href='#' onClick='scrollToTeam(" + j + ");'><b style='color:blue;'>" + team_score.name + " (" + team_score.cnt + ")</b></a></td>";
             tbody_str += "<td>" + avg_rank + "</td>";
             tbody_str += "<td>" + team_score.gp + "</td>";
             tbody_str += "<td>" + team_score.fgm + "</td>";
             tbody_str += "<td>" + team_score.fga + "</td>";
             tbody_str += "<td>" + team_score.fg_pct + "<br>(" + fg_pct_rank  + ")</td>";
             tbody_str += "<td>" + team_score.fg3m + "<br>(" + fg3m_rank  + ")</td>";
             tbody_str += "<td>" + team_score.fg3a + "</td>";
             tbody_str += "<td>" + team_score.fg3_pct + "</td>";
             tbody_str += "<td>" + team_score.ftm + "</td>";
             tbody_str += "<td>" + team_score.fta + "</td>";
             tbody_str += "<td>" + team_score.ft_pct + "<br>(" + ft_pct_rank  + ")</td>";
             tbody_str += "<td>" + team_score.reb + "<br>(" + reb_rank  + ")</td>";
             tbody_str += "<td>" + team_score.ast + "<br>(" + ast_rank  + ")</td>";
             tbody_str += "<td>" + team_score.tov + "<br>(" + tov_rank  + ")</td>";
             tbody_str += "<td>" + team_score.stl + "<br>(" + stl_rank  + ")</td>";
             tbody_str += "<td>" + team_score.blk + "<br>(" + blk_rank  + ")</td>";
             tbody_str += "<td>" + team_score.pts + "<br>(" + pts_rank  + ")</td>";

           });
           $( "#scoreboard_tbody" ).append(tbody_str);
           $( "#scoreboard_tbody" ).trigger('update');
           shade_scoreboard();

       },
       error: function(data, status) {
       }
    });

}

function league_save() {

    // VALIDATE FORM
    var valid = 1;
    if ($("#league_name").val().length == 0) { alert('league name is blank'); valid = 0; }

    if (!valid) { return; }

    var league = "";
    var teams_arr = new Array();
    var c = 0;
    var d = 1;
    // LOOP TEXT INPUTS
    $('input[type=text]').each(function(){
      if ( $(this).attr('id').substring(0, 9) == 'team_name' ) { 
        team_name = $(this).val();
        team_id = $("#team_id" + d).val();
        teams_arr[c] = team_name + ' ,' + team_id + ',';
        // LOOP PLAYERS IN TABLES TO CREATE STRINGS OF TEAMS AND PLAYERS
        $('#destinationtable' + $(this).attr('id').replace('team_name', '') + ' > tbody  > tr').each(function(i, e) { 
          var pid = Number($(e).attr('id').replace('dest','' ));
          var found = $.inArray( pid, addedrows);
          // DUE TO LAG AFTER DROP BUTTON PRESSED - ONLY ADD PLAYER TO TEAM LIST IF FOUND IN GLOBAL ARRAY OF PLAYERS ON ROSTERS
          if (found > -1) {
            teams_arr[c] += $(e).attr('id').replace('dest','') + ','; 
          }
        });
        teams_arr[c] = teams_arr[c].substring(0, teams_arr[c].length - 1);
        c++;
        d++;
      }
      else if ( $(this).attr('id').substring(0, 11) == 'league_name' ) {
        league = $(this).val();
      }
    });

    //console.log(addedrows);

    league_data = JSON.stringify(league);
    teams_data = JSON.stringify(teams_arr);

    var selectedVal = "";
    var selectedVal2 = "";
    var selected = $("input[type='radio'][name='data_type']:checked");
    if (selected.length > 0) {
        selectedVal = selected.val();
    }

    selected = $("input[type='radio'][name='stat_type']:checked");
    if (selected.length > 0) {
        selectedVal2 = selected.val();
    }

    ignore_vals = "";
    for (i = 0; i < 9; i++) { 
      if ($("#ignore" + i).is(':checked')) { ignore_vals += i + ","; }
    }

    if (ignore_vals.length > 0) { ignore_vals = ignore_vals.substring(0, ignore_vals.length - 1); }


    //console.log("sending over: ");
    //console.log(teams_arr);
    //console.log("return vals: ");
    $.ajax({
       url: 'league_save.php',
       datatype: 'text',
       async: true,
       type: 'post',
       data: { league: league_data, teams: teams_data, duration: selectedVal, stat: selectedVal2, ignore: ignore_vals },
       success: function(data, status) {
         //location.href = "league.php";
         //console.log(data);
         var team_array = data.split(',');
         for(var i = 0; i < team_array.length; i++) {
           j = i+1;
           $("#team_id" + j).val(team_array[i]);
           //console.log("#team_id" + j + " = " + team_array[i]);
         }
       },
       error: function(data, status) {
         //console.log(data);
         //alert(data);
       }
    });

};

$(document).ready(function() {

    $("#scoreboard").tablesorter(); 

    $("#sourcetable").tablesorter({
        widthFixed : true,
        headerTemplate : '{content} {icon}', // Add icon for various themes

        widgets: [ 'stickyHeaders' ],

        widgetOptions: {
                // jQuery selector or object to attach sticky header to
                stickyHeaders_attachTo : '.wrapper' // or $('.wrapper')
        }
    });

    //$("#league_save").click(function() {
    //});

    $("#team_add").click(function() {

        teams = teams + 1;
        var new_table_html = '<div id="div' + teams + '" style="margin:auto;width:100%" onClick="radio(' + teams + ');"><div id="divhilite' + teams + '" style="margin:auto;width:65%"><input type="radio" name="tablenum" value="' + teams + '" id="radio' + teams + '" onChange="radio(' + teams + ');return false;"> Team Name: <input type="text" id="team_name' + teams + '" class="text_change"><input type="hidden" id="team_id' + teams + '"> <a href="#" class="orangeButton" onClick="shade_table(\'#destinationtable' + teams + '\'); return false;">Shade</a> <a href="#" class="redButton" onClick="delete_team(' + teams + '); return false;">Delete Team</a><br></div>';
        new_table_html += '<table id="destinationtable' + teams + '" class="tablesorter" style="width:75%;margin:auto;" bgcolor="white" onClick="radio(' + teams + ');">';

        new_table_html += '<thead><tr><th>FName<br></th><th>LName</th><th>GP</th><th>FGM</th><th>FGA</th><th>FG%</th><th>FG3M</th><th>FG3A</th><th>FG3%</th><th>FTM</th><th>FTA</th><th>FT%</th><th>REB</th><th>AST</th><th>TO</th><th>STL</th><th>BLK</th><th>PTS</th><th> </th>';

        new_table_html += '<tbody><tr id="dummyNeededForTableSorter"><td colspan="18"></td></tr></tbody></table><input id="team_count' + teams + '" type="text" style="width:20px;text-align:center;"> players';
        new_table_html += '<br><a href="#" id="importButt' + teams + '" class="greenButton" onClick="team_import(' + teams + '); return false;">Import Players</a><br><div id="team_import_div' + teams + '"><textarea id="team_import' + teams + '" style="width:400px;height:100px;" placeholder="Copy and paste from Yahoo!, ESPN, etc. Don\'t worry about extra text."></textarea><br><span id="team_import_checkbox_label' + teams + '"><br><input type="checkbox" id="team_import_checkbox' + teams + '" checked> Remove existing players from team before import</span><br><a class="blackButton" id="team_import_butt' + teams + '" onClick="team_import_spin(' + teams + ');">Import</a></div><br><br></div>';
        $('#dynamic_content').append( new_table_html );
        $('#radio' + teams).trigger('click');

        $("#destinationtable" + teams).tablesorter();
        $("#destinationtable" + teams).trigger("update");

        league_save();

        return false;

    });

    $("#update_season_data").click(function() {

        var timeframe = "";
        var stattype = "";
    
        var selected = $("input[type='radio'][name='data_type']:checked");
        if (selected.length > 0) {
            timeframe = selected.val();
        }
    
        selected = $("input[type='radio'][name='stat_type']:checked");
        if (selected.length > 0) {
            stattype = selected.val();
        }

        load_scoreboard(timeframe, stattype);

        load_existing_teams();

        update_league_prefs(timeframe, stattype);

        //$("#league_save").trigger("click"); 
        //league_save();
        //location.href = "league.php";
  
    });

    // OnClick for players add/remove
    $( "#sourcetable tbody tr" ).on( "click", function( event ) {

        var tablenum = $("input[name=tablenum]:checked").val();

        if (tablenum == undefined) { return; }

        var ok = 0;
        var theid = $( this ).attr('id');    
        var newaddedrows = new Array();
         
        // check if player exists on a team already
        for (index = 0; index < addedrows.length; ++index) {
            if (addedrows[index] == theid) {
                $( this ).css( "background-color", "#ffffff" );
                // remove from dest table :
                var tr = $( "#dest" + theid );
                // if row to be removed is only row in table - add dummy
                if ( (typeof tr.prev().attr('id') == 'undefined') && (typeof tr.next().attr('id') == 'undefined') ) {
                    tr.after('<tr id="dummyNeededForTableSorter"><td colspan="18"></td></tr>');
                }
                tr.css("background-color","#FF3700");
                tr.fadeOut(400, function(){
                    player_del_save(tablenum, theid, false);
                    tr.remove();
                });
                //the boolean
                ok = 1;
            } 
            else {
                // add row to array
                newaddedrows.push(addedrows[index]);
            } 
        }   
        addedrows = newaddedrows;
        // if no match found then add the row :
        if (!ok) {

            console.log("calling player_add_save with " + tablenum + " and " + theid);
            player_add_save(tablenum, theid, false);
            addedrows.push( theid );
            //console.log(this);
            $( this ).css( "background-color", "#cacaca" );
            // if table is empty and this is the first row being added set flag to remove dummy row
            f = 'O';
            if ( $('#destinationtable' + tablenum + ' tr:last').attr('id') == 'dummyNeededForTableSorter' ) { f = 'D'; rtd = $('#destinationtable' + tablenum + ' tr:last'); }
            $('#destinationtable' + tablenum + ' tr:last').after('<tr id="dest' + theid + '"><td>'
                                           + $(this).find("td").eq(0).html() + '</td><td>'
                                           + $(this).find("td").eq(1).html() + '</td><td>'
                                           + $(this).find("td").eq(2).html() + '</td><td>'
                                           + $(this).find("td").eq(3).html() + '</td><td>'
                                           + $(this).find("td").eq(4).html() + '</td><td>'
                                           + $(this).find("td").eq(5).html() + '</td><td>'
                                           + $(this).find("td").eq(6).html() + '</td><td>'
                                           + $(this).find("td").eq(7).html() + '</td><td>'
                                           + $(this).find("td").eq(8).html() + '</td><td>'
                                           + $(this).find("td").eq(9).html() + '</td><td>'
                                           + $(this).find("td").eq(10).html() + '</td><td>'
                                           + $(this).find("td").eq(11).html() + '</td><td>'
                                           + $(this).find("td").eq(12).html() + '</td><td>'
                                           + $(this).find("td").eq(13).html() + '</td><td>'
                                           + $(this).find("td").eq(14).html() + '</td><td>'
                                           + $(this).find("td").eq(15).html() + '</td><td>'
                                           + $(this).find("td").eq(16).html() + '</td><td>'
                                           + $(this).find("td").eq(17).html() + '</td><td style=\'color:red;\'>'
                                           + 'drop' + '</td></tr>');         

            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(2).prop('title', $(this).find("td").eq(2).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(3).prop('title', $(this).find("td").eq(3).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(4).prop('title', $(this).find("td").eq(4).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(5).prop('title', $(this).find("td").eq(5).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(6).prop('title', $(this).find("td").eq(6).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(7).prop('title', $(this).find("td").eq(7).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(8).prop('title', $(this).find("td").eq(8).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(9).prop('title', $(this).find("td").eq(9).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(10).prop('title', $(this).find("td").eq(10).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(11).prop('title', $(this).find("td").eq(11).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(12).prop('title', $(this).find("td").eq(12).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(13).prop('title', $(this).find("td").eq(13).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(14).prop('title', $(this).find("td").eq(14).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(15).prop('title', $(this).find("td").eq(15).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(16).prop('title', $(this).find("td").eq(16).prop('title'));
            $('#destinationtable' + tablenum + ' tr:last').find("td").eq(17).prop('title', $(this).find("td").eq(17).prop('title'));

            // remove dummy row
            if ( f == 'D' ) { rtd.remove(); f = 'O'; }

            // drop a player from existing team
            $("#dest" + theid).find("td").eq(18).on( "click", function( event ) {
                $('#radio' + tablenum).trigger('click');
                $( '#' + theid ).trigger('click');
                $( '#team_count' + tablenum ).val( $('#destinationtable' + tablenum + ' tr').length - 2 );
                //$( "#league_save" ).trigger("click"); 
                //league_save(); 
            });
            
            $( '#team_count' + tablenum ).val( $('#destinationtable' + tablenum + ' tr').length - 1 );
            $( "#destinationtable" + tablenum ).trigger("update");

        }

    });

    $(".text_change").on('change', function (){
        var textvalue = $(this).val(); // this.value
        console.log(textvalue);
        console.log($(this));
        console.log($(this)[0].id);

        var tablenum = $(this)[0].id.replace( /^\D+/g, ''); // replace all leading non-digits with nothing

        console.log("#team_id" + tablenum);
        console.log($("#team_id" + tablenum).val());

        $.ajax({ 
            url: 'update_team_name.php',
            data: { team_name: textvalue, team_id: $("#team_id" + tablenum).val() },
            type: 'post'
        }).done(function(responseData) {
            console.log('Done: ', responseData);
        }).fail(function() {
            console.log('Failed');
        });

    });

    $(".text_change").on('change', function (){



    });

<?php

function  cell_color_func($val, $qual) {

  global $stat;

  if ($stat == 2) {
    if ($qual == 'N') { return "#ffffff"; }
    if     ($val <= 50) { return "#009900"; }
    elseif ($val <= 100) { return "#99ff33"; }
    elseif ($val <= 150) { return "#FFFF00"; }
    elseif ($val <= 200) { return "#ff704d"; }
    else { return "#ff3300"; }
  }
  else {
    if ($qual == 'N') { return "#ffffff"; }
    if ($val >= 80) { return "#009900"; }
    if ($val >= 60) { return "#99ff33"; }
    if ($val >= 40) { return "#FFFF00"; }
    if ($val >= 20) { return "#ff704d"; }
    else { return "#ff3300"; }
  }
}


  $team_add_str = "";
  if (isset($_SESSION["userid"]) && isset($_SESSION["league_id"])) { 
    $league_id = $_SESSION["league_id"]; 
 
    // EXISTING TEAMS AND PLAYERS 
    if ($stat == 2) {

      $sql = "
        SELECT league.name lg_name, team.id, team.name, team_members.pid,a.fname, a.lname, b.gp AS gp, a.gp AS a_gp, b.min, a.min AS a_min, b.fgm, a.fgm AS a_fgm, b.fga, a.fga AS a_fga, 
               b.fg_pct, a.fg_pct AS a_fg_pct, b.fg3m, a.fg3m AS a_fg3m, b.fg3a, a.fg3a AS a_fg3a, b.fg3_pct, a.fg3_pct AS a_fg3_pct, b.ftm, a.ftm AS a_ftm, b.fta, a.fta AS a_fta, b.ft_pct, 
               a.ft_pct AS a_ft_pct, b.reb, a.reb AS a_reb, b.ast, a.ast AS a_ast, b.tov, a.tov AS a_tov, b.stl, a.stl AS a_stl, b.blk, a.blk AS a_blk, b.pts, a.pts AS a_pts

        FROM league
        LEFT OUTER JOIN team ON league.id = team.league_id
        LEFT OUTER JOIN team_members ON team_members.team_id = team.id
        LEFT OUTER JOIN $table a ON a.pid = team_members.pid
        LEFT OUTER JOIN $rk_table b ON b.pid = team_members.pid

        WHERE league.id = (
            SELECT id
            FROM league
            WHERE user_id=" . $_SESSION["userid"] . "
            AND id =  '" . $league_id . "' )
        ORDER BY id, a_pts desc, a_reb desc, a_ast desc
      ";
    }
    else {

      $sql = "
        SELECT league.name lg_name, team.id, team.name, team_members.pid, a.pid, a.fname, a.lname, round(a.gp/maxt.gp*100) as gp, a.gp as a_gp, round(a.min/maxt.min*100) as min, a.min as a_min, 
               round(a.fgm/maxt.fgm*100) as fgm, a.fgm as a_fgm, round(a.fga/maxt.fga*100) as fga, a.fga as a_fga, round((a.fg_pct - maxt.fg_pct_min)/(maxt.fg_pct - maxt.fg_pct_min)*100) as fg_pct, 
               a.fg_pct as a_fg_pct, round(a.fg3m/maxt.fg3m*100) as fg3m, a.fg3m as a_fg3m, round(a.fg3a/maxt.fg3a*100) as fg3a, a.fg3a as a_fg3a, round(a.fg3_pct/maxt.fg3_pct*100) as fg3_pct, 
               a.fg3_pct as a_fg3_pct, round(a.ftm/maxt.ftm*100) as ftm, a.ftm as a_ftm, round(a.fta/maxt.fta*100) as fta, a.fta as a_fta, 
               round((a.ft_pct - maxt.ft_pct_min)/(maxt.ft_pct - maxt.ft_pct_min)*100) as ft_pct, a.ft_pct as a_ft_pct, round(a.reb/maxt.reb*100) as reb, a.reb as a_reb, round(a.ast/maxt.ast*100) as ast, 
               a.ast as a_ast, round(a.tov/maxt.tov*100) as tov, a.tov as a_tov, round(a.stl/maxt.stl*100) as stl, a.stl as a_stl, round(a.blk/maxt.blk*100) as blk, a.blk as a_blk, 
               round(a.pts/maxt.pts*100) as pts, a.pts as a_pts 

        FROM league
        LEFT OUTER JOIN team ON league.id = team.league_id
        LEFT OUTER JOIN team_members ON team_members.team_id = team.id
        LEFT OUTER JOIN $table a ON a.pid = team_members.pid,
        (SELECT max(gp) as gp, max(min) as min, max(fgm) as fgm, max(fga) as fga, (select max(fg_pct) from $table where fga > 5) as fg_pct, (select min(fg_pct) from $table where fga > 5) as fg_pct_min, 
                 max(fg3m) as fg3m, max(fg3a) as fg3a, (select max(fg3_pct) from $table where fg3m > 1) as fg3_pct, max(ftm) as ftm, max(fta) as fta, (select max(ft_pct) from $table where fta > 2) as ft_pct,
                 (select min(ft_pct) from $table where fta > 2) as ft_pct_min, max(reb) as reb,max(ast) as ast, max(tov) as tov, max(stl) as stl, max(blk) as blk, max(pts) as pts FROM $table
        ) as maxt 

        WHERE league.id = (
            SELECT id
            FROM league
            WHERE user_id=" . $_SESSION["userid"] . "
            AND id =  '" . $league_id . "' ) 
        order by id, a_pts desc, a_reb desc, a_ast desc";
    }
  
    error_log($sql);
  
    $prev_team = 0;
    $curr_team = 0;
    $tablenum = 0;
    $roster_slots = 0;
    $league_name = "League Name";
    foreach ($conn->query($sql) as $row) {
      if (!is_null($row['name'])) {
        $name = $row['name']; 
        $curr_team = $row['id'];
  
        if ($tablenum == 0) { 
          $league_name = $row['lg_name']; 
        }
        elseif ($curr_team != $prev_team) {
          $team_add_str .= "</tbody></table>
            <input id='team_count$tablenum' type='text' style='width:20px;text-align:center;' value='$roster_slots'> players
            <br><a href='#' id='importButt$tablenum' class=\"greenButton\" onClick='team_import($tablenum);return false;'>Import Players</a><br><div id='team_import_div$tablenum' style='display:none;'><textarea id='team_import$tablenum' style='width:400px;height:100px;'
            placeholder='Copy and paste from Yahoo!, ESPN, etc. Dont worry about extra text.'></textarea><br><span id='team_import_checkbox_label$tablenum'><br><input type='checkbox' id='team_import_checkbox$tablenum' checked>
            Remove existing players from team before import</span><br><a class='blackButton' id='team_import_butt$tablenum' onClick='team_import_spin($tablenum);'>
            Import</a></div><br><br></div>
          ";
          $roster_slots = 0;
        }
  
        if ($curr_team != $prev_team) {
          $team_slots = 0;
          $tablenum++;
          echo "\n";
  
          $team_add_str .= "
            <div id='div$tablenum' style='margin:auto;width:100%' onClick='radio($tablenum);'><div id='divhilite$tablenum' style='margin:auto;width:65%'><input type='radio' name='tablenum' value='$tablenum' id='radio$tablenum' onChange='radio($tablenum);return false'> Team Name: 
            <input type='text' id='team_name$tablenum' value=\"$name\" class='text_change'> 
            <input type='hidden' id='team_id$tablenum' value='$curr_team'>
            <a href='#' class=\"orangeButton\" onClick=\"shade_table('#destinationtable$tablenum');return false;\">Shade</a>
            <a href='#' class=\"redButton\" onClick=\"delete_team('$tablenum');return false;\">Delete Team</a><br></div>
            <table id='destinationtable$tablenum' class='tablesorter' style='width:75%;margin:auto;' bgcolor='white' onClick='radio($tablenum);'>
            <thead><tr><th>FName<br></th><th>LName</th><th>GP</th><th>FGM</th><th>FGA</th><th>FG%</th><th>FG3M</th><th>FG3A</th><th>FG3%</th><th>FTM</th><th>FTA</th><th>FT%</th><th>REB</th><th>AST</th><th>TO</th><th>STL</th>
                       <th>BLK</th><th>PTS</th><th> </th>
            <tbody>";
        }
 
        if (!is_null($row['pid'])) {
          echo "addedrows.push( " . $row['pid'] . " );";
   
          $title_prefix = "";
          $value_prefix = "";
   
          if ($stat == 0) { $value_prefix = "a_"; $tov = $row['a_tov']; $t_tov = 100 - $row['tov']; $r_tov = $t_tov; }
          if ($stat == 1)  { $title_prefix = "a_"; $t_tov = $row['a_tov']; $tov = 100 - $row['tov']; $r_tov = $tov; }
          if ($stat == 2) { $title_prefix = "a_"; $t_tov = $row['a_tov']; $tov = $row['tov']; $r_tov = $tov; }
    
          $fg_pct_qual  = 'N';
          $ft_pct_qual  = 'N';
          $fg3_pct_qual = 'N';
    
          if ($row['a_fga'] > 5) { $fg_pct_qual = 'Y'; }
          if ($row['a_fta'] > 2) { $ft_pct_qual = 'Y'; }
          if ($row['a_fg3m'] > 1)  { $fg3_pct_qual = 'Y'; }
    
          $team_add_str .= "<tr id='dest" . $row['pid'] . "'><td>" . $row['fname'] . "</td><td>" . $row['lname'] . "</td><td title='". $row[$title_prefix . 'gp']  . "'>" . $row[$value_prefix . 'gp'] . "</td>";
          $team_add_str .= "<td title='". $row[$title_prefix . 'fgm'] . "'>" . $row[$value_prefix . 'fgm'] . "</td><td title='". $row[$title_prefix . 'fga'] . "'>" . $row[$value_prefix . 'fga'] . "</td>";
          $team_add_str .= "<td title='". $row[$title_prefix . 'fg_pct'] . "'";
          if (strpos($ignore,'0') === false) { $team_add_str .= " style='background-color:" . cell_color_func($row['fg_pct'], $fg_pct_qual) . "'"; }
          $team_add_str .= ">" . $row[$value_prefix . 'fg_pct'] . "</td><td title='". $row[$title_prefix . 'fg3m'] . "'";
          if (strpos($ignore,'1') === false) { $team_add_str .=" style='background-color:" . cell_color_func($row['fg3m'], 'Y') . "'"; }
          $team_add_str .= ">" . $row[$value_prefix . 'fg3m'] . "</td><td title='". $row[$title_prefix . 'fg3a'] . "'>" . $row[$value_prefix . 'fg3a'] . "</td>";
          $team_add_str .= "<td title='". $row[$title_prefix . 'fg3_pct'] . "'>" . $row[$value_prefix . 'fg3_pct'] . "</td><td title='". $row[$title_prefix . 'ftm'] . "'>" . $row[$value_prefix . 'ftm'] . "</td>";
          $team_add_str .= "<td title='". $row[$title_prefix . 'fta'] . "'>" . $row[$value_prefix . 'fta'] . "</td><td title='". $row[$title_prefix . 'ft_pct'] . "'";
          if (strpos($ignore,'2') === false) { $team_add_str .=" style='background-color:" . cell_color_func($row['ft_pct'], $ft_pct_qual) . "'"; }
          $team_add_str .= ">" . $row[$value_prefix . 'ft_pct'] . "</td><td title='". $row[$title_prefix . 'reb'] . "'";
          if (strpos($ignore,'3') === false) { $team_add_str .=" style='background-color:" . cell_color_func($row['reb'], 'Y') . "'"; }
          $team_add_str .= ">" . $row[$value_prefix . 'reb'] . "</td><td title='". $row[$title_prefix . 'ast'] . "'";
          if (strpos($ignore,'4') === false) { $team_add_str .=" style='background-color:" . cell_color_func($row['ast'], 'Y') . "'"; }
          $team_add_str .= ">" . $row[$value_prefix . 'ast'] . "</td><td title='". $t_tov . "'";
          if (strpos($ignore,'5') === false) { $team_add_str .=" style='background-color:" . cell_color_func($r_tov, 'Y') . "'"; }
          $team_add_str .= ">" . $tov . "</td><td title='". $row[$title_prefix . 'stl'] . "'";
          if (strpos($ignore,'6') === false) { $team_add_str .=" style='background-color:" . cell_color_func($row['stl'], 'Y') . "'"; }
          $team_add_str .= ">" . $row[$value_prefix . 'stl'] . "</td><td title='". $row[$title_prefix . 'blk'] . "'";
          if (strpos($ignore,'7') === false) { $team_add_str .=" style='background-color:" . cell_color_func($row['blk'], 'Y') . "'"; }
          $team_add_str .= ">" . $row[$value_prefix . 'blk'] . "</td><td title='". $row[$title_prefix . 'pts'] . "'";
          if (strpos($ignore,'8') === false) { $team_add_str .=" style='background-color:" . cell_color_func($row['pts'], 'Y') . "'"; }
          $team_add_str .= ">" . $row[$value_prefix . 'pts'] . "</td><td style='color:red;' onClick=\"$('#radio$tablenum').trigger('click');$('#" . $row['pid'] . "').trigger('click');$('#team_count$tablenum').val( $('#destinationtable$tablenum tr').length - 2 );\">drop</td></tr>"; 
    
          echo "\$('#" . $row['pid'] . "').css('background-color', '#cacaca');";
  
        }
        else {
          $team_add_str .= '<tr id="dummyNeededForTableSorter"><td colspan="18"></td></tr>';
        }
  
        $prev_team = $curr_team;
  
        echo "$('#destinationtable$tablenum').tablesorter();";
  
        $roster_slots++;
        $team_slots++;
      }
    }
  
    // AFTER LOOP FOR ALL TEAMS, SHADE FINAL TEAM AND SCOREBOARD
    if ($tablenum > 0) { 
        $team_add_str .= "</tbody></table>
          <input id='team_count$tablenum' type='text' style='width:20px;text-align:center;' value='$roster_slots'> players
          <br><a href='#' class='greenButton' onClick='team_import($tablenum);return false;'>Import Players</a><br><div id='team_import_div$tablenum' style='display:none;'><textarea id='team_import$tablenum' style='width:400px;height:100px;'
          placeholder='Copy and paste from Yahoo!, ESPN, etc. Dont worry about extra text.'></textarea><br><span id='team_import_checkbox_label$tablenum'><br><input type='checkbox' id='team_import_checkbox$tablenum' checked>
          Remove existing players from team before import</span><br><a class='blackButton' id='team_import_butt$tablenum' onClick='team_import_spin($tablenum);'>
          Import</a></div><br><br></div>
        ";
      //echo "console.log(addedrows);";
      echo "teams = $tablenum;";
      //echo "shade_table( '#destinationtable$tablenum' );"; 
      echo "shade_scoreboard();"; 
    }
  }
?>

});  

</script>

</head>

<body>
<?php 
  include 'menu.php';
?>
<div id="spinnerContainer" style="position:fixed;top:50%;left:50%;z-index:5;"></div>
<br><br>

<div id="dynamic_content" style="text-align:center;">
    <div style="border-style:solid;width:300px;margin:auto;background:white;"><br>
      <b>2015-16 NBA Fantasy</b><br>
      <br>League Name: <input type="text" id="league_name" value="<?php echo $league_name; ?>"><br>
         <br>Time: <input name="data_type" type="radio" value="0"> Season 
                   <input name="data_type" type="radio" value="1" title="Show data from only the player's previous 5 games."> Last 5 
                   <input name="data_type" type="radio" value="2" title="Show data from only the player's previous 10 games."> Last 10<br><br>
      <hr style="width:75%;margin:auto;">
      <br>Values: <input name="stat_type" type="radio" value="0" title="Per game averages."> Average 
                  <input name="stat_type" type="radio" value="1" title="Value between 0 - 100. See FAQ for more info."> Rating 
                  <input name="stat_type" type="radio" value="2" title="Ranking of per game averages."> Ranking <br><br>
      <hr style="width:75%;margin:auto;">
      <a href="#" onClick="$('#advanced').toggle();">Advanced >></a>
      <div id="advanced" style="display:none;">
      <br>Ignore: <input id="ignore0" type="checkbox" value="0" title="Field goal percentage"> FG%
                  <input id="ignore1" type="checkbox" value="1" title="3 point field goals made"> FG3M
                  <input id="ignore2" type="checkbox" value="2" title="Free throw percentage"> FT%<br>
             <br> <input id="ignore3" type="checkbox" value="3" title="Rebounds"> REB
                  <input id="ignore4" type="checkbox" value="4" title="Assists"> AST
                  <input id="ignore5" type="checkbox" value="5" title="Turnovers"> TO<br>
             <br> <input id="ignore6" type="checkbox" value="6" title="Steals"> STL
                  <input id="ignore7" type="checkbox" value="7" title="Blocks"> BLK
                  <input id="ignore8" type="checkbox" value="8" title="Points"> PTS<br><br>
      </div>
      <hr style="width:75%;margin:auto;"><br>
        <a id='update_season_data' class='blueButton'>Update</a><br><br>
  
    </div>
    <br><br>
    <div style="border-style:solid;width:55%;margin:auto;background:#9acc85;padding:5px;">
      <a href='sync.php?lid=<?php echo $_SESSION["league_id"]; ?>'><span style="font-size:16px;font-weight:bold;color:blue;"> << Copy rosters from your Yahoo! Fantasy League >> </span></a>

    </div>	
    <?php if (isset($_SESSION['league_id'])) { ?>

<?php

/* SCOREBOARD SECTION */

  $sql = "
          SELECT t.id, name, count(id) as cnt, IFNULL(round(avg(gp),2),0) as gp, IFNULL(round(avg(fgm),2),0) as fgm, IFNULL(round(avg(fga),2),0) as fga, 
                           IFNULL(round(sum(fgm)/sum(fga)*100,2),0) as fg_pct, IFNULL(round(avg(fg3m),2),0) as fg3m,
                           IFNULL(round(avg(fg3a),2),0) as fg3a, IFNULL(round(sum(fg3m)/sum(fg3a),2),0) as fg3_pct, IFNULL(round(avg(ftm),2),0) as ftm, 
                           IFNULL(round(avg(fta),2),0) as fta, IFNULL(round(sum(ftm)/sum(fta)*100,2),0) as ft_pct,
                           IFNULL(round(avg(reb),2),0) as reb, IFNULL(round(avg(ast),2),0) as ast, IFNULL(round(avg(tov),2),0) as tov, 
                           IFNULL(round(avg(stl),2),0) as stl, IFNULL(round(avg(blk),2),0) as blk, IFNULL(round(avg(pts),2),0) as pts
          FROM team t left outer join team_members tm on t.id = tm.team_id
                      left outer join $table p on tm.pid = p.pid
          WHERE t.league_id = " . $_SESSION["league_id"] . "
          GROUP BY t.id
  ";

  error_log("league.php - sql from SCOREBOARD SECTION = " . $sql);

  $sth = $conn->prepare($sql);
  $sth->execute();

  $result = $sth->fetchAll(); 

  if (count($result) > 0) {
  ?>

  <br>
  Scoreboard: <br>(Average per player on each team)<br>
  <a href="#" class="orangeButton" onClick="shade_scoreboard(); return false;">Shade</a><br>
 
<table id="scoreboard" class="tablesorter" style="width:75%;margin:auto">
    <thead>
        <tr>
          <th>Team Name</th>
          <th title="This value is the average rank per team for the 9 categories. The best possible value would be a '1' where one team leads every category.">AVG RK</th>
          <th>GP</th>
          <th>FGM</th>
          <th>FGA</th>
          <th>FG%</th>
          <th>FG3M</th>
          <th>FG3A</th>
          <th>FG3%</th>
          <th>FTM</th>
          <th>FTA</th>
          <th>FT%</th>
          <th>REB</th>
          <th>AST</th>
          <th>TO</th>
          <th>STL</th>
          <th>BLK</th>
          <th>PTS</th>
        </tr>
    </thead>
    <tbody id='scoreboard_tbody'>
<?php

  }

  $fg_pct_arr = array();
  $fg3m_arr = array();
  $ft_pct_arr = array();
  $reb_arr = array();
  $ast_arr = array();
  $tov_arr = array();
  $stl_arr = array();
  $blk_arr = array();
  $pts_arr = array();

  foreach ($result as $row) {

    array_push($fg_pct_arr, $row['fg_pct']);
    array_push($fg3m_arr,   $row['fg3m']);
    array_push($ft_pct_arr, $row['ft_pct']);
    array_push($reb_arr,    $row['reb']);
    array_push($ast_arr,    $row['ast']);
    array_push($tov_arr,    $row['tov']);
    array_push($stl_arr,    $row['stl']);
    array_push($blk_arr,    $row['blk']);
    array_push($pts_arr,    $row['pts']);

  }

  rsort($fg_pct_arr);
  rsort($fg3m_arr);
  rsort($ft_pct_arr);
  rsort($reb_arr);
  rsort($ast_arr);
  sort ($tov_arr);
  rsort($stl_arr);
  rsort($blk_arr);
  rsort($pts_arr);

  //$row_cnt = 1;

  foreach ($result as $idx=>$row) {

    $idx++;

    $fg_pct_rk = array_search($row['fg_pct'], $fg_pct_arr) + 1;
    $fg3m_rk   = array_search($row['fg3m'], $fg3m_arr) + 1;
    $ft_pct_rk = array_search($row['ft_pct'], $ft_pct_arr) + 1;
    $reb_rk =    array_search($row['reb'], $reb_arr) + 1;
    $ast_rk =    array_search($row['ast'], $ast_arr) + 1;
    $tov_rk =    array_search($row['tov'], $tov_arr) + 1;
    $stl_rk =    array_search($row['stl'], $stl_arr) + 1;
    $blk_rk =    array_search($row['blk'], $blk_arr) + 1;
    $pts_rk =    array_search($row['pts'], $pts_arr) + 1;

    $c = 0;
    $avg_rk = 0;
    if (strlen($ignore) == 0) {
      $avg_rk = round(($fg_pct_rk + $fg3m_rk + $ft_pct_rk + $reb_rk + $ast_rk + $tov_rk + $stl_rk + $blk_rk + $pts_rk)/9, 2);
    }
    else {
      if (strpos($ignore, '0') === false) {
        $c++;
        $avg_rk += $fg_pct_rk;
      }
      if (strpos($ignore, '1') === false) {
        $c++;
        $avg_rk += $fg3m_rk;
      }
      if (strpos($ignore, '2') === false) {
        $c++;
        $avg_rk += $ft_pct_rk;
      }
      if (strpos($ignore, '3') === false) {
        $c++;
        $avg_rk += $reb_rk;
      }
      if (strpos($ignore, '4') === false) {
        $c++;
        $avg_rk += $ast_rk;
      }
      if (strpos($ignore, '5') === false) {
        $c++;
        $avg_rk += $tov_rk;
      }
      if (strpos($ignore, '6') === false) {
        $c++;
        $avg_rk += $stl_rk;
      }
      if (strpos($ignore, '7') === false) {
        $c++;
        $avg_rk += $blk_rk;
      }
      if (strpos($ignore, '8') === false) {
        $c++;
        $avg_rk += $pts_rk;
      }
      $avg_rk = round($avg_rk/$c, 2);
    }

    echo "<tr style='background-color:white;'><td title='Team Name (Roster Size)'><a href='#' style='color:blue;' onClick='scrollToTeam(" . $idx . ");'><b>" . $row['name'] . " (" . $row['cnt'] . ") </b></a></td><td>" . sprintf("%1\$.2f", $avg_rk) . "</td><td>" . $row['gp'] . "</td><td>" . $row['fgm'] . "</td><td>" . $row['fga'] . "</td>
          <td>" . $row['fg_pct'] . "<br>(" . $fg_pct_rk . ")</td><td>" . $row['fg3m'] . "<br>(" . $fg3m_rk . ")</td><td>" . $row['fg3a'] . "</td><td>" . $row['fg3_pct'] . "</td>
          <td>" . $row['ftm'] . "</td><td>" . $row['fta'] . "</td><td>" . $row['ft_pct'] . "<br>(" . $ft_pct_rk . ")</td><td>" . $row['reb'] . "<br>(" . $reb_rk . ")</td>
          <td>" . $row['ast'] . "<br>(" . $ast_rk . ")</td><td>" . $row['tov'] . "<br>(" . $tov_rk . ")</td><td>" . $row['stl'] . "<br>(" . $stl_rk . ")</td><td>" . $row['blk'] . "<br>(" . $blk_rk . ")</td>
          <td>" . $row['pts'] . "<br>(" . $pts_rk . ")</td></tr>";

  }

}

?>
    </tbody>
</table><br><br>
<?php echo $team_add_str; ?>
</div>
<div style='text-align:center'>
  <a href='#' class='skyBlueButton' id='team_add' style='text-align:center'>Add Team</a><br><br><br>
  <a href="#" class="orangeButton" onClick="shade_table('#sourcetable'); return false;">Shade</a> <br>
</div>

<div class="narrow-block wrapper">
<table id="sourcetable" class="tablesorter">
    <thead>
      <tr>
        <th>FName</th>
        <th>LName</th>
        <th>GP</th>
        <th>FGM</th>
        <th>FGA</th>
        <th>FG%</th>
        <th>FG3M</th>
        <th>FG3A</th>
        <th>FG3%</th>
        <th>FTM</th>
        <th>FTA</th>
        <th>FT%</th>
        <th>REB</th>
        <th>AST</th>
        <th>TO</th>
        <th>STL</th>
        <th>BLK</th>
        <th>PTS</th>
      </tr>
    </thead>
 
    <tbody>
<?php



$servername = "localhost";
$username = "root";
$password = "";
$dbname = "nba";

try {
  $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
  // set the PDO error mode to exception
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
#  echo "Connected successfully";
}
catch(PDOException $e) {
#  echo "Connection failed: " . $e->getMessage();
}

if ($stat == 2) {

  $sql = "
SELECT a.pid, a.fname, a.lname, b.gp AS gp, a.gp AS a_gp, b.min, a.min AS a_min, b.fgm, a.fgm AS a_fgm, b.fga, a.fga AS a_fga, b.fg_pct, a.fg_pct AS a_fg_pct, b.fg3m, a.fg3m AS a_fg3m, b.fg3a, a.fg3a AS a_fg3a, b.fg3_pct, a.fg3_pct AS a_fg3_pct, b.ftm, a.ftm AS a_ftm, b.fta, a.fta AS a_fta, b.ft_pct, a.ft_pct AS a_ft_pct, b.reb, a.reb AS a_reb, b.ast, a.ast AS a_ast, b.tov, a.tov AS a_tov, b.stl, a.stl AS a_stl, b.blk, a.blk AS a_blk, b.pts, a.pts AS a_pts
FROM $table a, $rk_table b
WHERE a.pid = b.pid
ORDER BY a_pts DESC
";

}

else {

  $sql = "
select a.pid, a.fname, a.lname, round(a.gp/maxt.gp*100) as gp, a.gp as a_gp, round(a.min/maxt.min*100) as min, a.min as a_min, round(a.fgm/maxt.fgm*100) as fgm, a.fgm as a_fgm, round(a.fga/maxt.fga*100) as fga, a.fga as a_fga, round((a.fg_pct - maxt.fg_pct_min)/(maxt.fg_pct - maxt.fg_pct_min)*100) as fg_pct, a.fg_pct as a_fg_pct, round(a.fg3m/maxt.fg3m*100) as fg3m, a.fg3m as a_fg3m, round(a.fg3a/maxt.fg3a*100) as fg3a, a.fg3a as a_fg3a, round(a.fg3_pct/maxt.fg3_pct*100) as fg3_pct, a.fg3_pct as a_fg3_pct, round(a.ftm/maxt.ftm*100) as ftm, a.ftm as a_ftm, round(a.fta/maxt.fta*100) as fta, a.fta as a_fta, round((a.ft_pct - maxt.ft_pct_min)/(maxt.ft_pct - maxt.ft_pct_min)*100) as ft_pct, a.ft_pct as a_ft_pct, round(a.reb/maxt.reb*100) as reb, a.reb as a_reb, round(a.ast/maxt.ast*100) as ast, a.ast as a_ast, round(a.tov/maxt.tov*100) as tov, a.tov as a_tov, round(a.stl/maxt.stl*100) as stl, a.stl as a_stl, round(a.blk/maxt.blk*100) as blk, a.blk as a_blk, round(a.pts/maxt.pts*100) as pts, a.pts as a_pts from $table a,
(SELECT max(gp) as gp,max(min) as min,max(fgm) as fgm,max(fga) as fga,(select max(fg_pct) from $table where fga > 5) as fg_pct,(select min(fg_pct) from $table where fga > 5) as fg_pct_min,max(fg3m) as fg3m,max(fg3a) as fg3a,(select max(fg3_pct) from $table where fg3m > 1) as fg3_pct,max(ftm) as ftm,max(fta) as fta, (select max(ft_pct) from $table where fta > 2) as ft_pct,(select min(ft_pct) from $table where fta > 2) as ft_pct_min, max(reb) as reb,max(ast) as ast,max(tov) as tov,max(stl) as stl,max(blk) as blk,max(pts) as pts FROM $table) as maxt order by a_pts desc, a_reb desc, a_ast desc
";

}

  $return_arr = array();

  foreach ($conn->query($sql) as $row) {

    $fg_pct_qual  = 'N';
    $ft_pct_qual  = 'N';
    $fg3_pct_qual = 'N'; 

    echo "<tr height='25' id='" . $row['pid'] . "'>";
    echo "<td>" . $row['fname'] . "</td>";
    echo "<td>" . $row['lname'] . "</td>";

    $title_prefix = "a_";
    $value_prefix = "";
    if ($stat == 0) { $title_prefix = ""; $value_prefix = "a_"; $tov = $row['a_tov']; $t_tov = 100 - $row['tov']; $r_tov = $t_tov; }
    if ($stat == 1)  { $t_tov = $row['a_tov']; $tov = 100 - $row['tov']; $r_tov = $tov; }
    if ($stat == 2) { $t_tov = $row['a_tov']; $tov = $row['tov']; $r_tov = $tov; }

    if ($row['a_fga'] > 5) { $fg_pct_qual = 'Y'; }
    if ($row['a_fta'] > 2) { $ft_pct_qual = 'Y'; }
    if ($row['a_fg3m'] > 1)  { $fg3_pct_qual = 'Y'; }

    echo "<td title='". $row[$title_prefix . 'gp']  . "'>" . $row[$value_prefix . 'gp'] . "</td>";
    echo "<td title='". $row[$title_prefix . 'fgm'] . "'>" . $row[$value_prefix . 'fgm'] . "</td>";
    echo "<td title='". $row[$title_prefix . 'fga'] . "'>" . $row[$value_prefix . 'fga'] . "</td>";

    echo "<td title='". $row[$title_prefix . 'fg_pct'] . "'";
      if (strpos($ignore,'0') === false) { echo " style='background-color:" . cell_color_func($row['fg_pct'], $fg_pct_qual) . "'"; }
    echo ">" . $row[$value_prefix . 'fg_pct'] . "</td>";

    echo "<td title='". $row[$title_prefix . 'fg3m'] . "'";
      if (strpos($ignore,'1') === false) { echo " style='background-color:" . cell_color_func($row['fg3m'], 'Y') . "'"; }
    echo ">" . $row[$value_prefix . 'fg3m'] . "</td>";

    echo "<td title='". $row[$title_prefix . 'fg3a'] . "'>" . $row[$value_prefix . 'fg3a'] . "</td>";
    echo "<td title='". $row[$title_prefix . 'fg3_pct'] . "'>" . $row[$value_prefix . 'fg3_pct'] . "</td>";
    echo "<td title='". $row[$title_prefix . 'ftm'] . "'>" . $row[$value_prefix . 'ftm'] . "</td>";
    echo "<td title='". $row[$title_prefix . 'fta'] . "'>" . $row[$value_prefix . 'fta'] . "</td>";

    echo "<td title='". $row[$title_prefix . 'ft_pct'] . "'";
      if (strpos($ignore,'2') === false) { echo " style='background-color:" . cell_color_func($row['ft_pct'], $ft_pct_qual) . "'"; }
    echo ">" . $row[$value_prefix . 'ft_pct'] . "</td>";

    echo "<td title='". $row[$title_prefix . 'reb'] . "'";
      if (strpos($ignore,'3') === false) { echo " style='background-color:" . cell_color_func($row['reb'], 'Y') . "'"; }
    echo ">" . $row[$value_prefix . 'reb'] . "</td>";

    echo "<td title='". $row[$title_prefix . 'ast'] . "'";
      if (strpos($ignore,'4') === false) { echo " style='background-color:" . cell_color_func($row['ast'], 'Y') . "'"; }
    echo ">" . $row[$value_prefix . 'ast'] . "</td>";

    echo "<td title='". $t_tov . "'";
      if (strpos($ignore,'5') === false) { echo " style='background-color:" . cell_color_func($r_tov, 'Y') . "'"; }
    echo ">" . $tov . "</td>";

    echo "<td title='". $row[$title_prefix . 'stl'] . "'";
      if (strpos($ignore,'6') === false) { echo " style='background-color:" . cell_color_func($row['stl'], 'Y') . "'"; }
    echo ">" . $row[$value_prefix . 'stl'] . "</td>";

    echo "<td title='". $row[$title_prefix . 'blk'] . "'";
      if (strpos($ignore,'7') === false) { echo " style='background-color:" . cell_color_func($row['blk'], 'Y') . "'"; }
    echo ">" . $row[$value_prefix . 'blk'] . "</td>";

    echo "<td title='". $row[$title_prefix . 'pts'] . "'";
      if (strpos($ignore,'8') === false) { echo " style='background-color:" . cell_color_func($row['pts'], 'Y') . "'"; }
    echo ">" . $row[$value_prefix . 'pts'] . "</td></tr>";

  }

?>
    </tbody>
</table>
<br><br>
</div>
<br><br>
</body>
