
from boto3 import resource
from PIL import Image


def lambda_handler(event, context):
    im = Image.open(...)
    if 'exif' in im.info: del im.info['exif']
    im.save(..., quality='keep')
  
def lambda_handler(event, context):

    global s3_resource
    s3_resource = resource('s3')
    
    sourcebucketname = 'incoming-bucket'
    destination_bucket = s3_resource.destination_Bucket('final-bucket')

    key = event['Records'][0]['s3']['object']['key']


    return {
        'statusCode': 200
    }
