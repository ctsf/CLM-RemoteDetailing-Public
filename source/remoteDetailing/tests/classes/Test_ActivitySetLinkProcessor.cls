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

    private static final String sObjectAPIName = 'Account';

    private static final String LINK_RD_FIELD = 'Site';
    private static final String APPLICATION_IDS_FIELD = 'Description';

    private static RecordType recordType = new RecordType();

    @isTest static void checkValidSObjectAPIName() {
        ActivitySetLinkHTTPCalloutMock mockClass = new ActivitySetLinkHTTPCalloutMock();

        clm__ApplicationSetup__c applicationSetup = new clm__ApplicationSetup__c();
        applicationSetup.clm__ActivityObjectAPIName__c = sObjectAPIName;
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
        applicationSetup.clm__ActivityObjectAPIName__c = sObjectAPIName + ',Contact';
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
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :sObjectAPIName];
        if(!recordTypes.isEmpty()){
            recordType = recordTypes[0];
        }
    }

    private static Set<Id> insertActivities(){
        List<Account> activities = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            Account activity = new Account(
                    Name = 'test acc ' + i
            );
            if(String.isNotBlank(recordType.Id)){
                activity.RecordTypeId = recordType.Id;
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
        String query = 'SELECT Id, ' + LINK_RD_FIELD + ' FROM ' + sObjectAPIName + ' ' +
                'WHERE Id IN :activityIds AND ' + LINK_RD_FIELD + ' != NULL';
        List<SObject> activitiesForCheck = Database.query(query);
        for (SObject sObj : activitiesForCheck) {
            System.assertEquals(true, activitiesForCheck.size() > 0);
        }
    }

}