#!/usr/bin/env python3

###     --- Gathers assets from AWS and creates CSVs to import into Freshservice ---

import boto3
import csv

###########################################
###     --- CSV headers function ---    ###
###########################################

def csv_headers(fileName, headers):
    with open(fileName, 'w') as file:
        csvWrite = csv.writer(file, delimiter=',')
        headerValues = headers
        csvWrite.writerow(headerValues)
        file.close

###############################
###     --- EC2 data ---    ###
###############################
print("Gathering EC2 instances...")
#       --- Write CSV headers ---
csv_headers('ec2.csv', ['Display Name','Instance ID','Instance Type','AMI ID','Operating System','Availability Zone','Private IP','Public IP','Private DNS','Public DNS','Patch Group','Instance State','Subnet ID','Launch Time','VPC ID','Platform','Key Name','EBS Optimized','IAM Instance Profile','Hypervisor','Monitoring','Tags'])

#       --- EC2 data function ---
def ec2_data(region):
    instanceProfile = 'None'
    patchGroup = 'None'
    imageOs = 'Unknown'
    ec2 = boto3.resource('ec2', region)
    instances = ec2.instances.all()
    for i in instances:
        try:
            for e in i.tags:
                if e['Key'] == 'Name':
                    name = e['Value']
        except:
            pass

        try:
            for e in i.tags:
                if e['Key'] == 'Patch Group':
                    patchGroup = e['Value']
        except:
            pass

        try:
            instanceProfile = i.iam_instance_profile['Arn']
        except:
            pass

        try:
            image = i.image_id
            ami = boto3.client('ec2')
            imageData = ami.describe_images(ImageIds=[image])
            if len(imageData['Images']) != 0:
                if len(imageData['Images'][0]['Description']) != 0:
                    imageOs = imageData['Images'][0]['Description']
        except:
            pass

        with open('ec2.csv', 'a+') as file:
            csvWrite = csv.writer(file)
            row = [name, i.id, i.instance_type, i.image_id, imageOs, i.placement['AvailabilityZone'], i.private_ip_address, i.public_ip_address, i.private_dns_name, i.public_dns_name, patchGroup, i.state['Name'], i.subnet_id, i.launch_time, i.vpc_id, i.platform_details, i.key_name, i.ebs_optimized, instanceProfile, i.hypervisor, i.monitoring['State'], i.tags]
            csvWrite.writerow(row)

#       --- Gather EC2 data from each region ---
ec2_data('REGION')


#######################################
###     --- Attached EBS data ---   ###
#######################################
print("Gathering attached EBS volumes...")
#       --- Write CSV headers ---
csv_headers('ebs.csv', ['Display Name','Region','Volume ID','Attached To','Size','Created','State','Volume Type','Snapshot','Encrypted'])

#       --- EBS data function that only pulls volumes with attachments ---
import re
def ebs_data(region):
    name = 'None'
    ebs = boto3.resource('ec2', region)
    volumes = ebs.volumes.all()
    for v in volumes:
        with open('ebs.csv', 'a+') as file:
            if len(v.attachments) > 0:
                csvWrite = csv.writer(file)
                time = re.sub(r'(.*?:.*?):.*', '\g<1>', str(v.create_time))
                try:
                    for t in v.tags:
                        if t['Key'] == 'Name':
                            name = t['Value']
                except:
                    continue
                row = [name, region, v.id, v.attachments[0]['InstanceId'], str(v.size)+' GB', time, v.state, v.volume_type, v.snapshot_id, v.encrypted]
                csvWrite.writerow(row)
            else:
                continue

#       --- Gather EBS data from each region ---
ebs_data('REGION')


###############################################
###     --- AMIs owned by COMPANY ---       ###
###############################################
print("Gathering AMIs...")
#       --- Write CSV headers ---
csv_headers('ami.csv', ['Region','Item ID','Item Name','Guest OS','Created Time','Image Type','State','Hypervisor','Root Device Name','Root Device Type','Virtualization Type','Public'])

#       --- AMI data function ---
def ami_data(region):
   ami = boto3.resource('ec2', region)
   filters = [
       {'Name': 'owner-id', 'Values': ['AWS_ACCOUNT_ID']}
   ]
   images = ami.images.filter(Filters=filters).all()
   for i in images:
       with open('ami.csv', 'a+') as file:
           timeTemp = re.sub(r'(.*?:.*?):.*', '\g<1>', str(i.creation_date))
           time = re.sub(r'T', ' ', timeTemp)
           csvWrite = csv.writer(file)
           row = [region, i.id, i.name, i.platform_details, time, i.image_type, i.state, i.hypervisor, i.root_device_name, i.root_device_type, i.virtualization_type, i.public]
           csvWrite.writerow(row)

#      --- Gather AMIs from each region ---
ami_data('REGION')

####################################################
###     --- ElasticBeanstalk environments ---    ###
####################################################
print("Gathering ElasticBeanstalk environments...")
#       --- Write CSV headers ---
csv_headers('bean.csv', ['Name','Environment ID','Application Name','Solution Stack','Endpoint URL','CNAME','Created At','Updated At','Status','Tier Name','Tier Type','Tier Version'])

#       --- ElasticBeanstalk function ---
def bean_data():
    bean = boto3.client('elasticbeanstalk')
    env = bean.describe_environments()
    for e in env['Environments']:
        with open('bean.csv', 'a+') as file:
            csvWrite = csv.writer(file)
            timeCreated = re.sub(r'(.*?:.*?):.*', '\g<1>', str(e['DateCreated']))
            timeUpdated = re.sub(r'(.*?:.*?):.*', '\g<1>', str(e['DateUpdated']))
            row = [e['EnvironmentName'], e['EnvironmentId'], e['ApplicationName'], e['SolutionStackName'], e['EndpointURL'], e['CNAME'], timeCreated, timeUpdated, e['Status'], e['Tier']['Name'], e['Tier']['Type'], e['Tier']['Version']]
            csvWrite.writerow(row)

#       --- Gather ElasticBeanstalk data for each environment ---
bean_data()

###########################################
###     --- Move to shared drive ---    ###
###########################################
print("Moving exported CSVs to shared drive...")

import platform
import shutil
csvs = ['bean.csv', 'ebs.csv', 'ec2.csv', 'eks.csv']

if platform.system() == 'Windows':
    sharePath = "DRIVE_PATH"
else:
    sharePath = "DRIVE_PATH"

for c in csvs:    
    shutil.copy(c, sharePath)