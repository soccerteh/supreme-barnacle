trigger TranscriptEvaluationTrigger on Transcript_Evaluation__c (before insert, before update) {
    new TranscriptEvaluationTriggerHandler().run();
}