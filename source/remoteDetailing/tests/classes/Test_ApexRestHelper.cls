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

@isTest
public class Test_ApexRestHelper {

    @testSetup static void setup() {
        clm__ApplicationSetup__c setting =  new clm__ApplicationSetup__c(
                clm__CloudToken__c = '1234',
                clm__ActivityObjectAPIName__c = 'CTPHARMA__Activity__c',
                clm__ActivityFieldAPI__c = 'CTPHARMA__ActivityId__c',
                SetupOwnerId = Userinfo.getOrganizationId()
        );

        insert setting;

        clm__Application__c application = new clm__Application__c(
                Name = 'Test'
        );

        insert application;
        
        
        Task task = new Task();
        
        insert task;

        //CTPHARMA__Activity__c report = new CTPHARMA__Activity__c();

        //insert report;
    }

    static testMethod void test_BodyIsNull(){

        RestRequest req = new RestRequest();
        System.assertNotEquals(null, req);

        RestResponse res = new RestResponse();
        System.assertNotEquals(null, res);

        req.requestURI = '/services/apexrest/Mobile/';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        ApexRestHelper.doPost();

        Test.stopTest();

    }

    static testMethod void test_GetWidget(){

        RestRequest req = new RestRequest();
        System.assertNotEquals(null, req);

        RestResponse res = new RestResponse();
        System.assertNotEquals(null, res);

        req.requestURI = '/services/apexrest/Mobile/';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf('{ "token": "1234" }');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        ApexRestHelper.getWidgets();

        Test.stopTest();

    }

    static testMethod void test_InvalidToken(){

        RestRequest req = new RestRequest();
        System.assertNotEquals(null, req);

        RestResponse res = new RestResponse();
        System.assertNotEquals(null, res);

        req.requestURI = '/services/apexrest/Mobile/l0tx9-mobile';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{ "token": "123" }');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        ApexRestHelper.doPost();

        Test.stopTest();

    }

    static testMethod void test_ActionIsNull(){

        RestRequest req = new RestRequest();
        System.assertNotEquals(null, req);

        RestResponse res = new RestResponse();
        System.assertNotEquals(null, res);

        req.requestURI = '/services/apexrest/Mobile/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{ "token": "a0ng1oY4V" }');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        ApexRestHelper.doPost();

        Test.stopTest();

    }

    static testMethod void test_saveStats(){
        CTPHARMA__Activity__c report = new CTPHARMA__Activity__c();
        Task t = [select id from Task limit 1];


        RestRequest req = new RestRequest();
        System.assertNotEquals(null, req);

        RestResponse res = new RestResponse();
        System.assertNotEquals(null, res);

        req.requestURI = '/services/apexrest/Mobile/l0tx9-mobile';
        req.httpMethod = 'POST';

        //test data
        clm__Application__c application = [select Id from clm__Application__c where Name = 'Test' limit 1];

        req.requestBody = Blob.valueOf('{ "action": "l0tx9-mobile", "token": "a0ng1oY4V", "activityId":"'+ t.Id + '", "application": { "Id": "' + application.Id + '" }, "slideIds": ["a0C0H00001OTI26UAH", "dsg", "a0C0H00001OMIkN"] } ');
        System.assertNotEquals(null, req.requestBody);



        RestContext.request = req;
        RestContext.response = res;

        // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenereator());

        Test.startTest();

        ApexRestHelper.doPost();

        Test.stopTest();



    }

    static testMethod void test_unsubscribe(){
        CTPHARMA__Activity__c report = new CTPHARMA__Activity__c(); // [select id from CTPHARMA__Activity__c limit 1];
        Task t = [select id from Task limit 1];  

        RestRequest req = new RestRequest();
        System.assertNotEquals(null, req);

        RestResponse res = new RestResponse();
        System.assertNotEquals(null, res);

        req.requestURI = '/services/apexrest/Mobile/l0tx9-unsubscribe';
        req.httpMethod = 'POST';

        //test data
        clm__Application__c application = [select Id from clm__Application__c where Name = 'Test' limit 1];

        req.requestBody = Blob.valueOf('{ "action": "unsubscribe", "token": "a0ng1oY4V", "activityId":"'+ t.Id + '" }');
        System.assertNotEquals(null, req.requestBody);



        RestContext.request = req;
        RestContext.response = res;

        // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenereator());

        Test.startTest();
 
        ApexRestHelper.doPost();

        Test.stopTest();



    }

    static testMethod void test_update(){

        RestRequest req = new RestRequest();
        System.assertNotEquals(null, req);

        RestResponse res = new RestResponse();
        System.assertNotEquals(null, res);

        req.requestURI = '/services/apexrest/Mobile/l0tx9-update';
        req.httpMethod = 'POST';

        //test data
        clm__Application__c application = [select Id from clm__Application__c where Name = 'Test' limit 1];

        req.requestBody = Blob.valueOf('{ "action": "update", "token": "a0ng1oY4V", "application": { "Id": "' + application.Id + '", "Name":"Test2" } }');
        System.assertNotEquals(null, req.requestBody);



        RestContext.request = req;
        RestContext.response = res;

        // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenereator());

        Test.startTest();

        ApexRestHelper.doPost();

        Test.stopTest();
    }
    
    
    static testMethod void test_upsert_method(){  
        
        Task toUpdate = [select id from Task limit 1];
        
        Task toInsert = new Task();
        
        List<Sobject> testList = new List<Sobject>{toInsert,toUpdate};
        
        Test.startTest();
        
        ApexRestHelper.upsertSobject(testList);
        
        String jsonStr = ApexRestHelper.createSuccessJSResponse(testList);
         
        System.assertNotEquals(null, jsonStr);

        Test.stopTest();
    }

}