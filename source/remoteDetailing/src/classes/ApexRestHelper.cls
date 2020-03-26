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

@RestResource (urlMapping='/Mobile/*')
global without sharing class ApexRestHelper {

    @HttpGet
    global static List<clm__Application__c> getWidgets() {

        RestContext.response.headers.put('Access-Control-Allow-Origin','*');
        RestContext.response.headers.put('Access-Control-Allow-Methods','GET, POST, OPTIONS');
        RestContext.response.headers.put('Access-Control-Allow-Headers','X-Custom-Header');

        List<clm__Application__c> apps = [SELECT Name from clm__Application__c];
        return apps;
    }

    @HttpPost
    global static void doPost(){
        clm__ApplicationSetup__c appSet = getAppSettings();
        String activityLookupField = null;

        if (null != appSet){
            activityLookupField = (String)appSet.get('clm__ActivityFieldAPI__c');
        }

        System.debug('activityLookupField >> '+activityLookupField);

        RestRequest req = RestContext.request;
        String ending = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

        String endingLC;
        try {
            endingLC = ending.tolowercase();
        } catch (Exception ex) {
            //suppress error
        }

        try {

            if ('l0tx9-mobile' == endingLC ) {
                RestContext.response.responseBody = Blob.valueOf(saveMobileStats());
            }
        } catch(Exception ex) {

            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf('{"action":"save",'
                    + '"status":"fail",'
                    + '"exception":"' + ex.getMessage() + '",'
                    + '"stack":"' + ex.getStackTraceString() + '",'
                    + '"linenumber":"'+ex.getLineNumber()+'"}');
        }
    }

    private static void upsertSobject(List<sObject> upsertList){
        //system.debug('START upsertSobject');
        List<sObject> toUpdate = new List<sObject>();
        List<sObject> toInsert = new List<sObject>();
        for(sObject item : upsertList){
            if(null == item){
                continue;
            }
            if (null == item.id || '' == String.valueOf(item.id)){
                toInsert.add(item);
            }
            else{
                toUpdate.add(item);
            }
        }
        system.debug('toUpdate >> ' + toUpdate);
        system.debug('toInsert >> ' + toInsert);
        //system.debug('END upsertSobject');
        if(0 < toUpdate.size()){
            update toUpdate;
        }
        if(0 < toInsert.size()){
            insert toInsert;
        }
        return;
    }

    private static clm__ApplicationSetup__c getAppSettings() {
        clm__ApplicationSetup__c result = clm__ApplicationSetup__c.getValues(Userinfo.getProfileId());

        if (null == result) {
            result = clm__ApplicationSetup__c.getOrgDefaults();
        }

        return result;
    }

    private static String createSuccessJSResponse(SObject[] items) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeObjectField('result', items);
        gen.writeBooleanField('success', true);
        if (items != null) {
            gen.writeNumberField('rows', items.size());
        }
        gen.writeEndObject();

        return gen.getAsString();
    }

    private static String createFailJSResponse(String message) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeObjectField('result', new SObject[0]);
        gen.writeBooleanField('success', false);
        gen.writeNumberField('rows', 0);
        gen.writeStringField('error', message);
        gen.writeEndObject();

        return gen.getAsString();
    }


    private static String saveMobileStats() {
        String result = '';

        RestRequest req = RestContext.request;

        try {
            system.debug('req.requestBody.toString() >> ' + req.requestBody.toString());
            String reqBody = req.requestBody.toString();


            clm__ApplicationSetup__c appSet = getAppSettings();
            String activityLookupField = null;
            String activityObjectField = null;


            if (null != appSet){
                activityLookupField = (String)appSet.get('clm__ActivityFieldAPI__c');
                activityObjectField = (String)appSet.get('clm__ActivityObjectAPIName__c');
            }

            String[] activityObjects;
            if (null != activityLookupField){
                activityObjects = activityObjectField.split(',');
            } else {
                activityObjects = new String[0];
            }

            String[] activityFields;

            if (null != activityLookupField){
                activityFields = activityLookupField.split(',');
            } else {
                activityFields = new String[0];
            }


            SObject appItem;

            //
            wrapper a = (wrapper)JSON.deserialize(reqBody, wrapper.class);


            //Проверяем токен, т.к. сервис открытый
            if (a.token != 'a0ng1oY4V') {
                //Нас пытаются взломать. Имитируем что все закончилось успешно.
                return createSuccessJSResponse(null);
            }

            Id visitId = (Id)a.activityId;
            String visitType = String.valueOf(visitId.getSobjectType());
            string[] visitpart = visitType.split('__');
            String visitPrefix = '';
            if (visitPart.size() > 2) {
                visitPrefix = visitPart[1];
            } else {
                visitPrefix = visitPart[0];
            }

            String visitLookupName;

            Integer i = 0;
            for (String objectName : activityObjects) {
                if (objectName.startsWithIgnoreCase(visitPrefix)) {
                    if (activityFields.size() > i) {
                        visitLookupName = activityFields[i];
                        break;
                    }
                }
                i++;
            }

            List<RecordType> rtList = [select id, DeveloperName from RecordType where sObjectType = 'clm__ApplicationStats__c'];
            RecordType rtApp, rtSlide;

            for(RecordType rt : rtList){
                if ('GlobalStats' == rt.DeveloperName) {
                    rtApp = rt;
                } else if('SlideStats' == rt.DeveloperName) {
                    rtSlide = rt;
                } else {
                    continue;
                }
            }


            appItem = a.application;

            if (appItem != null) {

                if (String.isNotBlank(visitLookupName)) {
                    appItem.put(visitLookupName, visitId);
                }

                if (rtApp != null) {
                    appItem.put('RecordTypeId', rtApp.Id);
                }

                insert appItem;
                //upsertsObject(new SObject[] {appItem} );
            }


            SObject[] slides = new SObject[0];
            if (a.slides != null) {
                for (SObject item : a.slides) {

                    // link with main stat
                    if (appItem != null) {
                        item.put('clm__ParentId__c', appItem.Id);
                    }

                    if (rtSlide != null) {
                        item.put('RecordTypeId', rtSlide.Id);
                    }

                    // link with visit
                    if (String.isNotBlank(visitLookupName) && visitId != null) {
                        item.put(visitLookupName, visitId);
                    }

                    slides.add(item);
                }

                upsertsObject( slides );
            }

            result = createSuccessJSResponse(new SObject[] {appItem});

        } catch (Exception ex) {
            system.debug(ex);
            result = createFailJSResponse(ex.getMessage() + '\n' + ex.getLineNumber() + '\n' + ex.getStackTraceString() );
        }

        return result;


    }


    class wrapper {
        public string token;
        public string activityId;
        public clm__ApplicationStats__c  application;
        public clm__ApplicationStats__c[] slides;
    }
}