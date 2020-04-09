/**
 * CT CLM Remote Detailing,
 * Copyright (C) 2007-2020 Customertimes Corp.
 * 3 Columbus Circle, 15th Floor, #1513
 * New York, NY 10019
 * mailto:support@customertimes.com
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

@IsTest private class Test_ActivitySetLinkProcessor {

    // Type here API names of necessary object and fields
    private static final String SOBJECT_API_NAME = 'CTPHARMA__Activity__c'; // <--- API Name of Object
    private static final String LINK_RD_FIELD = 'RDLink__c'; // <--- API name of the field to add remote detailing link
    private static final String APPLICATION_IDS_FIELD = 'ApplicationIds__c'; // <--- API name of the field to collect application Ids
    private static final String RECORD_TYPE_NAME = 'Visit'; // <--- RecordType DeveloperName of Object
    private static Map<String, String> requiredFieldToValue = new Map<String, String>{
            'CTPHARMA__Result__c' => 'Test Result',
            'CTPHARMA__Description__c' => 'Test Description'
    }; // <--- Required fields of Object => Value for this field
    // Note: If we have required reference field, we should create new record in method "insertActivities" below in code


    private static RecordType recordType = new RecordType();

    @isTest static void checkValidSObjectAPIName() {
        ActivitySetLinkHTTPCalloutMock mockClass = new ActivitySetLinkHTTPCalloutMock();

        clm__ApplicationSetup__c applicationSetup = new clm__ApplicationSetup__c();
        applicationSetup.clm__ActivityObjectAPIName__c = SOBJECT_API_NAME;
        insert applicationSetup;

        setRecordType();
        Set<Id> activityIds = insertActivities();

        Test.startTest();

        String setupJSON = buildSetupJSON();

        ActivitySetLinkProcessor.updateSessionInfo(activityIds, setupJSON);
        Test.setMock(HttpCalloutMock.class, mockClass);
        Test.stopTest();

        activitiesCheck(activityIds);

    }

    @isTest static void checkValidSObjectAPINames() {
        ActivitySetLinkHTTPCalloutMock mockClass = new ActivitySetLinkHTTPCalloutMock();

        clm__ApplicationSetup__c applicationSetup = new clm__ApplicationSetup__c();
        applicationSetup.clm__ActivityObjectAPIName__c = SOBJECT_API_NAME + ',Contact';
        insert applicationSetup;

        setRecordType();
        Set<Id> activityIds = insertActivities();

        Test.startTest();
        String setupJSON = buildSetupJSON();
        ActivitySetLinkProcessor.updateSessionInfo(activityIds, setupJSON);
        Test.setMock(HttpCalloutMock.class, mockClass);
        Test.stopTest();

        activitiesCheck(activityIds);

    }

    private static void setRecordType(){
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType
        WHERE SobjectType = :SOBJECT_API_NAME AND DeveloperName = :RECORD_TYPE_NAME];
        if(!recordTypes.isEmpty()){
            recordType = recordTypes[0];
        }
    }

    private static Set<Id> insertActivities(){
        List<SObject> activities = new List<SObject>();

        /* If we have required lookup field, we should create new record, example:
    Account testAccount = new Account(Name = 'testAccount');
    insert testAccount;
    requiredFieldToValue.put('CTPHARMA__AccountId__c', testAccount.Id);
    */

        for (Integer i = 0; i < 10; i++) {

            sObject activity = Schema.getGlobalDescribe().get(SOBJECT_API_NAME).newSObject();
            for(String requiredField : requiredFieldToValue.keySet()){
                activity.put(requiredField, requiredFieldToValue.get(requiredField)) ;
            }

            if(String.isNotBlank(recordType.Id)){
                activity.put('RecordTypeId', recordType.Id);
            }
            activities.add(activity);
        }

        insert activities;

        Set<Id> activityIds = (new Map<Id, SObject>(activities)).keySet();
        return activityIds;
    }

    private static String buildSetupJSON() {
        ActivitySetLinkProcessor.Setup setup = new ActivitySetLinkProcessor.Setup();

        setup.linkRDField = LINK_RD_FIELD;
        setup.applicationIdsField = APPLICATION_IDS_FIELD;
        setup.remoteDetailingRecordTypes = new List<String>();
        setup.selfDetailingRecordTypes = new List<String>{recordType.DeveloperName};

        String setupJSON = JSON.serialize(setup);
        return setupJSON;
    }

    private static void activitiesCheck(Set<Id> activityIds) {
        String query = 'SELECT Id, ' + LINK_RD_FIELD + ' FROM ' + SOBJECT_API_NAME + ' ' +
                'WHERE Id IN :activityIds AND ' + LINK_RD_FIELD + ' != NULL';
        List<SObject> activitiesForCheck = Database.query(query);
        for (SObject sObj : activitiesForCheck) {
            System.assertEquals(true, activitiesForCheck.size() > 0);
        }
    }

}