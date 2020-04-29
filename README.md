# The Remote Detailing Functionality

## Installation Guide
1. Go to Setup → Apex Classes → click New and add separately following Apex classes:
    - ApexRestHelper
    - Test_ApexRestHelper
    - ActivitySetLinkProcessor
    - ActivitySetLinkHTTPCalloutMock
    - Test_ActivitySetLinkProcessor
2. Go to Setup → Object Manager → click an Activity object. In the Triggers section, click New and add the following Apex trigger:
    - ActivitySetLinkProcess
3. If needed, in the trigger’s code, replace the API name of the Activity object;
4. If needed, in the trigger’s code, change API name(s) of fields and record types of an Activity object for Remote Detailing/Self Detailing flow.

## Quick Action to create CLM-Presentation Set on Activity Record in Lightning Experience 
If needed, download activityApplication.zip, replace API names of objects in the Apex Class, and create a new archive.
Log in as the administrator on https://workbench.developerforce.com/ and deploy the archive.

For macOS users, there can be an issue with the __MACOSX system file. To delete this file, follow the guide here: http://wphosting.tv/how-to-remove-__macosx-from-zip-archives/.

(
activityApplications.zip - logic for linking Apps to Activity;
RemoteDetailing.zip - logic for requesting RD Session
)

## Full guide

http://help.customertimes.com/articles/#!ct-mobile-ios-en/the-remote-detailing-functionality
