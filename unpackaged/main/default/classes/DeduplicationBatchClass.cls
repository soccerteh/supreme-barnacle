public with sharing class DeduplicationBatchClass implements Database.Batchable<sObject>, Database.Stateful {

    Integer duplicateRecordSetsCreated = 0;
    Deduplication_Setting__mdt settings = [SELECT Object__c, RecordTypeName__c FROM Deduplication_Setting__mdt LIMIT 1];

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            'SELECT Id FROM ' + settings.Object__c + ' WHERE RecordType.Name = \'' + settings.RecordTypeName__c + '\''
        ); 
    }

    public void execute(Database.BatchableContext context, List<sObject> scope) {
        duplicateRecordSetsCreated += Deduplication.findDuplicates(scope).size();

    }

    public void finish(Database.BatchableContext context) {
        System.debug('Number of Potential Duplicate Matches: ' + duplicateRecordSetsCreated);
    }
}