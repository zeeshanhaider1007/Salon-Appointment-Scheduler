#!/bin/bash
## code for freecodecamp salon appointment task
echo -e "\n~~~~~ MY SALON ~~~~~\n"
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
MAIN_MENU(){
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  MAX_SERVICE_ID=$($PSQL "SELECT MAX(service_id) FROM services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
  echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  ## if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]*$ ]]
  then
  MAIN_MENU "I could not find that service. What would you like today?"
  else
  # if number check in range?
  if [[ $SERVICE_ID_SELECTED -ge 1 && $SERVICE_ID_SELECTED -le $MAX_SERVICE_ID ]]
  then
  ## get phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  ## check record of phone number
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # check if customer already in database
  if [[ -z $CUSTOMER_ID ]]
  then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_PHONE_INSERT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
  fi
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
  
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  ## store info into database
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  APPOINTMENT_INSERT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
  MAIN_MENU "I could not find that service. What would you like today?"
  fi

  fi

}
MAIN_MENU "Welcome to My Salon, how can I help you?\n"

