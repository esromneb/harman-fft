# HKPage

This app is to broadcast user's voice announcement to Harman Kardon Omni speakers in Wi-Fi network. User can record his/her voice and broadcast it to a set of selected Omni speakers.

----
## Release Notes (v1.2)
* Use HKWirelessHDSDKlw (lightweight version)


## Release Notes (v1.1)
### Features
* Replaced the callback functions with Delegate protocols
  - Plrease refer to HKWPlayerEventHandlerSingleton.h and HKWDeviceEventHandelerSingleton.h

## Release Notes (v1.0)

### Features
* Record user's voice and send it (broadcast) to selected speakers.
  - select speakers or rooms to play paging audio to
* Search for Omni speakers available in the WiFi network (Radar scanning UI with WiFi signal strengths)
* View and change speaker information:
  - change the volume level
  - view or change speaker name
  - view the model name and the firmware version of the speaker
  - view or change group that the speaker belongs to
  - view the current WiFi signal strength and IP address
  - view if the speaker is playing or not
  - take a note on the speaker
* House Alarm
  - User can play alarm sound to all speaker in the network. (User can select the sound of the alarm).
