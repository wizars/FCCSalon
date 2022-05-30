#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n\n~~~~~ SALON APPOINTMENTS SCHEDULER ~~~~~"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # get available services and list them
  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo -e "\nAvailable Services:"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME 
    do
    echo "$SERVICE_ID) $NAME"
    done

    # ask for a service
    echo -e "\nWhich service you would like to schedule?"
    read SERVICE_ID_SELECTED

    # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then # no es un numero
      # send to main menu
      MAIN_MENU "That is not a valid service number."
    else  # si es un numero
      TEMP=$($PSQL "SELECT service_id from services where service_id = $SERVICE_ID_SELECTED")
      echo El valor es $TEMP
      if [[ -z $TEMP ]]
      then # no es un id valido
        MAIN_MENU "That services dosen't exist."
      else # si es un id de servicio valido
        
        # get customer phone
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

        # if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          # get new customer name
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME

          # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
        fi
        
        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        echo el customer_id es $CUSTOMER_ID


        echo -e "\nWhat time do you whant?"
        read SERVICE_TIME

echo -e "tengo...............\nNombre $CUSTOMER_NAME \n ID= $CUSTOMER_ID\n time = $SERVICE_TIME\n servicio=$SERVICE_ID_SELECTED"

        ## guardo la cita en la DB
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

        SERVICE=$($PSQL "SELECT name from services where service_id=$SERVICE_ID_SELECTED")
        CUSTOMER_PHONE=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        echo  "I have put you down for a$SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."

      fi
  
    fi
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU