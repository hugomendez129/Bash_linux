#!/bin/bash
df -h > /Monitor_Espacio/espacio_DB.txt

#listado de directorios a usar
DIR_DB="/Monitor_Espacio/Directorios/dir_DB.txt"
#el archivo que se crea en la linea 2 para almacenar la capacidad de cada directorio
ESP_DB="/Monitor_Espacio/espacio_DB.txt"

#Busco la info del server WL como en la linea 2
DIR_WL="/Monitor_Espacio/Directorios/dir_WL.txt"
ESP_WL="/Monitor_Espacio/espacio_WL.txt"

#Info guardo la inforamacion que voy a usar
INFO="/Monitor_Espacio/Directorios/INFO.txt"

#valor del % de la alerta
SET=30 

df -h > $ESP_DB

FUNCION_MONITOR (){
#coloco el inicio de la linea para indicar que significa cada columna
echo -e "\n MONITOREO EN $3 \n" >> $INFO 
head -n 1 $2 >> $INFO 
# Leer el archivo dir_DB.txt que son de los directorios a monitorear.
while IFS= read -r line; do
     # se verifica si se termina el archivo
    if [ -z $line ]; then
    exit 1
else
# se busca los directorios indicados 
#consulto el espacio usado en los directorios y elimino el caracter %
used=$(grep -w $line $2 |awk '{ print $5 }'| sed -e 's/%//g')
echo $line
echo $used
#consulto si el % en uso es mayor al valor programado
if [ $used -ge $SET ]; then
     grep $line $2 >> $INFO 
     #email=1
fi 
 fi
done < "$1"
}

FUNCION_MONITOR $DIR_DB $ESP_DB DB

#FUNCION_MONITOR $DIR_WL $ESP_WL WL

echo "" >> $INFO 

#si esta en condicion se manda mail
if [ $email -eq 1 ];
then
	echo "SE MANDA MAIL"
salida=$(cat $INFO)	
echo -e "ALERTA DE POCO ESPACIO EN: \n $salida" | mailx -s "ALERTA DE ESPACIO EN SERVIDORES"  email_example@example 

fecha=$(date +%Y%m%d_%H%M%S)
cat  $INFO > /Monitor_Espacio/Directorios/log/MONITOREO_$fecha.log

fi

cat $INFO
rm $INFO

exit
