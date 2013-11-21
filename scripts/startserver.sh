#!/bin/bash

STORAGELIST=`awk '{print $1}' storage`
MANAGERLIST=`awk '{print $1}' manager`
NODELIST=(25 26 27 28)
#NODELIST=(04 10 11 12 13 14 16 17 18 19 20 21 22 23 24 25 26 27 28 29 55 56 57 58)
#NODELIST=(04 10 11 12 13 14 16 17 22 23 24 25 26 27 28 29 31 32 33 34 35 36 37 38)
GROUPSIZE=4
USERNAME=$USER

function users {
    echo "Check users ..."
    for i in ${NODELIST[@]}
    do
        echo "hec-$i:"
        ssh hec-$i "users"
    done
}

function checkstatus {
    echo "Check manager node status ..."
    for i in ${MANAGERLIST[@]}
    do
        echo "hec-$i:"
		(ssh hec-$i /mnt/common/${USERNAME}/etc/init.d/fhgfs-helperd status \ 
		ssh hec-$i /mnt/common/${USERNAME}/etc/init.d/fhgfs-storage status \ 
		ssh hec-$i /mnt/common/${USERNAME}/etc/init.d/fhgfs-meta status \ 
		ssh hec-$i /mnt/common/${USERNAME}/etc/init.d/fhgfs-client status \ 
		ssh hec-$i /mnt/common/${USERNAME}/etc/init.d/fhgfs-mgmtd status \ 
		ssh hec-$i ls /home/${USERNAME}/fhgfs \ 
        ssh hec-$i ls /var/log/fhgfs* &)
    done
	wait
    echo "Check storage node status ..."
	for i in ${STORAGELIST[@]}
    do
        echo "hec-$i:"
		(ssh hec-$i /mnt/common/${USERNAME}/etc/init.d/fhgfs-helperd status \ 
		ssh hec-$i /mnt/common/${USERNAME}/etc/init.d/fhgfs-storage status \ 
		ssh hec-$i /mnt/common/${USERNAME}/etc/init.d/fhgfs-client status \ 
		ssh hec-$i ls /home/${USERNAME}/fhgfs \ 
        ssh hec-$i ls /var/log/fhgfs* &)
    done
	wait
}

function clearcache {
    echo "Clear cache ..."
	cp fm.sh /mnt/common/${USERNAME}/
    for i in ${NODELIST[@]}
    do
        ssh hec-$i sudo /mnt/common/${USERNAME}/fm.sh &
    done
	wait
}

function checkcache {
    echo "Check cache ..."
    for i in ${NODELIST[@]}
    do
        echo "hec-$i:"
        ssh hec-$i "free | grep Mem" &
    done
	wait
} 
# copy all configuration files to all storage nodes, and modify sysMgmtd to relative management host.
function generateconf {
    echo "Generate configure file ..."
    index=0
    rm manager storage
    touch manager storage
    for i in ${NODELIST[@]}
    do
        if [ $((index % ${GROUPSIZE})) -eq "0" ]
        then
            MANAGERLIST=("${MANAGERLIST[@]}" "$i")
            echo $i >> manager
        else
            STORAGELIST=("${STORAGELIST[@]}" "$i")
            echo $i >> storage
        fi
        ((index=index+1))
    done
    echo 'manager list: '${MANAGERLIST[@]}''
    echo 'storage list: '${STORAGELIST[@]}''
    for i in ${MANAGERLIST[@]} ${STORAGELIST[@]}
    do
        ssh hec-$i sudo mkdir /home/${USERNAME}/etc
        ssh hec-$i sudo chown ${USERNAME} /home/${USERNAME}/etc
        ssh hec-$i mkdir /home/${USERNAME}/etc/fhgfs
        ssh hec-$i sudo mkdir /home/${USERNAME}/fhgfs
        ssh hec-$i sudo chown ${USERNAME} /home/${USERNAME}/fhgfs
        ssh hec-59 scp /home/${USERNAME}/etc/fhgfs/fhgfs-* ${USERNAME}@hec-$i:/home/${USERNAME}/etc/fhgfs/
    done
    index=0
    for i in ${NODELIST[@]}
    do
    	scp ${USERNAME}@hec-59:/home/${USERNAME}/etc/fhgfs/fhgfs-* ${USERNAME}@hec-$i:/home/${USERNAME}/etc/fhgfs 
        OLD=hec-34
	if [ $((index % ${GROUPSIZE})) -eq "0" ]
	then
	    NEW=hec-$i
	else	
	   temp=`expr $index / ${GROUPSIZE}`
	   temp=`expr $temp \* ${GROUPSIZE}`
	   node=${NODELIST[$temp]}
           NEW=hec-$node
	fi
	echo "copying hec-$i ..."
    	ssh hec-$i sed -i -e 's/'${OLD}'/'${NEW}'/g' /home/${USERNAME}/etc/fhgfs/fhgfs-* 
        ((index=index+1))
    done
}

function startmanager {
    echo "Start management server ..."
    for i in ${MANAGERLIST[@]}
    do
        (echo "HEC-$i:" \ 
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-mgmtd start \ 
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-meta start \ 
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-storage start \ 
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-helperd start \ 
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-admon start \ 
		ssh hec-$i sudo insmod /opt/fhgfs/src/client/fhgfs_client_opentk_module/build/fhgfs-client-opentk.ko \ 
        ssh hec-$i sudo insmod /opt/fhgfs/src/client/fhgfs_client_module/build/fhgfs.ko \ 
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-client start &)
    done
	wait
}

function startstorage {
    echo "Start storage server ..."
    for i in ${STORAGELIST[@]}
    do
        (echo "HEC-$i:" \ 
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-helperd start \ 
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-storage start \ 
        ssh hec-$i sudo insmod /opt/fhgfs/src/client/fhgfs_client_opentk_module/build/fhgfs-client-opentk.ko \ 
        ssh hec-$i sudo insmod /opt/fhgfs/src/client/fhgfs_client_module/build/fhgfs.ko \ 
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-client start &)
    done
	wait
}
function stopmanager {
    echo "Stop management server ..."
    for i in ${MANAGERLIST[@]}
    do
        echo "HEC-$i:"
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-helperd stop 
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-storage stop
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-meta stop
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-client stop
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-mgmtd stop
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-admon stop
		#ssh hec-$i sudo rm -rf /home/${USERNAME}/etc/fhgfs
        ssh hec-$i sudo rm -rf /home/${USERNAME}/fhgfs
        ssh hec-$i sudo rm -rf /home/${USERNAME}/fhgfs-mount
        ssh hec-$i sudo rm /var/log/fhgfs-*
    done
}

function stopstorage {
    echo "Stop storage server ..."
    for i in ${STORAGELIST[@]}
    do
        echo "HEC-$i:"
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-storage stop
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-helperd stop
        ssh hec-$i sudo /mnt/common/${USERNAME}/etc/init.d/fhgfs-client stop
        #ssh hec-$i sudo rm -rf /home/${USERNAME}/etc/fhgfs
        ssh hec-$i sudo rm -rf /home/${USERNAME}/fhgfs
        ssh hec-$i sudo rm -rf /home/${USERNAME}/fhgfs-mount
        ssh hec-$i sudo rm /var/log/fhgfs-*
    done
}

if [ $1 == "cache" ] 
then
    clearcache
    checkcache
elif [ $1 == "start" ] 
then
    startmanager
    startstorage
elif [ $1 == "stop" ]
then
    stopstorage
    sleep 5
    stopmanager
elif [ $1 == "config" ]
then
    generateconf
elif [ $1 == "status" ]
then
    checkstatus
elif [ $1 == "users" ]
then
    users
fi
