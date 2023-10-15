/dev/xvda                   - root volumen generated from AMI
/dev/xvdb - /dev/xvde       - instance store (/media/empheral0)
/dev/xvdf - /dev/xvdp       - additionally attached EBS volumes

Testing:

1. Write test:
```sh
sudo dd if=/dev/zero of=/mnt/volume/tempfile bs=1M count=1024 conv=fdatasync.notrunc
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

2. Read test:
```sh
sudo dd if=/mnt/volume/tempfile of=/dev/null bs=1M count=1024 conv=fdatasync.notrunc
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

Blocking write operations on disk:

Can be used before creating snapshot

```sh
fsfreeze -f /mnt/volume/    # apply lock
fsfreeze -u /mnt/volume/    # remove lock
```

EFS mounting parameters:
```sh
mount -t nfs4 -o nfsver=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $FileSystemID.efs.$region.amazonaws.com:/$EfsMountPoint

nfsver=4.1
rsize=1048576   # read data block size (in bytes)
wsize=1048576   # write data block size (in bytes)
hard            # if EFS volume doesn't work, then client will wait until it comes back online
timeo=600       # time (in decsec) before client repeat request
retrans=2       # retires count  
```

/etc/fstab:
```
$FileSystemID.efs.$region.amazonaws.com:/$EfsMountPoint nfs4 nfsver=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0
```

```sh
while ! nc -z $FileSystemID.efs.$region.amazonaws.com 2049; do sleep 10; done
sleep 10
```

Sharing home between instances:
```sh
#!/bin/bash -x
bash -ex << "TRY"
# poczekaj, az system plikow EFS bedzie dostepny
while ! nc -z ${FileSystem}.efs.${AWS::Region}.amazonaws.com 2049; do sleep 10; done
sleep 10

# skopiuj istniejacy katalog /home do /oldhome
mkdir /oldhome
cp -a /home/. /oldhome

# podmontuj system plikow EFS
echo "${FileSystem}.efs.${AWS::Region}.amazonaws.com:/ /home nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0" >> /etc/fstab
mount -a

# skopiuj katalog /oldhome do nowego katalogu /home
cp -a /oldhome/. /home
TRY
/opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource EC2InstanceA --region ${AWS::Region}
```

```sh
#!/bin/bash -x
bash -ex << "TRY"
# poczekaj, az system plikow EFS bedzie dostepny
while ! nc -z ${FileSystem}.efs.${AWS::Region}.amazonaws.com 2049; do sleep 10; done
sleep 10

# podmontuj system plikow EFS
echo "${FileSystem}.efs.${AWS::Region}.amazonaws.com:/ /home nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0" >> /etc/fstab
mount -a
TRY
/opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource EC2InstanceB --region ${AWS::Region}
```

The same with backup:
```sh
#!/bin/bash -x
bash -ex << "TRY"
# poczekaj, az system plikow EFS bedzie dostepny
while ! nc -z ${FileSystem}.efs.${AWS::Region}.amazonaws.com 2049; do sleep 10; done
sleep 10

# skopiuj istniejacy katalog /home do /oldhome
mkdir /oldhome
cp -a /home/. /oldhome

# podmontuj system plikow EFS
echo "${FileSystem}.efs.${AWS::Region}.amazonaws.com:/ /home nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0" >> /etc/fstab
mount -a

# skopiuj katalog /oldhome do nowego katalogu /home
cp -a /oldhome/. /home
TRY
/opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource EC2InstanceA --region ${AWS::Region}

# poczekaj, az wolumin EBS zostanie dolaczony
while ! [ "`fdisk -l | grep '/dev/xvdf' | wc -l`" -ge "1" ]; do sleep 10; done

# jesli trzeba, sformatuj wolumin EBS
if [[ "`file -s /dev/xvdf`" != *"ext4"* ]]; then mkfs -t ext4 /dev/xvdf; fi

# podmontuj wolumin EBS
mkdir /mnt/backup
echo "/dev/xvdf /mnt/backup ext4 defaults,nofail 0 2" >> /etc/fstab
mount -a

# zainstaluj zadanie programu cron do wykonywania kopii zapasowych
cat > /etc/cron.d/backup << EOF
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/opt/aws/bin
MAILTO=root
HOME=/
*/15 * * * * root rsync -av --delete /home/ /mnt/backup/ ; fsfreeze -f /mnt/backup/ ; aws --region ${AWS::Region} ec2 create-snapshot --volume-id ${EBSBackupVolumeA} --description "EFS backup" ; fsfreeze -u /mnt/backup/
EOF
```

```sh
#!/bin/bash -x
bash -ex << "TRY"
# poczekaj, az system plikow EFS bedzie dostepny
while ! nc -z ${FileSystem}.efs.${AWS::Region}.amazonaws.com 2049; do sleep 10; done
sleep 10

# podmontuj system plikow EFS
echo "${FileSystem}.efs.${AWS::Region}.amazonaws.com:/ /home nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0" >> /etc/fstab
mount -a
TRY
/opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource EC2InstanceB --region ${AWS::Region}
```