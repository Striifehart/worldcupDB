#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Clear existing data (optional, for testing purposes)
$PSQL "TRUNCATE games, teams RESTART IDENTITY;"

# Read unique teams from games.csv and insert into teams table
tail -n +2 games.csv | cut -d',' -f3,4 | tr ',' '\n' | sort | uniq | while read team; do
  if [[ -n $team ]]; then
    insert_team_result=$($PSQL "INSERT INTO teams(name) VALUES('$team') ON CONFLICT (name) DO NOTHING;")
    if [[ $insert_team_result == "INSERT 0 1" ]]; then
      echo "Inserted team: $team"
    fi
  fi
done

# Read games.csv and insert data into games table
tail -n +2 games.csv | while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")
  insert_game_result=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);")
  if [[ $insert_game_result == "INSERT 0 1" ]]; then
    echo "Inserted game: $year, $round, $winner vs $opponent"
  fi
done
