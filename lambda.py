import json
import boto3
import random

def lambda_handler(event,context):
    body = {'message': 'Thank you for providing ParameterName, refresh to retrive last stored parameter'}
    client = boto3.client('ssm')
    test=event['queryStringParameters']['ParameterName']
    
    try:
        if event['httpMethod']=='GET' and event['queryStringParameters']['ParameterName']:
            resp = client.get_parameter( Name = event['queryStringParameters']['ParameterName'], WithDecryption=True )
            body = {'ParameterName': event['queryStringParameters']['ParameterName'], 'ParameterValue': resp['Parameter']['Value']}
            
    except Exception as e:
        client.put_parameter(
       Name = test, Description="A test parameter", Value= str(random.randint(10000,2000000)), Type="SecureString"
    )

        pass
    response = {'statusCode': 200, 'body': json.dumps(body) }
    return response
