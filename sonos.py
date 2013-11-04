#!/usr/bin/env python

import sys
import requests
import xmltodict
import ast

"""
A simple script that lets you test SOAP requests against a Sonos
system for debugging purposes.

Example:
    Pause:
        python sonos.py 10.0.1.9 /MediaRenderer/AVTransport/Control AVTransport Pause "{'InstanceID': 0}"
    Play:
        python sonos.py 10.0.1.9 /MediaRenderer/AVTransport/Control AVTransport Play "{'InstanceID': 0, 'Speed': 1}"
    Media Info:
        python sonos.py 10.0.1.9 /MediaRenderer/AVTransport/Control AVTransport GetMediaInfo "{'InstanceID': 0}"

Go to http://SPEAKER_IP:1400/xml/device_description.xml to understand what the speakers
are capable of.
"""

def run(ip, control, service, action, params={'InstanceID': 0}):
    headers = {'SOAPACTION': 'urn:schemas-upnp-org:service:%s:1#%s' % (service, action)}
    
    param_string = ''
    if params:
        for param in params:
            param_string += '<%s>%s</%s>' % (param, params[param], param)
    
    template = '<?xml version="1.0" encoding="utf-8"?>\
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">\
    <s:Body>\
        <u:%s xmlns:u="urn:schemas-upnp-org:service:%s:1">\
            %s\
        </u:%s>\
    </s:Body>\
</s:Envelope>' % (action, service, param_string, action)

    url = 'http://%s:1400%s' % (ip, control)
    r = requests.post(url, data=template, headers=headers)
    
    namespaces = {
        'http://schemas.xmlsoap.org/soap/envelope/': None
    }
    response = dict(xmltodict.parse(r.text, namespaces=namespaces))
    
    output = {
        'envelope': dict(response['s:Envelope']),
        'body': dict(response['s:Envelope']['s:Body'])
    }
    
    # Look for an error and add it to the output
    try:
        output['error'] = dict(response['s:Envelope']['s:Body']['s:Fault'])
    except KeyError:
        output['response'] = dict(response['s:Envelope']['s:Body']['u:%sResponse' % action])
        
    # Look for meta data XML
    try:
        output['metadata'] = dict(xmltodict.parse(output['response']['CurrentURIMetaData']))
        output['metadata'] = dict(output['metadata']['DIDL-Lite']['item'])
    except KeyError:
        output['metadata'] = None
    except TypeError:
        output['metadata'] = None
        
    return output


if __name__ == '__main__':
    if (len(sys.argv) < 5):
        print "Usage: python sonos.py [speaker IP] [service] [action] [params]"
        print "Example: python sonos.py 10.0.1.9 AVTransport Play \"{'InstanceID': 0, 'Speed': 1}\""
        sys.exit()

    speaker_ip = sys.argv[1]
    control = sys.argv[2]
    service = sys.argv[3]
    action = sys.argv[4]
    
    try:
        params = ast.literal_eval(sys.argv[5])
        response = run(speaker_ip, control, service, action, params=params)
    except IndexError:
        response = run(speaker_ip, control, service, action)
        
    print ''
    print '\x1B[37mEnvelope:'
    print '\x1B[33m%s\n' % response.get('envelope', None)
    print '\x1B[37mBody:'
    print '\x1B[32m%s\n' % response.get('body', None)
    print '\x1B[37mResponse:'
    print '\x1B[36m%s\n' % response.get('response', None)
    
    if response.get('metadata', None):
        print '\x1B[37mMetaData:'
        print '\x1B[36m%s\n' % response.get('metadata', None)
    
    if response.get('error', None):
        print '\x1B[41;37mError:\x1B[0m'
        print '\x1B[31m%s\n' % response.get('error', None)
