public class HttpRequests implements Queueable, Database.AllowsCallouts {
    private List<List<SerializedRequest>> requests;
    public List<HttpResponse> responses;

    public HttpRequests(
        List<HttpRequest> callouts,
        List<String> headerKeys
    ) {
        this.requests = segmentRequests(
            callouts,
            headerKeys
        );        
    }

    public HttpRequests(List<List<SerializedRequest>> requests) {
        this.requests = requests;
    }
    
    public void execute(System.QueueableContext context) {
        List<HttpResponse> responses = new List<HttpResponse>();
        List<SerializedRequest> requestBatch = this.requests[0];
        this.requests.remove(0);
        for (SerializedRequest serializedRequest :requestBatch) {
            HttpRequest request = new HttpRequest();
            request.setMethod(serializedRequest.requestMethod);
            request.setEndpoint(serializedRequest.requestURI);
            request.setBody(serializedRequest.requestBody);
            for (String headerKey :serializedRequest.requestHeaders.keySet()) {
                request.setHeader(headerKey, serializedRequest.requestHeaders.get(headerKey));
            }
            responses.add(new Http().send(request));
        }
        for (HttpResponse response :responses) {
            if (response.getStatusCode() != 200) {
                //add logic to handle error
            }
        }

        if (
            !this.requests.isEmpty() &&
            !Test.isRunningTest()    
        ) {
            System.enqueueJob(new HttpRequests(this.requests));
        }
    }

    public static List<HttpResponse> makeRequests(
        List<HttpRequest> requests,
        List<String> headerKeys
    ) {
        if (requests.size() > 75) {
            System.enqueueJob(new HttpRequests(
                requests,
                headerKeys
            ));
            return null;
        }
        List<HttpResponse> responses = new List<HttpResponse>();
        for (HttpRequest request : requests) {
            responses.add(new Http().send(request));
        }
        return responses;
    }

    //This method should be refactored to something more generic and then moved 
    //to a List utility class once there is a need for one.
    @TestVisible
    private static List<List<SerializedRequest>> segmentRequests(
        List<HttpRequest> fullList,
        List<String> requestHeaders
    ) {
        List<List<SerializedRequest>> segmentedList = new List<List<SerializedRequest>>();
        List<SerializedRequest> segment = new List<SerializedRequest>();
        Integer max = 75;
        Integer count = 0;
        Integer index = 0;
        while (index < fullList.size()) {
            segment.add(new SerializedRequest(
                fullList.get(index++),
                requestHeaders
            ));
            count++;
            if (count == max) {
                segmentedList.add(segment);
                segment =  new List<SerializedRequest>();
                count = 0;
            }
        }
        segmentedList.add(segment);
        if (segmentedList.size() > 4) {
            //Queue depth will be too high to process this further, in the best conditions.
            throw new HttpRequestsException('Too many requests to process.');
        }
        return segmentedList;
    }

    //HttpRequest serialization is currently unsupported. As a result, they are
    //not usable directly within batch or queueable apex. This inner class is a 
    //workaround to allow HttpRequests to be passed as an argument to the queueable
    //method without having to care about dealing with serialization.
    public class SerializedRequest {
        Map<String, String> requestHeaders;
        String requestMethod;
        String requestURI;
        String requestBody;

        public SerializedRequest(
            HttpRequest request,
            List<String> headerKeys
        ) {
            this.requestHeaders = new Map<String, String>();
            this.requestMethod = request.getMethod();
            this.requestURI = request.getEndpoint();
            this.requestBody = request.getBody();
            for (String key :headerKeys) {
                this.requestHeaders.put(
                    key,
                    request.getHeader(key)
                );
            }
        }
    }

    public class HttpRequestsException extends Exception {

    }
}