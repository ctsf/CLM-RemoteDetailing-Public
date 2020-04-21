/**
 * Created by sohatto on 21/04/2020.
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