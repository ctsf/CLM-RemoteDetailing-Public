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

@IsTest
public with sharing class TestActivityApplications {
    @IsTest
    static void testBehavior() {
        CTPHARMA__Activity__c activity = new CTPHARMA__Activity__c();
        activity.ApplicationIds__c = 'test';
        insert activity;

        clm__Application__c application = new clm__Application__c();
        application.clm__IsAvailableForRD__c = true;
        application.clm__IsActive__c = true;
        insert application;

        ActivityApplications.getCurrentApplications(activity.Id);
        ActivityApplications.updateApplicationIds(activity.Id, 'test1,test2');
        ActivityApplications.getIsRDEnabled(activity.Id);
    }
}
