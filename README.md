# The Remote Detailing Functionality

## Installation Guide
1. In Salesforce, from Setup, go to Apex Classes, click New and add separately Apex classes from this archive:
		- ActivitySetLinkProcessor
		- Test_ActivitySetLinkProcessor
		- ActivitySetLinkHTTPCalloutMock
2. If needed, replace Object API Name:
		– "on CTPHARMA__Activity__c" ---> "on API_name_of_the_object"
3. In Salesforce, from Setup, go to Object Manager, click an Activity object, go to the Triggers section, click New and add Apex trigger «ActivitySetLinkProcess» listed below in the code.
4. If needed, change API name(s) of fields and record types below in the code. For example:
		– setup.selfDetailingRecordTypes = new List<String>{'SMSDetailing', 'New Self Detailing Record Type'};

## Full guide

http://help.customertimes.com/articles/#!ct-mobile-ios-en/the-remote-detailing-functionality