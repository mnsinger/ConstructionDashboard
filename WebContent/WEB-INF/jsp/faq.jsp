<html>
  <head>
    <title>NBA Fantasy Tools</title>

    <link rel="stylesheet" type="text/css" href="<%=request.getContextPath() %>/CSS/style.css"/>
    <script type="text/javascript" src="<%=request.getContextPath() %>/JS/jquery-2.1.4.min.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath() %>/JS/jquery.tablesorter.min.js"></script>
    <script type="text/javascript" src="<%=request.getContextPath() %>/JS/jquery.dropdownPlain.js"></script>
    <style>
      div.div_faq {
            margin:auto;
            background-color:white;
            max-width:800px;
            text-align:center;
            font-size:24px;
            padding:10px;
            border-style:groove;
            border-color:green;
            vertical-align:text-top;
      }

      ul.ul_faq {
         text-align:left;
         list-style-type: circle;
         font-size:16px;
         max-width:600px;
      }

      blockquote.bq_faq {
         padding-left: 15px;
      }
    </style>

  </head>

<body>
<br><br>
<div class='div_faq'>
  Q: What is the purpose of this site?<br>
  A: <span style="font-size:16px;">I wanted a place where I could take my Yahoo! Fantasy NBA team and ESPN Fantasy NBA team and compare them with the other teams in my league. I also wanted to bone up on my programming skills since I made a career redirection from Oracle DBA to more of a full-stack developer.</span>
</div>  
<br><br>
<div class='div_faq'>
  Q: What are the different menu options?<br>
  A: <img src='images/menu.png' align='top'><br><br>
  <ul class='ul_faq'>
    <li> <b>Add New League:</b> You can save multiple leagues and teams under your username. </li>
    <li> <b>Team Rosters:</b> This page will show all the team rosters for a particular league. </li>
    <li> <b>Matchup:</b> This page shows the expected results of a Head-To-Head matchup between two teams in a league. </li>
    <li> <b>Yahoo! Sync:</b> This page enables realtime sync (pull only) of rosters from a Yahoo! League. This uses OAuth (you won't be asked for your Yahoo! password) and only requires read-only access to your Yahoo! Fantasy League. </li>
  </ul>
</div>  
<br><br>
<div class='div_faq'>
  Q: How are the statistics on the Team Rosters page calculated?<br>
  A: <img src='images/stats.png' align='top'><br><br>
  <ul class='ul_faq'><span style="font-size:18px">Time</span><br>
    <li> <b>Season: </b> Calculate player stats and fantasy team scoreboard based on the entire season's stats.</li>
    <li> <b>Last 5: </b> Calculate player stats and fantasy team scoreboard based on only the last 5 games for each respective player. </li>
    <li> <b>Last 10:</b> Calculate player stats and fantasy team scoreboard based on only the last 10 games for each respective player. </li>
  </ul><br><br>
  <ul class='ul_faq'><span style="font-size:18px">Values</span><br>
    <li> <b>Average: </b> Show player stats as a per game average based on the selected time period (Season, Last 5, Last 10).<br><br></li>
    <li> <b>Rating:  </b> <br><br><blockquote class='bq_faq'><b><i>(For all non-percentage fields [points, rebounds, assists, 3-pointers made, steals, blocks, turnovers, etc.])</i></b> A calculation based as a percentage of the league leader in a given category. For instance, if the league leader is averaging 30 ppg, he would be a 100 for PTS and a player averaging 15 ppg would be a 50, because 15 is 50% of 30.</blockquote> <br><blockquote class='bq_faq'><b><i>(For fg% and ft%)</i></b> A calculation based as a percentage of the league leader, but stretched over the range of values with consideration of the player at the lowest percentage in the league. For example, Jamal Crawford leads the league in FT% at 92.2%, if LeBron James is shooting 72.1%, a regular percentage of the league leader would put him at a rating of 78 (72.1/92.2). However, this is not the best calculation because nobody shoots 0% from the free-throw line. We should also consider the person who is last in the league in free throw percentage (with a qualifying number of attempts) and give him a 0. That would be Andre Drummond at 35.9%. A better calculation for LeBron (and everyone else) would be (LeBron - Min) / (Max - Min) ... (72.1 - 35.9) / (92.2 - 35.9) which would give him a rating of 64. The modified calc would also put Drummond at 0 instead of 39.</blockquote><br><blockquote class='bq_faq'><i>Note on Qualifying attempts: </i> In order to be considered for the percentages of league leader or league lagger (and make a real difference in fantasy basketball), you must reach a cut-off. The cut-offs for number of attempts are averages of: 5+ FGAs per game and 2+ FTAs per game. Notice that players who do not qualify can have values above 100 or below 0. Players who don't qualify will also be excluded from the colored shading option. You should ignore values above 100, below 0 or non-shaded fields since they are insignificant and won't impact your team.</blockquote><br></li>
    <li> <b>Ranking:</b> Simple ranking where the league leader in any given category is 1, next person is 2, then 3, etc. Ties are given the same rank but increased accordingly to lower players. For instance Westbrook with 2.3 steals is 1, Curry with 2.2 steals is 2, Rubio with 2.2 steals is also 2 but Chris Paul at 2.1 steals is 4 (nobody is 3).</li>
  </ul><br><br>
  <ul class='ul_faq'><span style="font-size:18px">Ignore</span><br>
    <li> Selecting any stat in the ignore section will exclude that statistic from the Scoreboard, and Matchup sections and will also exclude those stats from the color shading.</li>
  </ul><br><br>
</div>  <br><br>
<div class='div_faq'>
  Q: How are the statistics on the Team Rosters page calculated?<br>
  A: <img src='images/stats.png' align='top'><br><br>
  <ul class='ul_faq'><span style="font-size:18px">Time</span><br>
    <li> <b>Season: </b> Calculate player stats and fantasy team scoreboard based on the entire season's stats.</li>
    <li> <b>Last 5: </b> Calculate player stats and fantasy team scoreboard based on only the last 5 games for each respective player. </li>
    <li> <b>Last 10:</b> Calculate player stats and fantasy team scoreboard based on only the last 10 games for each respective player. </li>
  </ul><br><br>
  <ul class='ul_faq'><span style="font-size:18px">Values</span><br>
    <li> <b>Average: </b> Show player stats as a per game average based on the selected time period (Season, Last 5, Last 10).<br><br></li>
    <li> <b>Rating:  </b> <br><br><blockquote class='bq_faq'><b><i>(For all non-percentage fields [points, rebounds, assists, 3-pointers made, steals, blocks, turnovers, etc.])</i></b> A calculation based as a percentage of the league leader in a given category. For instance, if the league leader is averaging 30 ppg, he would be a 100 for PTS and a player averaging 15 ppg would be a 50, because 15 is 50% of 30.</blockquote> <br><blockquote class='bq_faq'><b><i>(For fg% and ft%)</i></b> A calculation based as a percentage of the league leader, but stretched over the range of values with consideration of the player at the lowest percentage in the league. For example, Jamal Crawford leads the league in FT% at 92.2%, if LeBron James is shooting 72.1%, a regular percentage of the league leader would put him at a rating of 78 (72.1/92.2). However, this is not the best calculation because nobody shoots 0% from the free-throw line. We should also consider the person who is last in the league in free throw percentage (with a qualifying number of attempts) and give him a 0. That would be Andre Drummond at 35.9%. A better calculation for LeBron (and everyone else) would be (LeBron - Min) / (Max - Min) ... (72.1 - 35.9) / (92.2 - 35.9) which would give him a rating of 64. The modified calc would also put Drummond at 0 instead of 39.</blockquote><br></li>
    <li> <b>Ranking:</b> Simple ranking where the league leader in any given category is 1, next person is 2, then 3, etc. Ties are given the same rank but increased accordingly to lower players. For instance Westbrook with 2.3 steals is 1, Curry with 2.2 steals is 2, Rubio with 2.2 steals is also 2 but Chris Paul at 2.1 steals is 4 (nobody is 3).<br><br></li>
    <li> <b>Qualifying attempts: </b> In order to be considered for the percentages (and make a real difference in fantasy basketball), you must reach a cut-off. The cut-offs for number of attempts are averages of: 5+ FGAs per game and 2+ FTAs per game. Notice that players who do not qualify can have values above 100 or below 0. Players who don't qualify will also be excluded from the colored shading. You should ignore these values since they are insignificant and won't impact your team.
  </ul>
</div>  
