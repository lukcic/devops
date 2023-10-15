# Aby umozliwic wykonywanie niepodpisanych skryptow programu PowerShell 
# uruchom najpierw te powloke jako Administrator i wprowadz polecenie:
# Set-ExecutionPolicy Unrestricted
# Zamknij okno PowerShell (aby uruchamiac skrypty nie musisz miec uprawnien administratora)
#
# Musisz tez zainstalowac program AWS Command Line Interface ze strony http://aws.amazon.com/cli/
#
# Kliknij prawym przyciskiem myszy plik *.ps1 i wybierz polecenie Run with PowerShell
$ErrorActionPreference = "Stop"

$AMIID=aws ec2 describe-images --filters "Name=name,Values=amzn-ami-hvm-2017.09.1.*-x86_64-gp2" --query "Images[0].ImageId" --output text
$VPCID=aws ec2 describe-vpcs --filter "Name=isDefault, Values=true" --query "Vpcs[0].VpcId" --output text
$SUBNETID=aws ec2 describe-subnets --filters "Name=vpc-id, Values=$VPCID" --query "Subnets[0].SubnetId" --output text
$SGID=aws ec2 create-security-group --group-name mysecuritygroup --description "Moja grupa zabezpieczen" --vpc-id $VPCID --output text
aws ec2 authorize-security-group-ingress --group-id $SGID --protocol tcp --port 22 --cidr 0.0.0.0/0
$INSTANCEID=aws ec2 run-instances --image-id $AMIID --key-name mykey --instance-type t2.micro --security-group-ids $SGID --subnet-id $SUBNETID --query "Instances[0].InstanceId" --output text
Write-Host "oczekiwanie na $INSTANCEID ..."
aws ec2 wait instance-running --instance-ids $INSTANCEID
$PUBLICNAME=aws ec2 describe-instances --instance-ids $INSTANCEID --query "Reservations[0].Instances[0].PublicDnsName" --output text
Write-Host "$INSTANCEID przyjmuje polaczenia SSH jako $PUBLICNAME"
Write-Host "lacz sie z $PUBLICNAME przez SSH jako uzytkownik ec2-user"
Write-Host "Aby zamknac $INSTANCEID, nacisnij klawisz [Enter] ..."
Read-Host
aws ec2 terminate-instances --instance-ids $INSTANCEID
Write-Host "zamykanie $INSTANCEID ..."
aws ec2 wait instance-terminated --instance-ids $INSTANCEID
aws ec2 delete-security-group --group-id $SGID
Write-Host "gotowe."
