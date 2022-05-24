trigger ContentVersionTrigger on ContentVersion (after insert) {
    if(Apex_Trigger_Status__mdt.getInstance('ContentVersionTrigger').isActive__c){

        switch on Trigger.OperationType {
            when AFTER_INSERT {
                ContentVersionTriggerHandler.relocateFile(Trigger.newMap);
                ContentVersionTriggerHandler.updateFormSubmissions(Trigger.newMap);
                ContentVersionTriggerHandler.handleGuestSiteUploads(Trigger.newMap);
            }
        }
    }
}