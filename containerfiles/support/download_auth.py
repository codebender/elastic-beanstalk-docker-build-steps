#!/usr/bin/env python

import sys

from boto.s3.connection import S3Connection
from boto.s3.key import Key

def download_auth(bucket_name, key_name):
    conn = S3Connection()
    bucket = conn.get_bucket(bucket_name,validate=False)
    key = Key(bucket = bucket, name = key_name)
    key.get_contents_to_filename('/root/.dockercfg')

if __name__ == '__main__':
    download_auth(sys.argv[1], sys.argv[2])
