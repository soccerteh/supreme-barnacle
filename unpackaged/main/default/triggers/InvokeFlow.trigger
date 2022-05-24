trigger InvokeFlow on ContentVersion (after Insert, after Update) {
    // Create variables to pass to the flow and query Title and relatedRecordId (FirstPublishLocationId)
    String relatedRecordId;
    String DocumentName;
    List<ContentVersion> variables = [SELECT Id, Title, FirstPublishLocationId
                                        FROM ContentVersion
                                       WHERE Id =:Trigger.new];

    // Set variables to be passed to the flow
    Map<String, Object> vars = new Map<String, Object>();
    vars.put('relatedRecordId', variables.get(0).FirstPublishLocationId);
    vars.put('DocumentName', variables.get(0).Title);
    System.debug('Variables passed to the Flow are: ' + vars);

    // Pass variables to the flow and invoke it
    Flow.Interview.Opportunity_Document_Check oppDocCheck = new Flow.Interview.Opportunity_Document_Check(vars);
    oppDocCheck.start();
}