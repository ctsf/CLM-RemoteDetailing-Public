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

public with sharing class ActivityApplications {
    @AuraEnabled(Cacheable=true)
    public static List<Object> getCurrentApplications(String activityId) {
        List<Object> applications = new List<Object>();
        List<String> applicationIds = new List<String>();

        List<CTPHARMA__Activity__c> activities = [
                SELECT ApplicationIds__c
                FROM CTPHARMA__Activity__c
                WHERE Id = :activityId
        ];

        if (activities[0].ApplicationIds__c != null) {
            applicationIds = activities[0].ApplicationIds__c.split(',');
        }

        List<clm__Application__c> accessApplications = [
                SELECT Id, Name
                FROM clm__Application__c
                WHERE clm__IsAvailableForRD__c = TRUE
                AND clm__IsActive__c = TRUE
        ];

        applications.add(accessApplications);
        applications.add(applicationIds);

        System.debug(applications);

        return applications;
    }

    @AuraEnabled()
    public static void updateApplicationIds(String activityId, String applicationsIds) {
        CTPHARMA__Activity__c activity = [
                SELECT ApplicationIds__c
                FROM CTPHARMA__Activity__c
                WHERE Id = :activityId
        ];

        activity.ApplicationIds__c = applicationsIds;

        update activity;
    }

    @AuraEnabled(Cacheable=true)
    public static Boolean getIsRDEnabled(String activityId) {
        CTPHARMA__Activity__c activity = [SELECT OwnerId FROM CTPHARMA__Activity__c WHERE Id = :activityId];
        Id profileId = [SELECT ProfileId FROM User WHERE Id = :activity.OwnerId].ProfileId;

        return clm__CLMSettings__c.getInstance(profileId).clm__IsRDEnabled__c;
    }
}
