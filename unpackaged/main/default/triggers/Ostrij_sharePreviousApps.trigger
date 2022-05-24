trigger Ostrij_sharePreviousApps on User (after insert) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            UserSharePreviousAppsTriggerHandler.doAfterInsert(Trigger.new);
        } 
    }
}