/* Needs:
1. Deploy all necessary classes:
 - ActivitySetLinkProcess
 - ActivitySetLinkProcessor
 - Test_ActivitySetLinkProcessor
 - ActivitySetLinkHTTPCalloutMock
2. Replace Object API Name in Trigger to Need Object: "on CTPHARMA__Activity__c" ---> "on type_here_need_object"
3. If necessary - change at Setup  API name of fields to need, for example:
    setup.selfDetailingRecordTypes = new List<String>{'SMSDetailing', 'New Self Detailing Record Type'};
*/

trigger ActivitySetLinkProcess on CTPHARMA__Activity__c (after insert, after update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        if (!System.isFuture() && !System.isBatch()) {
            ActivitySetLinkProcessor.Setup setup = new ActivitySetLinkProcessor.Setup();

            // TYPE HERE VALUES FOR NECESSARY FIELDS
            setup.linkRDField = 'RDLink__c'; // <--- Field for add remote detailing link
            setup.applicationIdsField = 'ApplicationIds__c'; // <--- Field for collect application ids
            setup.selfDetailingRecordTypes = new List<String>{'SmartAudit'}; // <--- Record Types for SelfDetailing flow
            setup.remoteDetailingRecordTypes = new List<String>{'RemoteDetailing'}; // <--- Record Types for Remote Detailing flow

            String setupJSON = JSON.serialize(setup);

            if (ActivitySetLinkProcessor.getIsRDEnabled()) {
                Set<Id> activityIdsForAddLink = ActivitySetLinkProcessor.getActivityIdsForAddLink(Trigger.new, setup.selfDetailingRecordTypes, setup.remoteDetailingRecordTypes);

                if(!activityIdsForAddLink.isEmpty() && ActivitySetLinkProcessor.checkBeforeRun(setup)){
                    ActivitySetLinkProcessor.updateSessionInfo(activityIdsForAddLink, setupJSON);
                }
            }
        }
    }
}
