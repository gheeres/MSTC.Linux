#!/bin/bash

# Check for command line argument?
ROOT_FOLDER="$1"

if [ -z "$ROOT_FOLDER" ]; then
  echo
  echo "Creates a department shared folder structure at the specified location"
  echo
  echo "  Usage: $0 <root folder>"
  echo 

  exit 1
fi

CURRENT_USER=`whoami`
if [ "$CURRENT_USER" != "root" ]; then
  echo "root permission required."
  exit 1
fi


DEPARTMENTS=("Sales" 
"HumanResources" 
"TechnicalOperations" 
"Helpdesk" 
"Research"
"ServerAdministration")

# Check that ROOT_FOLDER exists, if not, create it...
if [ ! -d "$ROOT_FOLDER" ]; then
  echo "Creating root folder at $ROOT_FOLDER..."
  mkdir -p "$ROOT_FOLDER"
fi

for DEPARTMENT in ${DEPARTMENTS[*]}; do
  # this will repeat for each department
  echo "Provisioning $DEPARTMENT..."

  # Check if department group exists?
  if [ ! $(getent group "$DEPARTMENT") ]; then
    echo "Creating group $DEPARTMENT..."
    groupadd "$DEPARTMENT"
  fi

  DEPARTMENT_FOLDER="$ROOT_FOLDER/$DEPARTMENT"
  if [ ! -d "$DEPARTMENT_FOLDER" ]; then
    echo "Creating shared folder at $DEPARTMENT_FOLDER..."
    mkdir -p "$DEPARTMENT_FOLDER"
  fi

  echo " - Applying $CURRENT_USER:$DEPARTMENT ownership on $DEPARTMENT_FOLDER..."
  chown "$CURRENT_USER:$DEPARTMENT" "$DEPARTMENT_FOLDER"

  echo " - Applying permissions on $DEPARTMENT_FOLDER... $CURRENT_USER=rwx,$DEPARTMENT=rwx,o="
  chmod u+rwx,g+rwx,o-rwx "$DEPARTMENT_FOLDER"
  # chmod 770 "$DEPARTMENT_FOLDER"

  echo " - Granting permission (rx) to Helpdesk on $DEPARTMENT_FOLDER..."
  setfacl --modify=g:Helpdesk:rx "$DEPARTMENT_FOLDER"
done



