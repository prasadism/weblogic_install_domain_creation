#!/bin/bash

CURDIR="$(realpath "$0")"
MYDIR="${CURDIR%/*}"


file="./myDomain.properties"

if [ -f "$file" ]
then
  echo "$file found."

  while IFS='=' read -r key value
  do
    key=$(echo $key | tr '.' '_')
    eval ${key}=\${value}
  done < "$file"
else
  echo "$file not found."
fi



# Set environment.
export MW_HOME=${path_middleware}
export WLS_HOME=$MW_HOME/wlserver
export WL_HOME=$WLS_HOME
export JAVA_HOME=${jdk_path}
export PATH=${jdk_path}/bin:$PATH
export CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom
export DOMAIN_HOME=${path_domain_config}/${domain_name}



if [[  -d "$MW_HOME"  ]] ; then
	echo "######## Weblogic is already installed #############"
else
	#Install Oracle Weblogic
echo " "
echo "########## Installing Weblogic #######################"
echo " "
	"${jdk_path}/bin/java" -Xmx2048m -jar $MYDIR/fmw_12.2.1.4.0_wls.jar -silent -responseFile $MYDIR/wls.rsp -invPtrLoc $MYDIR/oraInst.loc
fi 

echo " "
echo "################ Setting Environment ###############"
echo " "

. ${path_wls}/server/bin/setWLSEnv.sh


if [[ -d "$DOMAIN_HOME" ]] ; then
	echo "################ Domain Name is already present ########"
else

	echo " "
	echo "################ Creating Domain ####################"

	# Command to Create the domain.
	java weblogic.WLST $MYDIR/create_domain.py -p $MYDIR/myDomain.properties
fi


lsof -i:$domain_admin_port

if [[ $? = 0 ]] ; then

	echo "######### AdminServer is Already up !! #######"

else

echo " "
echo "########################## Starting AdminServer #####################"
echo " "
#Create security folder in AdminServer
/usr/bin/mkdir -p ${path_domain_config}/${domain_name}/servers/AdminServer/security

#Copy boot.properies file to AdminServer
/usr/bin/cp -parv $MYDIR/boot.properties ${path_domain_config}/${domain_name}/servers/AdminServer/security

#Start Weblogic Domain
/usr/bin/nohup $DOMAIN_HOME/bin/startWebLogic.sh &

fi
