#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

# Function to display services
display_services() {
  echo "Welcome to the salon. Here are the services we offer:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

# Function to prompt user for input
get_service_id() {
  display_services
  echo -e "\nPlease select a service by entering the service_id:"
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  if [[ -z $SERVICE_NAME ]]; then
    echo "Invalid service ID. Please select a valid service."
    get_service_id
  fi
}

get_service_id

# Prompt user for phone number
echo "Please enter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_ID ]]; then
  # If customer doesn't exist, prompt for name
  echo "It looks like you are a new customer. Please enter your name:"
  read CUSTOMER_NAME

  # Insert new customer into the customers table
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
else
  # Get existing customer's name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
fi

# Prompt user for the appointment time
echo "Please enter the appointment time:"
read SERVICE_TIME

# Insert the appointment into the appointments table
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Output the appointment confirmation
SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/^ *| *$//g')
CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
