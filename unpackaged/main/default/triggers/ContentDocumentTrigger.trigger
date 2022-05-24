trigger ContentDocumentTrigger on ContentDocument (before update) {
    switch on Trigger.OperationType {
        when BEFORE_UPDATE {
            ContentDocumentTriggerHandler.updateFormSubmissions(Trigger.new, Trigger.oldMap);
        }
    }
}