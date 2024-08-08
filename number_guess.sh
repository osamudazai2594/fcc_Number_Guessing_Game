#!/bin/bash
PSQL="psql -tAX -U freecodecamp -d number_guess -c"
#SECRET=$(( RANDOM % 1000 + 1 ))
SECRET=23
GAME() {

  echo "Enter your username:"
  read USERNAME

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")

  if [[ -z $USER_ID ]]
  then
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
    if [[ $INSERT_USERNAME_RESULT = 'INSERT 0 1' ]]
    then
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
      echo "Welcome, $USERNAME! It looks like this is your first time here."
    else
      GAME
    fi
  else
    USER_GAME_INFO=$($PSQL "SELECT MIN(guesses), COUNT(user_id) FROM games WHERE user_id = $USER_ID")
    IFS="|" read BEST_GAME TOTAL_GAMES <<< "$USER_GAME_INFO"

    echo -e "\nWelcome back, $USERNAME! You have played $TOTAL_GAMES games, and your best game took $BEST_GAME guesses."
  fi

 echo "Guess the secret number between 1 and 1000:"
  TRIES=0
  while true
  do
    read GUESS
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    else
      ((TRIES++))
      if [[ $GUESS -lt $SECRET ]]
      then
        echo "It's higher than that, guess again:"
      elif [[ $GUESS -gt $SECRET ]]
      then
        echo "It's lower than that, guess again:"
      else
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $TRIES)")
        echo -e "\nYou guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"
        break
      fi
    fi
  done
}

GAME
