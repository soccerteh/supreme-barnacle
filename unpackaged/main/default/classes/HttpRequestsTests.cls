@IsTest
public with sharing class HttpRequestsTests {

    private static final Integer MAX_CALLOUTS_PER_TRANSACTION = 75;

    @IsTest
    private static void testExecuteQueueable() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpMock());
        Id jobId = System.enqueueJob(new HttpRequests(
            new List<HttpRequest>{mockRequest()},
            new List<String>{'Content-Type'}
        ));
        Test.stopTest();
        AsyncApexJob jobDetails = [
            SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
            FROM AsyncApexJob 
            WHERE Id = :jobId
            LIMIT 1
        ];
        System.assertEquals(
            'Completed',
            jobDetails.Status,
            'Expected a completed job.'
        );
    }

    @IsTest
    private static void testBulkExecuteQueueable() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpMock());
        List<HttpRequest> requests = new List<HttpRequest>();
        for (Integer i = 0; i < 100; i++) {
            requests.add(mockRequest());
        }
        Id jobId = System.enqueueJob(new HttpRequests(
            requests,
            new List<String>{'Content-Type'}
        ));
        Test.stopTest();
        AsyncApexJob jobDetails = [
            SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
            FROM AsyncApexJob 
            WHERE Id = :jobId
            LIMIT 1
        ];
        System.assertEquals(
            'Completed',
            jobDetails.Status,
            'Expected a completed job.'
        );
    }

    @IsTest
    private static void testMakeRequests() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpMock());
        List<HttpResponse> responses = HttpRequests.makeRequests(
            new List<HttpRequest>{mockRequest()},
            new List<String>{'Content-Type'}
        );
        Test.stopTest();
        System.assertEquals(
            1,
            responses.size(),
            'Expected 1 response.'
        );
        System.assertEquals(
            200,
            responses[0].getStatusCode(),
            'Expected a 200 response.'
        );
    }

    @IsTest 
    private static void testBulkMakeRequests() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpMock());
        List<HttpRequest> requests = new List<HttpRequest>();
        for (Integer i = 0; i < 100; i++) {
            requests.add(mockRequest());
        }
        List<HttpResponse> responses = HttpRequests.makeRequests(
            requests,
            new List<String>{'Content-Type'}
        );
        Test.stopTest();
        System.assertEquals(
            null,
            responses,
            'Expected null value returned due to async job created.'
        );
    }

    @IsTest
    private static void testSegmentingCalloutList() {
        String exceptionMessage;
        Test.startTest();
        List<HttpRequest> unsegmentedRequests = new List<HttpRequest>();
        for (Integer i = 0; i < 200; i++) {
            unsegmentedRequests.add(mockRequest());
        }
        List<List<HttpRequests.SerializedRequest>> segmentedRequests = HttpRequests.segmentRequests(
            unsegmentedRequests,
            new List<String>{'Content-Type'}
        );
        //Force exception to be thrown when attempting to process over 300 requests.
        try {
            for (Integer i = 0; i < 101; i++) {
                unsegmentedRequests.add(mockRequest());
            }
            List<List<HttpRequests.SerializedRequest>> tooManyRequests = HttpRequests.segmentRequests(
                unsegmentedRequests,
                new List<String>{'Content-Type'}
            );
        } catch (HttpRequests.HttpRequestsException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(
            3,
            segmentedRequests.size(),
            'Expected three segments to be made from the 200 requests.'
        );
        for (List<HttpRequests.SerializedRequest> segment :segmentedRequests) {
            System.assertEquals(
                true,
                MAX_CALLOUTS_PER_TRANSACTION >= segment.size(),
                'Expected each segment to have at most 75 requests.'
            );
        }
        System.assertEquals(
            'Too many requests to process.',
            exceptionMessage,
            'Expected an exception to be thrown when there are more than 300 requests.'
        );
    }

    private static HttpRequest mockRequest() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.vertoeducation.org');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serializePretty('Hello World.'));
        return request;
    }

    private class HttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            response.setBody('Hello World.');
            return response;
        }
    }
}