import os
import urllib.request
from urllib.parse import urlparse
import json
import boto3
import cfnresponse

print('Loading function')

s3 = boto3.resource('s3')

def save_to_local(url):
    urlPath = urlparse(url).path
    fileName = os.path.basename(urlPath)
    filePath = ''/tmp/'' + fileName
    urllib.request.urlretrieve(url, filePath)
    return filePath

def upload_to_s3(filePath, bucket):
    fileName = os.path.basename(filePath)
    s3.Object(bucket, ''labdata/''+fileName).put(Body=open(filePath, ''rb''))


def copy_to_s3(url, bucket):
    filePath = save_to_local(url)
    upload_to_s3(filePath, bucket)


def lambda_handler(event, context):
    print(''Received event: '' + json.dumps(event, indent=2))

    if event[''RequestType''] == ''Create'':
        # get the properties set in the CloudFormation resource
        properties = event[''ResourceProperties'']
        urls = properties[''Urls'']
        bucket = properties[''S3BucketName'']

        try:'
            for url in urls:
                copy_to_s3(url, bucket)

        except Exception as e:
            print(e)'
            cfnresponse.send(event, context, cfnresponse.FAILED, {
                             ''Response'': ''Failure''})
            return'

    cfnresponse.send(event, context, cfnresponse.SUCCESS,
                     {''Response'': ''Success''})