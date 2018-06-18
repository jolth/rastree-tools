#!/usr/bin/env bash

#===============================================================================
# Copyright (c) 2018 Dev Microsystem
# Author: Jorge A Toro <jorge.toro at devmicrosystem.com><jolthgs at gmail.com>
# URL: http://devmicrosyste.com
# License: MIT
#
# usage: ./unlink_client_to_vehicle.sh plate document
# test: ./unlink_client_to_vehicle.sh TNE317 15959650
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
sms () {
  printf "%b${Color_off}\n" "$1" >&2
}

success() {
  msg "${Green}[✔]: ${1}${2}"
}

error () {
  sms "${Red}[✘]: ${1}${2}"
}

output_color () {
  printf "%b" "${Blue}"
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
  psql -d $DATABASE -c "$1"
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

information_of_customer () {
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

# }}}


# main() {{{

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

if [ -z $2 ]; then 
  error 'Needs the document of customer'
  usage
  exit 1
fi


output_color; vehicle_information; information_of_customer; output_clear

# }}}
