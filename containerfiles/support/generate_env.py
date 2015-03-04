#!/usr/bin/env python
#==============================================================================
# Copyright 2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use
# this file except in compliance with the License. A copy of the License is
# located at
#
#             http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
# implied. See the License for the specific language governing permissions
# and limitations under the License.
#==============================================================================


from __future__ import with_statement
from optparse import OptionParser

try: 
    import simplejson as json
except ImportError:
    import json

_DATA_FILE='/opt/elasticbeanstalk/deploy/configuration/containerconfiguration'

def main():
    parser = OptionParser()
    parser.add_option('-d', '--data-file', dest='data_file', default=_DATA_FILE)
    (options, args) = parser.parse_args()

    try:
        data = []
        with open(options.data_file) as f:
            data = json.loads(f.read())
                    
        docker_data = data['docker']

        output_lines = []
        if 'plugins' in data: 
            plugin_data = data['plugins']
            for resource_key, resource_value in plugin_data.iteritems():
            	if 'env' in resource_value:
            		resource_env_params = resource_value['env']
            		for resource_env_param_key, resource_env_param_value in resource_env_params.iteritems():
                    		output_lines.append('%s=%s' % (resource_env_param_key, resource_env_param_value))

        if 'env' in docker_data:
            for keyvalue in docker_data['env']:
                output_lines.append(keyvalue)

        print '\n'.join(output_lines)

    except Exception, e:
        raise e

if __name__=='__main__':
    main()
