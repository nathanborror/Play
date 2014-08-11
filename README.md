# Play

This is an attempt at making a better Sonos controller for iOS. It's pretty hacked together right now -- I'll try to articulate needs later so others can contribute. The following (sparse) instructions below should get it working with your system.

## First figure out the IP addresses of all your speakers.

Easiest way to do this is to checkout: [https://github.com/rahims/SoCo](https://github.com/rahims/SoCo) and use the command line example. Run: `python sonoshell.py all list_ips` to find all the IPs. Then run `python sonoshell.py YOUR_SPEAKERS_IP_ADDRESS info` to determine the uid for each speaker.

Now open the file PLNowPlayingViewController.m and replace lines 79-82 with your speaker information. Compile and you should be able to control the volume of your speakers.

## Current mock

![Current Mock](https://raw.github.com/nathanborror/Play/master/Mocks/MOCK.png)

## UPnP

You can also visit speakers directly in a browser:

- http://<SPEAKER_IP>:1400/status - status information
- http://<SPEAKER_IP>:1400/reboot - reboots speaker
- http://<SPEAKER_IP>:1400/support/review - support information?
- http://<SPEAKER_IP>:1400/support - XML dump of the latter
- http://<SPEAKER_IP>:1400/xml/zone_player.xml
- http://<SPEAKER_IP>:1400/xml/device_description.xml - info about the speaker
- http://<SPEAKER_IP>:1400/xml/<SERVICE>1.xml
