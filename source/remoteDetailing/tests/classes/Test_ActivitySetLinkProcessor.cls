@isTest
public class Test_SetLink {
    
    private static final String APPLICATION_IDS_FIELD = 'Subject'; // <--- API name of the field to collect application Ids
    private static final String LINK_RD_FIELD = 'Description'; // <--- API name of the field to add remote detailing link
	
    // Type here necessary fields
    private static Map<String, Object> requiredFieldToValue = new Map<String, Object>{
            'DurationInMinutes' => 30,
            'ActivityDateTime' => System.today(),
            'Description' => 'Test Description'
    }; // <--- Required fields of Object => Value for this field
    // Note: If we have required reference field, we should create new record in method "insertActivity" below in code

        
    // Change API-name 'Event' on your Activity object 
    private static void insertActivity(){
        
        Event activity = new Event();
        
        for (Integer i = 0; i < 10; i++) {
            for(String requiredField : requiredFieldToValue.keySet()){
                activity.put(requiredField, requiredFieldToValue.get(requiredField)) ;
            }
        }
        
		clm__ApplicationSetup__c appSetup = new clm__ApplicationSetup__c();
			appSetup.clm__ActivityObjectAPIName__c = activity.getSObjectType().getDescribe().getName();
		insert appSetup;
        
        clm__CLMSettings__c clmSettings = new clm__CLMSettings__c();
        	clmSettings.clm__LinkField__c = LINK_RD_FIELD;
        	clmSettings.clm__ApplicationsListField__c = APPLICATION_IDS_FIELD;
        insert clmSettings;
        
        insert activity; 
    }

	
    @isTest static void checkTrigger() {
        
        Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new ActivitySetLinkHTTPCalloutMock());
        insertActivity();
        Test.stopTest(); 
        
    } 
 

}