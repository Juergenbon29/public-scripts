#!/usr/bin/env python

import boto3

# Create EC2 client object
ec2 = boto3.client('ec2')

# Tag to remove 
tagKey = 'Patch Group'

# List instances with the tag
response = ec2.describe_instances(
    Filters=[
        {
            'Name': 'tag-key',
            'Values': [tagKey]
        }
    ]
)

# Extract instance IDs from the response
instanceIds = []
for reservation in response['Reservations']:
    for instance in reservation['Instances']:
        instanceIds.append(instance['InstanceId'])

# TESTING - List instance IDs
#print(instanceIds)

# Remove tag from instances
removeTag = ec2.delete_tags(
    Resources=instanceIds,
    Tags=[
        {
            'Key': tagKey
        }
    ]
)

# Print removeTag
print(removeTag)