import json
import boto3
import pprint
import random
 
def lambda_handler(event,context):
    client = boto3.client('s3')


