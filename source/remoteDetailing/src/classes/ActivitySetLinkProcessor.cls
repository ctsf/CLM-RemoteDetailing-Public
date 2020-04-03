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

global class ActivitySetLinkProcessor {
    public class SettingsNotFoundException extends Exception {}
    public class ObjectTypeNotFoundInSettingsException extends Exception {}

    public static String BASE_PRESENT_ENDPOINT = 'https://www.ctclm.com/present';

    private static List<SObject> activitiesForAddLink;
    private static String objectType = '';

    private static String cloudToken = '';

    private static String linkRDField = 'RDLink__c';
    private static String applicationIdsField = 'ApplicationIds__c';
    private static List<String> selfDetailingRecordTypes = new List<String>();
    private static List<String> remoteDetailingRecordTypes = new List<String>();
    private static String startDate = 'CreatedDate';
    private static String endDate = '';

    public static Set<Id> getActivityIdsForAddLink(List<SObject> activities, List<String> selfDetailingRecordTypes, List<String> remoteDetailingRecordTypes) {
        Set<Id> activityIdsForAddLink = new Set<Id>();
        String objectTypeName = String.valueOf(activities[0].Id.getSobjectType());
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :objectTypeName];
        System.debug('all record types ' + recordTypes);
        if(recordTypes.isEmpty()){
            activityIdsForAddLink = (new Map<Id,SObject>(activities)).keySet();
        } else {
            Set<Id> recordTypeIds = new Set<Id>();
            for(RecordType rt : recordTypes){
                if(selfDetailingRecordTypes.contains(rt.DeveloperName) || remoteDetailingRecordTypes.contains(rt.DeveloperName)){
                    recordTypeIds.add(rt.Id);
                }
            }
            for (SObject activity : activities) {
                // Check Record Types
                String recordTypeId = (String) activity.get('RecordTypeId');
                if (recordTypeIds.contains(recordTypeId)) {
                    activityIdsForAddLink.add(activity.Id);
                }
            }
        }
        System.debug('activityIdsForAddLink size ' + activityIdsForAddLink.size());
        return activityIdsForAddLink;
    }

    public static Boolean checkBeforeRun(ActivitySetLinkProcessor.Setup setup) {
        Boolean isSuccess = false;
        if(String.isNotBlank(setup.linkRDField) && String.isNotBlank(setup.applicationIdsField)){
            isSuccess = true;
        }
        return isSuccess;
    }

    @Future(Callout=true)
    public static void updateSessionInfo(Set<Id> activityIds, String setupJSON) {
        setupData(activityIds, setupJSON);
        String sessionInfo = getSessionInfo();
        parseSessionInfo(sessionInfo);
    }

    private static void setupData(Set<Id> activityIds, String setupJSON) {
        init(setupJSON);
        setCloudToken();

        clm__ApplicationSetup__c settings = clm__ApplicationSetup__c.getOrgDefaults();
        if (settings != null) {
            if (String.isNotBlank(settings.clm__ActivityObjectAPIName__c)) {
                objectType = getObjectType(settings.clm__ActivityObjectAPIName__c, activityIds);

                if (String.isNotBlank(objectType)) {
                    setDateFields(settings);
                    setActivitiesForAddLink(activityIds);
                } else {
                    throw new ObjectTypeNotFoundInSettingsException('Object Type ' + objectType + 'doesn\'t specify in clm__ActivityObjectAPIName__c');
                }
            } else {
                throw new SettingsNotFoundException('clm__ActivityObjectAPIName__c is empty');
            }
        } else {
            throw new SettingsNotFoundException('clm__ApplicationSetup__c was not found');
        }

    }

    private static void init(String setupJSON) {
        if (String.isNotEmpty(setupJSON)) {
            Setup setup = (Setup) JSON.deserialize(setupJSON, Setup.class);
            linkRDField = setup.linkRDField;
            applicationIdsField = setup.applicationIdsField;
            selfDetailingRecordTypes = setup.selfDetailingRecordTypes;
            remoteDetailingRecordTypes = setup.remoteDetailingRecordTypes;
        }
    }

    private static void setCloudToken() {
        if (String.isEmpty(cloudToken)) {
            clm__ApplicationSetup__c setups = clm__ApplicationSetup__c.getOrgDefaults();
            if (setups != null) {
                if (String.isNotEmpty(setups.clm__CloudToken__c)) {
                    cloudToken = setups.clm__CloudToken__c;
                }
            }
        }
    }

    private static String getObjectType(String activityObjectAPInames, Set<Id> activityIds) {
        String objectTypeName = getObjectTypeName(activityIds);

        List<String> activityObjects = activityObjectAPInames.split(',');

        Set<String> activitySet = new Set<String>();
        for (String activityItem : activityObjects) {
            activitySet.add(activityItem.trim());
        }

        if (!activitySet.contains(objectTypeName)) {
            objectTypeName = '';
        }
        return objectTypeName;
    }

    private static String getObjectTypeName(Set<Id> activityIds) {
        String objectTypeName = '';

        for (Id activityId : activityIds) {
            objectTypeName = String.valueOf(activityId.getSobjectType());
            break;
        }
        return objectTypeName;
    }

    private static void setDateFields(clm__ApplicationSetup__c settings) {
        if (settings.clm__ActivityObjectAPIName__c.contains(',')) {

            List<String> objects = settings.clm__ActivityObjectAPIName__c.split(',');
            Integer i;
            for (i = 0; i < objects.size(); i++) {
                if (objects[i] == objectType) break;
            }

            if (String.isNotBlank(settings.clm__ActivityDateAPI__c)) {
                List<String> startFieds = settings.clm__ActivityDateAPI__c.split(',');
                startDate = startFieds[i].trim();
            }

            if (String.isNotBlank(settings.clm__ActivityEndDateAPI__c)) {
                List<String> endFieds = settings.clm__ActivityEndDateAPI__c.split(',');
                endDate = endFieds[i].trim();
            }

        } else {
            if (String.isNotBlank(settings.clm__ActivityDateAPI__c)) {
                startDate = settings.clm__ActivityDateAPI__c;
            }

            if (String.isNotBlank(settings.clm__ActivityEndDateAPI__c)) {
                endDate = settings.clm__ActivityEndDateAPI__c;
            }
        }
    }

    private static void setActivitiesForAddLink(Set<Id> activityIds) {
        List<Id> activityIdsList = new List<Id>(activityIds);

        String condition = ' Id IN  (\'' + String.join(activityIdsList, '\',\'') + '\')';

        String rows_query = 'SELECT Id, RecordTypeId, RecordType.DeveloperName, CreatedById, ' + linkRDField + ', '
                + applicationIdsField + ', ' + startDate;

        if (String.isNotEmpty(endDate)) {
            rows_query += ', ' + endDate;
        }

        rows_query += '  FROM ' + objectType + ' WHERE ' + condition;

        System.debug('rows_query: ' + rows_query);

        activitiesForAddLink = Database.query(rows_query);
    }

    private static String getSessionInfo() {

        String baseUrl = Url.getSalesforceBaseUrl().toExternalForm();   //  COMMENT THIS LINE FOR USE REMOTE DETAILING ON COMMUNITY LICENSES 

        /* UNCOMMENT THIS BLOCK FOR USE REMOTE DETAILING ON COMMUNITY LICENSES
        String baseUrl;
        SObject Profile = Database.query('SELECT UserLicense.Name FROM Profile WHERE Id = \'' + System.UserInfo.getProfileId() + '\' LIMIT 1');
            if (Profile.getSObject('UserLicense').get('Name') == 'Partner Community'){
                baseUrl = 'https://qa-purina.cs129.force.com/'; //  SET HERE YOUR COMMUNITY URL
            } else {
            	baseUrl = Url.getSalesforceBaseUrl().toExternalForm();   
            }
        */

        HttpRequest request = new HttpRequest();
        String url = BASE_PRESENT_ENDPOINT + '/api/json/getRoomId'
                + '?cloud_token=' + cloudToken + '&sf_base_url=' + baseUrl + '&org_id=' + UserInfo.getOrganizationId();

        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Accept-Encoding', 'gzip,deflate');
        request.setHeader('Content-Type', 'application/json');

        String messageBody = getMessageBody();
        System.debug('messageBody ' + messageBody);

        request.setBody(messageBody);
        request.setHeader('content-length', String.valueOf(messageBody.length()));

        Http http = new Http();
        HttpResponse res = http.send(request);

        return res.getBody();
    }


    private static void parseSessionInfo(String message) {
        System.debug('in parseSessionInfo');
        System.debug('message: ' + message);

        if (String.isBlank(message)) return;

        List<VisitItem> result = (List<VisitItem>) JSON.deserialize(message, List<VisitItem>.class);

        Map<String, VisitItem> visitMap = new Map<String, VisitItem>();
        for (VisitItem item : result) {
            System.debug (item);
            visitMap.put(item.visit_id, item);
        }

        if (visitMap.size() > 0) {

            for (SObject visit : activitiesForAddLink) {

                VisitItem itemMap = visitMap.get(visit.id);
                String mobilePart = '';
                System.debug('visit before mobile ' + visit);
                if (checkSelfDetailing(visit)) {
                    mobilePart = '/mobile';
                }

                System.debug('itemMap: ' + itemMap);

                if (itemMap == null) continue;
                if (itemMap.room_id != null) {
                    String session_id = itemMap.room_id;
                    if (!String.isBlank(session_id)) {

                        session_id = BASE_PRESENT_ENDPOINT + mobilePart + '/' + session_id;
                        visit.put(linkRDField, session_id);
                    }
                } else if (itemMap.apps != null) {
                    for (AppItem appItem : itemMap.apps) {
                        String session_id = appItem.room_id;
                        if (!String.isBlank(session_id)) {
                            session_id = BASE_PRESENT_ENDPOINT + mobilePart + '/' + session_id;
                            visit.put(linkRDField, session_id);
                            break;
                        }
                    }
                }
            }
            System.debug('in update activitiesForAddLink! ' + activitiesForAddLink);
            for(SObject activity : activitiesForAddLink){
                System.debug('activity rd link ' + activity.get(linkRDField));
            }
            update activitiesForAddLink;
        }
    }


    private static String getMessageBody() {
        String result = '';

        Map<Id, List<clm__Slide__c>> applicationSlidesMap = new Map<Id, List<clm__Slide__c>>();
        Set<String> appIdsSet = new Set<String>();

        for (SObject item : activitiesForAddLink) {
            String appIds = (String) item.get(applicationIdsField);

            if (String.isNotBlank(appIds)) {
                List<String> appArray = appIds.split(',');
                appIdsSet.addAll(appArray);
            }

            List<clm__Slide__c> slides = new List<clm__Slide__c>();

            if (appIdsSet.isEmpty()) {
                slides = [SELECT Id, clm__ApplicationId__c FROM clm__Slide__c WHERE clm__ApplicationId__c IN :appIdsSet ORDER BY clm__ApplicationId__c, clm__Branch__c, clm__Order__c];
                for (clm__Slide__c slide : slides) {
                    if (applicationSlidesMap.get(slide.clm__ApplicationId__c) == null) applicationSlidesMap.put(slide.clm__ApplicationId__c, new List<clm__Slide__c>());
                    applicationSlidesMap.get(slide.clm__ApplicationId__c).add(slide);
                }
            }
        }

        JSONGenerator gen = JSON.CreateGenerator(true);
        gen.writeStartArray();

        System.debug('activitiesForAddLink size ' + activitiesForAddLink.size());
        for (SObject item : activitiesForAddLink) {
            gen.writeStartObject();
            gen.writeStringField('visit_id', item.Id);
            gen.writeStringField('user_id', (String) item.get('CreatedById'));

            if (item.get(startDate) != null) {
                System.debug('item.get(startDate) ' + String.valueOf(item.get(startDate)));
                gen.writeStringField('startDate', String.valueOf(item.get(startDate)));
            }

            if (String.isNotBlank(endDate) && item.get(endDate) != null) {
                gen.writeStringField('endDate', String.valueOf(item.get(endDate)));
            }

            gen.writeFieldName('apps');
            gen.writeStartArray();

            String appIds = (String) item.get(applicationIdsField);

            if (appIds != null) {
                List<String> appArray = appIds.split(',');

                List<clm__Slide__c> slides = new List<clm__Slide__c>();
                for (String appId : appArray) {
                    if (applicationSlidesMap.get(appId) != null) {
                        slides.addAll(applicationSlidesMap.get(appId));
                    }
                }

                Map<String, List<String>> slideMap = new Map<String, List<String>>();

                for (clm__Slide__c slideItem : slides) {
                    if (!slideMap.containsKey(slideItem.clm__ApplicationId__c)) {
                        slideMap.put(slideItem.clm__ApplicationId__c, new String[0]);
                    }

                    slideMap.get(slideItem.clm__ApplicationId__c).add(slideItem.Id);
                }

                for (String appItem : appArray) {

                    gen.writeStartObject();
                    gen.writeStringField('app_id', appItem);
                    Boolean isSelfDetailing = checkSelfDetailing(item);
                    System.debug('isSelfDetailing get message ' + isSelfDetailing);
                    gen.writeBooleanField('isSelfDetailing', isSelfDetailing);

                    gen.writeEndObject();

                }
            }

            gen.writeEndArray();
            gen.writeEndObject();
        }

        gen.writeEndArray();

        result = gen.getAsString();
        System.debug('result of get message body ' + result);

        return result;
    }

    private static Boolean checkSelfDetailing(SObject activity){
        Boolean isSelfDetailing = false;
        if (activity.get('RecordTypeId') != null
                && (selfDetailingRecordTypes.contains(String.valueOf(activity.getSObject('RecordType').get('DeveloperName'))))) {                                  //SMSDetailing - то только в этом случае ставим mobile
            isSelfDetailing = true;
        }
        return isSelfDetailing;
    }


    /*
        Class for setup data
    */
    public class Setup {
        public String linkRDField = '';
        public String applicationIdsField = '';
        public List<String> selfDetailingRecordTypes = new List<String>();
        public List<String> remoteDetailingRecordTypes = new List<String>();
    }

    /*
        Classes for server response
    */
    public class VisitItem {
        public String user_id;
        public String room_id;
        public String visit_id;
        public String app_id;
        public List<AppItem> apps;
    }

    public class AppItem {
        public String app_id;
        public String room_id;
    }
}
