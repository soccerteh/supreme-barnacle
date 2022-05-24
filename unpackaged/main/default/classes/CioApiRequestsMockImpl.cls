@IsTest
@SuppressWarnings('PMD.AvoidGlobalModifier')
/** Mock Class */
global with sharing class CioApiRequestsMockImpl implements HttpCalloutMock {

    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        response.setBody('{ "status" : "success" }');
        return response;
    }

    global List<HttpResponse> respond(List<HttpRequest> requests) {
        List<HttpResponse> responses = new List<HttpResponse>();
        for (HttpRequest request :requests) {
            responses.add(respond(request));
        }
        return responses;
    }
}