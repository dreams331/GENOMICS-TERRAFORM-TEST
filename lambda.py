
import logging
import zipfile
from io import BytesIO
from boto3 import resource
from PIL import Image
import gzip
import io

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def unzip_and_gzip_files(filekey, sourcebucketname, destinationbucket):
    try:
        zipped_file = s3_resource.Object(bucket_name=sourcebucketname, key=filekey)
        buffer = BytesIO(zipped_file.get()["Body"].read())
        zipped = zipfile.ZipFile(buffer)
        
        for file in zipped.namelist():
            logger.info(f'current file in zipfile: {file}')
            final_file_path = file + '.gzip'

            with zipped.open(file, "r") as f_in:
                gzipped_content = gzip.compress(f_in.read())
                destinationbucket.upload_fileobj(io.BytesIO(gzipped_content),
                                                        final_file_path,
                                                        ExtraArgs={"ContentType": "text/plain"}
                                                )
    except Exception as e:  
        logger.info(f'Error: Unable to gzip & upload file: {e}')
      
def lambda_handler(event, context):
    im = Image.open(...)
    if 'exif' in im.info: del im.info['exif']
    im.save(..., quality='keep')
  
def lambda_handler(event, context):

    global s3_resource
    s3_resource = resource('s3')
    
    sourcebucketname = 'incoming-bucket'
    destination_bucket = s3_resource.Bucket('final-bucket')

    key = event['Records'][0]['s3']['object']['key']
    unzip_and_gzip_files(key, sourcebucketname, destination_bucket)

    return {
        'statusCode': 200
    }
