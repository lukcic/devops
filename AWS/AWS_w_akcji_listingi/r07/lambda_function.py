import boto3
ec2 = boto3.client('ec2')

def lambda_handler(event, context):
  print(event)
  if "/" in event['detail']['userIdentity']['arn']:
  	userName = event['detail']['userIdentity']['arn'].split('/')[1]
  else:
  	userName = event['detail']['userIdentity']['arn']
  instanceId = event['detail']['responseElements']['instancesSet']['items'][0]['instanceId']    
  print("Dodawanie tagu wlasciciela " + userName + " do instancji " + instanceId + ".")
  ec2.create_tags(Resources=[instanceId,],Tags=[{'Key': 'Owner', 'Value': userName},])
  return
