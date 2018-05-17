#!/usr/bin/env bash

#===============================================================================
# Copyright (c) 2018 Dev Microsystem
# Author: Jorge A Toro <jorge.toro at devmicrosystem.com><jolthgs at gmail.com>
# URL: http://devmicrosyste.com
# License: MIT
#
# usage: ./low_vehicle.sh plate document
#===============================================================================

# colors {{{
Color_off='\033[0m'       # Text Reset

Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White
# }}}

# globals {{{
DOCUMENT=$2
PLATE=$1
DATABASE='rastree'
# }}} 


# print {{{
msg () {
  printf "%b${Color_off}\n" "$1" >&2
}

success() {
  msg "${Green}[✔]: ${1}${2}"
}

error () {
  msg "${Red}[✘]: ${1}${2}"
}

output_color () {
  printf "%b" "${1}"
}

output_clear () {
  printf "%b" "${Color_off}"
}
# }}}

usage () {
  echo "Low Vehicle"
  echo 
  echo "usage: ./low_vehicle.sh vehicle_plate document_customer"
  echo
  echo "EXAMPLE:"
  echo "  ./low_vehicle.sh RJM270 2365699"
}

# database queries {{{

query_database() {
  psql ${2} -d $DATABASE -c "$1"
}

vehicle_information () {
  # print all the information of vehicle.

  printf "INFORMACION VEHICULO:\n\n"

  query_database "SELECT g.name AS id, v.placa AS plate, u.usuario AS user, 
    u.passwd AS password, p.descrip AS app, v.active AS vehicle_active, 
    u.last_entry, c.documento as document, 
    initcap((c.nombre1 || ' ' || COALESCE(c.nombre2, '') || ' ' || c.apellido1 || ' ' ||
      COALESCE(c.apellido2,''))) AS name, cv.id AS linked_client_to_vehicle
    FROM vehiculos v
    LEFT JOIN clientes_vehiculos AS cv on (cv.vehiculo_id = v.id)
    LEFT JOIN clientes AS c ON (c.id = cv.cliente_id)
    LEFT JOIN usuarios AS u ON (u.cliente_id = c.id)
    LEFT JOIN privileges AS p ON (p.id = u.privilege_id)
    LEFT JOIN gps AS g ON (g.id=v.gps_id)
    WHERE v.placa=lower('$PLATE');" 
}

information_of_customer() {
  # print all information of customer what reference the vehicle
  
  printf "INFORMACION CLIENTE:\n\n"

  query_database "SELECT documento AS Document, 
    initcap((c.nombre1 || ' ' || COALESCE(c.nombre2, '') || ' ' || c.apellido1 || ' ' ||
      COALESCE(c.apellido2,''))) AS Name,
    v.placa AS plate, g.name AS id, usuario AS user, passwd AS password, 
    u.activo AS user_active, u.last_entry, ch.id AS linked_client_to_vehicle
    FROM clientes c
    LEFT JOIN usuarios AS u ON (u.cliente_id=c.id)
    LEFT JOIN clientes_vehiculos AS ch ON (ch.cliente_id = c.id)
    LEFT JOIN vehiculos AS v ON  (v.id=ch.vehiculo_id)
    LEFT JOIN gps AS g ON (g.id=v.gps_id)
    WHERE c.documento='$DOCUMENT';"
    #WHERE c.documento='$DOCUMENT' AND v.placa=lower('$PLATE');"
}

delete_link_client_to_vehicle() {
  local out=$(query_database "DELETE FROM clientes_vehiculos
              WHERE id=$1;")
}

unlinked_client_of_the_vehicle() {
  #query_database "DELETE FROM clientes_vehiculos
  #  WHERE clientes_vehiculos.id = (SELECT id FROM another_table);"

  #query_database "SELECT cv.id AS delete FROM vehiculos v 
  #LEFT JOIN clientes_vehiculos AS cv on (cv.vehiculo_id=v.id) 
  #WHERE placa=lower('$PLATE')" 

  local LINKS=$(query_database "SELECT cv.id AS user
    FROM vehiculos v
    LEFT JOIN clientes_vehiculos AS cv on (cv.vehiculo_id = v.id)
    LEFT JOIN clientes AS c ON (c.id = cv.cliente_id)
    LEFT JOIN usuarios AS u ON (u.cliente_id = c.id)
    WHERE v.placa=lower('$PLATE');" --tuples-only)

  for l in $LINKS; do
    success "Unliked client of the vehicle. Delete link -> " $l 
    delete_link_client_to_vehicle $l
  done
}

users_of_the_vehicle() {
  ## gets users of the vehicle

  local users=$(query_database "SELECT u.usuario AS user
    FROM vehiculos v
    LEFT JOIN clientes_vehiculos AS cv on (cv.vehiculo_id = v.id)
    LEFT JOIN clientes AS c ON (c.id = cv.cliente_id)
    LEFT JOIN usuarios AS u ON (u.cliente_id = c.id)
    WHERE v.placa=lower('$1');" "--tuples-only")

  echo $users
}

delete_user_of_the_vehicle () {
  local out=$(query_database "DELETE FROM usuarios
        WHERE usuario='$1';")
}

vehicle_into_users() {
  local users=$(users_of_the_vehicle $PLATE)

  for u in $users; do
    amount_of_vehicles=$(query_database "SELECT COUNT(v.placa) 
      FROM usuarios u 
      LEFT JOIN clientes AS c ON (c.id=u.cliente_id)
      LEFT JOIN clientes_vehiculos AS cv ON (cv.cliente_id=c.id)
      LEFT JOIN vehiculos AS v ON (v.id=cv.vehiculo_id)
      WHERE usuario='$u';" "-t")

    #if [ $amount_of_vehicles -eq 1 ]; then
    if (( amount_of_vehicles == 1 )); then
      success "delete user '$u', has $amount_of_vehicles vehicle"
      delete_user_of_the_vehicle $u
      continue
    fi
    error "no't delete user '$u', has $amount_of_vehicles vehiles"

  done
}

device_search() {
  query_database "SELECT g.active AS gps_active, g.name AS id, v.placa AS plate, 
    v.active AS vehicle_active
    FROM vehiculos v 
    LEFT JOIN gps AS g ON (g.id=v.gps_id)
    WHERE v.placa=lower('$PLATE');" 
}

deactivate_device() {
  local out=$(query_database "UPDATE gps SET active='f' WHERE id=(SELECT g.id 
    FROM vehiculos v
    LEFT JOIN gps AS g ON (g.id=v.gps_id)
    WHERE v.placa=lower('$PLATE'));")

  success "deactivate device"
}

suspend_service() {
  local out=$(query_database "UPDATE vehiculos SET active='f' where
    placa=lower('$PLATE');")

  success "suspend service"
}

last_datetime() {
  local last_dt=$(query_database "SELECT fecha
    FROM vehiculos v
    LEFT JOIN last_positions_gps AS lpg ON (lpg.gps_id=v.gps_id)
    WHERE placa=lower('$1');" "-t")

    echo $last_dt
}

get_gps_id() {
  local query=$(query_database "SELECT gps_id
  FROM vehiculos WHERE placa=lower('$PLATE');" "-t")

  echo $query
}

get_vehicle_id() {
  local query=$(query_database "SELECT id
  FROM vehiculos WHERE placa=lower('$PLATE');" "-t")

  echo $query
}

count_states_from_vehicule() {
  local ldt="$1"
  local vehicle_id=$2

  local count_vehicle_states=$(query_database "SELECT COUNT(*) 
    FROM vehicle_state_history WHERE fecha < '$ldt' AND vehicle_id=$vehicle_id;" "-t")

  echo $count_vehicle_states
}

count_positions_from_gps() {
  local ldt="$1"
  local gps_id=$2

  local count_positions_gps=$(query_database "SELECT COUNT(*) 
    FROM positions_gps WHERE fecha < '$ldt' AND gps_id=$gps_id;" "-t")

  echo $count_positions_gps
}

delete_states_from_vehicule() {
  local ldt="$1"
  local vehicle_id=$2

  local delete=$(query_database "DELETE FROM vehicle_state_history 
    WHERE fecha < '$ldt' and vehicle_id=$vehicle_id")
}

delete_positions_gps() {
  local ldt="$1"
  local gps_id=$2

  local delete=$(query_database "DELETE FROM positions_gps 
    WHERE fecha < '$ldt' and gps_id=$gps_id")
}


# }}}


# main() {{{

# test arguments {{{
if [ $# -eq 0 ]; then
  usage
  exit 1
fi

if [ -z $2 ]; then 
  error 'Needs the document of customer'
  usage
  exit 1
fi
# }}}

output_color ${Blue}; vehicle_information; information_of_customer; output_clear

printf "type 1 for to continue with the deactivated from vehicle, 
  followed by [ENTER ↵]: "
read typed

if (( typed != 1 )); then
  error "exit of the program"
  exit 1
fi

vehicle_into_users
output_color ${Green}; unlinked_client_of_the_vehicle; output_clear
deactivate_device
suspend_service

ldt=$(last_datetime $PLATE)
v_id=$(get_vehicle_id)
g_id=$(get_gps_id)
success "last datetime of report of the vehicle: $ldt"
echo "counting amount of reports of the vehicle. Please timeout"
c_st=$(count_states_from_vehicule "$ldt" $v_id)
c_pg=$(count_positions_from_gps "$ldt" $g_id)
success "you have $c_st states of the vehicle for delete"
success "you have $c_pg reports of the vehicle for delete"

printf "type 1 for to continue with delete of the history from vehicle, 
  followed by [ENTER ↵]: "
read typed

if (( typed == 1 )); then

  delete_states_from_vehicule "$ldt" $v_id &
  delete_positions_gps "$ldt" $g_id &
  
  success "all vehicle history is deleted\n"

  vehicle_information
  device_search
else
  error "exit without delete history from vehicle"
fi

# }}}
