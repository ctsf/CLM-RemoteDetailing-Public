# The Remote Detailing Functionality

## Installation Guide
1. Go to Setup → Apex Classes → click New and add separately following Apex classes:
    - ApexRestHelper
    - Test_ApexRestHelper
    - ActivitySetLinkProcessor
    - Test_ActivitySetLinkProcessor
    - ActivitySetLinkHTTPCalloutMock
2. Go to Setup → Object Manager → click an Activity object. In the Triggers section, click New and add the following Apex trigger:
    - ActivitySetLinkProcess
3. If needed, in the trigger’s code, replace the API name of the Activity object;
4. If needed, in the trigger’s code, change API name(s) of fields and record types of an Activity object for Remote Detailing/Self Detailing flow.

## Lightning Actions deploy
1. If needed, in the apex code into archive, replace the API name of the Activity object;
2. Use Workbench to deploy a zip file with the functionality you need. 

(activityApplications.zip - logic for linking Apps to Activity)

## Full guide

http://help.customertimes.com/articles/#!ct-mobile-ios-en/the-remote-detailing-functionality
