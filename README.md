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

## Full guide

http://help.customertimes.com/articles/#!ct-mobile-ios-en/the-remote-detailing-functionality