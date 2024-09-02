#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\nHow may I help you?"

  echo -e "\n1. Show all Services\n2. Check your appointment\n3. Exit\n"

  read SELECTION

  case $SELECTION in
    1) SERVICES_MENU ;;
    2) APPOINTMENT_CHECK ;;
    3) EXIT ;;
    *) MAIN_MENU "Please choose one of the above options." ;;
  esac
}

SERVICES_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Fetch and display the list of services
  SERVICES=$($PSQL "SELECT * FROM services") 

  if [[ -z $SERVICES ]]
  then
    echo "No services found."
    MAIN_MENU
  else
    echo -e "\nAvailable Services:"
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  fi

  BOOKING
}
NEW_CUSTOMER(){
  echo -e "\nPlease enter your name:" 
  read NAME
  echo -e "\nPlease enter the appointment time you want"
  read SERVICE_TIME

  SERVICE_NAME=$($PSQL "select name from services where service_id = $SELECTED_SERVICE ")
    INSERT_CUSTOMER=$($PSQL "insert into customers (phone, name) values ('$PHONE', '$NAME')")
    
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$PHONE'")

    INSERT_APPOINTMENT=$($PSQL "insert into appointments (customer_id, service_id, time, phone, name) values ($CUSTOMER_ID, $SELECTED_SERVICE, '$SERVICE_TIME', '$PHONE', '$NAME')")
    
    if [[ $INSERT_CUSTOMER == 'INSERT 0 1' ]]
    then
      if [[ $INSERT_APPOINTMENT == 'INSERT 0 1' ]]
      then
         echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $NAME. "
      fi
    fi
}

REPEAT_CUSTOMER(){
  echo -e "\nWelcome back\n"
  echo -e "\nPlease enter the appointment time you want"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$PHONE'")
  NAME=$($PSQL "select name from customers where customer_id = $CUSTOMER_ID")
  SERVICE_NAME=$($PSQL "select name from services where service_id = $SELECTED_SERVICE ") 
    
    INSERT_APPOINTMENT=$($PSQL "insert into appointments (customer_id, service_id, time, phone, name) values ($CUSTOMER_ID, $SELECTED_SERVICE, '$SERVICE_TIME', '$PHONE', '$NAME')")
      if [[ $INSERT_APPOINTMENT == 'INSERT 0 1' ]]
      then
         echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $NAME. "
      fi
    

}
BOOKING() {
  echo -e "\nPlease select a service by entering the service number:" 
  read SELECTED_SERVICE

  SERVICE_AVAILABLE=$($PSQL "SELECT * FROM services WHERE service_id = $SELECTED_SERVICE")

  if [[ -z $SERVICE_AVAILABLE ]]
  then
    NO_SERVICE
  fi
  echo -e "\nPlease enter your phone number:"
  read PHONE 

  READ_PHONE=$($PSQL "select customer_id from customers where phone = '$PHONE'")
  if [[ -z $READ_PHONE ]]
  then
  NEW_CUSTOMER
  
  else
  REPEAT_CUSTOMER
  
  fi

  SERVICE_AVAILABLE=$($PSQL "SELECT * FROM services WHERE service_id = $SELECTED_SERVICE")

  if [[ -z $SERVICE_AVAILABLE ]]
  then
    NO_SERVICE
  else
    SERVICE_IS_AVAILABLE
    
    echo -e "\nchoose where to go next\n1) Main Menu\n2)Exit\n"
    read LAST_STOP

    case $LAST_STOP in
    1) MAIN_MENU ;;
    *) EXIT ;;
    esac
  fi

  
}

NO_SERVICE(){
  SERVICES_MENU "Please choose a valid service."
}

SERVICE_IS_AVAILABLE(){

  SERVICE_NAME=$($PSQL "select name from services where service_id = $SELECTED_SERVICE ")
    if [[ -z $READ_PHONE ]]
    then
    INSERT_CUSTOMER=$($PSQL "insert into customers (phone, name) values ('$PHONE', '$NAME')")
    
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$PHONE'")

    INSERT_APPOINTMENT=$($PSQL "insert into appointments (customer_id, service_id, time, phone, name) values ($CUSTOMER_ID, $SELECTED_SERVICE, '$SERVICE_TIME', '$PHONE', '$NAME')")
    else 
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$PHONE'")
    INSERT_APPOINTMENT=$($PSQL "insert into appointments (customer_id, service_id, time, phone, name) values ($CUSTOMER_ID, $SELECTED_SERVICE, '$SERVICE_TIME', '$PHONE', '$NAME')")
    fi
    if [[ $INSERT_CUSTOMER == 'INSERT 0 1' ]]
    then
      if [[ $INSERT_APPOINTMENT == 'INSERT 0 1' ]]
      then
         echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $NAME. "
      fi
    fi
}

APPOINTMENT_CHECK() {

  echo -e "\nPlease enter your phone number:"
  read PHONE

  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$PHONE'")
  APPOINTMENT_ID=$($PSQL "select max(appointment_id) from appointments where customer_id = $CUSTOMER_ID")

  echo $APPOINTMENT_ID
  if [[ -n $APPOINTMENT_ID ]]
  then
  APPOINTMENT_DETAILS=$($PSQL "select customers.name, services.name, time from appointments inner join customers using (customer_id) inner join services using (service_id) where appointment_id = $APPOINTMENT_ID")
  echo "$APPOINTMENT_DETAILS" | while read CNAME BAR SNAME BAR TIME
  do
  echo -e "Appointment for Mr/Mrs $CNAME for $SNAME services on $TIME O'clock"
  done
  else
  SERVICES_MENU "No Kindly book an appointment first "
  fi
}

EXIT() {
  echo -e "\nThank you for visiting. Goodbye!"
  exit 0
}

# Start with the main menu
MAIN_MENU
