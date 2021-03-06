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

global class ActivitySetLinkHTTPCalloutMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest request) {
        System.debug('request body ' + request.getBody());
        String requestBody = request.getBody();
        System.debug('body size ' + requestBody.length());
        HTTPResponse response = makePostResponse(request);
        return response;
    }

    private static HTTPResponse makePostResponse(HTTPRequest request) {

        List<String> visitIds = getVisitIds(request);

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        List<VisitItem> visitItems = new List<VisitItem>();

        if(visitIds.size() > 0){
            VisitItem visitItemWithRoomId = getVisitItem(visitIds[0]);
            visitItemWithRoomId.room_id = 'roomId123';
            visitItems.add(visitItemWithRoomId);
        }


        if(visitIds.size() > 1){
            VisitItem visitItemWithApps = getVisitItem(visitIds[1]);
            AppItem appItem = new AppItem();
            appItem.room_id = 'appRoomId123';
            visitItemWithApps.apps = new List<AppItem>{appItem};
            visitItems.add(visitItemWithApps);
        }

        String visitItemsJSON = JSON.serializePretty(visitItems);
        response.setBody(visitItemsJSON);
        return response;
    }


    private static List<String> getVisitIds(HTTPRequest request){
        String message = request.getBody();
        List<String> visitIds = new List<String>();
        List<String> visitIdStrings = message.split('visit_id');
        for(Integer i=1;i<visitIdStrings.size();i++){
            String visitIdString = visitIdStrings[i];
            String visitId = visitIdString.substringAfter('" : "');
            System.debug('visit id ' + visitId);

            if(String.isNotEmpty(visitId)){
                visitId = visitId.substringBefore('"');
                System.debug('visit Id after ' + visitId);
                visitIds.add(visitId);
            } else {
                break;
            }
        }

        return visitIds;
    }

    private static VisitItem getVisitItem(String visitId) {
        VisitItem visitItem = new VisitItem();
        visitItem.visit_id = visitId;

        return visitItem;
    }
	
	
        class VisitItem {
            public String user_id;
            public String room_id;
            public String visit_id;
            public String app_id;
            public AppItem[] apps;  	
        }
		
        class AppItem {
            public String app_id;
            public String room_id;  	
        }

}