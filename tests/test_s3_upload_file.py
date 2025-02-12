import boto3
import os
from dotenv import load_dotenv

load_dotenv()

if __name__ == '__main__':
    endpoint_switch = os.getenv('ENDPOINT')
    bucket_name = os.getenv('BUCKET_NAME')
    file_name = "test-file.csv"
    object_name = os.path.basename(file_name)

    # Get boto3 logs
    # boto3.set_stream_logger('')
    
    # Create client for uploading to s3
    s3 = boto3.client('s3',
                      endpoint_url=endpoint_switch,
                      aws_access_key_id=os.getenv('AWS_ACCESS_KEY'),
                      aws_secret_access_key=os.getenv('AWS_SECRET_KEY'),
                      region_name='ZH',
                    )
    s3_resource = boto3.resource('s3',
                                 endpoint_url=endpoint_switch,
                                aws_access_key_id=os.getenv('AWS_ACCESS_KEY'),
                                aws_secret_access_key=os.getenv('AWS_SECRET_KEY'),
                                region_name='ZH',)
    # Test S3 connection 
    response = s3.list_buckets()
    for bucket in response.get("Buckets", []):
        print(bucket["Name"])
        my_bucket = s3_resource.Bucket(bucket["Name"])
        for bucket_object in my_bucket.objects.all():
            print(bucket_object)

    # Upload test file
    # with open(file_name, "rb") as f:
    #     response = s3.put_object(Body=f, 
    #                              Bucket=bucket_name, 
    #                              Key=object_name
    #                              )
    #     print(response)