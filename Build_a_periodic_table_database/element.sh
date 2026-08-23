#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

if [[ $1 =~ ^[0-9]+$ ]]
then
  QUERY="e.atomic_number = $1"
else
  QUERY="e.symbol = '$1' OR e.name = '$1'"
fi

ELEMENT_INFO=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e INNER JOIN properties p USING(atomic_number) INNER JOIN types t USING(type_id) WHERE $QUERY;")

if [[ -z $ELEMENT_INFO ]]
then
  echo "I could not find that element in the database."
else
  echo "$ELEMENT_INFO" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MLT BPT
  do
    # 去除字段两端可能的空格
    ATOMIC_NUMBER=$(echo $ATOMIC_NUMBER | xargs)
    NAME=$(echo $NAME | xargs)
    SYMBOL=$(echo $SYMBOL | xargs)
    TYPE=$(echo $TYPE | xargs)
    MASS=$(echo $MASS | xargs)
    MLT=$(echo $MLT | xargs)
    BPT=$(echo $BPT | xargs)

    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MLT celsius and a boiling point of $BPT celsius."
  done
fi
