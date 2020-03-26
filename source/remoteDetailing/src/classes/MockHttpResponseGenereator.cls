@isTest
global class MockHttpResponseGenereator implements HttpCalloutMock{
	// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();

		system.debug('MOCK ENDPOINT' + req.getEndpoint());
        if (req.getEndpoint() == 'https://www.ctclm.com/present/api/json/getRoomId?cloud_token=12345') {
 	        res.setHeader('Content-Type', 'application/json');
	        res.setStatusCode(200);
	        	        
	        if (req.getMethod() == 'POST') {
                String str = '[{"user_id":"123","room_id":"321", "visit_id":"123", "app_id":"345", "apps":[{"app_id":"123","room_id":"321"}]}]';
		        res.setBody(str);   	
	        }              
        } else {
	        // Create a fake response
	        res.setHeader('Content-Type', 'application/json');
	        String str = '{"__genid": 1,';
			str += '"_id": "53749009c09405c5ca280a03",';
			str += '"background": "bg-default",';
			str += '"customStylesheet": "",';
			str += '"deckVersion": "1.0",';
			str += '"fileName": "TEST PLAIN",';
			str += '"html": "html",';
			str += '"slidesAmount":"1"';
			str += '}';
	        res.setBody(str);
	        res.setStatusCode(200);
	        
	        System.assertEquals(res.getHeader('Content-Type'), 'application/json');
	
        	
        }
        
        return res;
    }
}