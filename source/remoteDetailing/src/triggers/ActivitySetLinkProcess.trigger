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

trigger ActivitySetLinkProcess on CTPHARMA__Activity__c (after insert, after update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        if (!System.isFuture() && !System.isBatch()) {
            ActivitySetLinkProcessor.Setup setup = new ActivitySetLinkProcessor.Setup();

            // Type here API names of necessary fields and record types
            setup.linkRDField = 'RDLink__c'; // <--- API name of the field to add remote detailing link
            setup.applicationIdsField = 'ApplicationIds__c'; // <--- API name of the field to collect application Ids
            setup.selfDetailingRecordTypes = new List<String>{'Visit', 'SmartAudit'}; // <--- API name(s) of record types of an Activity object for Self Detailing flow
            setup.remoteDetailingRecordTypes = new List<String>{'JointVisit'}; // <--- API name(s) of record types of an Activity object for Remote Detailing flow

            String setupJSON = JSON.serialize(setup);

            Set<Id> activityIdsForAddLink = ActivitySetLinkProcessor.getActivityIdsForAddLink(Trigger.new, setup.selfDetailingRecordTypes, setup.remoteDetailingRecordTypes);

            if(!activityIdsForAddLink.isEmpty() && ActivitySetLinkProcessor.checkBeforeRun(setup)){
                ActivitySetLinkProcessor.updateSessionInfo(activityIdsForAddLink, setupJSON);
            }

        }
    }
}