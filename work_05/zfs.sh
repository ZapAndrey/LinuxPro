#!/bin/bash
#Установка и настройка ZFS
    echo "Install ZFS"
    apt install zfsutils-linux -y

#view disk
    echo "view disk"
    lsblk

#create pool
    echo "create pool"
    zpool create otus1 mirror /dev/sda /dev/sdb
    zpool create otus2 mirror /dev/sdc /dev/sdd
    zpool create otus3 mirror /dev/sde /dev/sdf
    zpool create otus4 mirror /dev/sdg /dev/sdh

#view pool
    echo "view pool"
    zpool list

#create arh
    echo "create arh"
    zfs set compression=lzjb otus1
    zfs set compression=lz4 otus2
    zfs set compression=gzip-9 otus3
    zfs set compression=zle otus4

#view compression
    echo "view compression"
    zfs get all | grep compression
