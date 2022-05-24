trigger Ostrij_shareAppToPartner on College_Application__c (after insert, after update) {

    if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                    CollegeAppTriggerHandler.doAfterInsert(Trigger.new);
            } else if (Trigger.isUpdate) {
                    CollegeAppTriggerHandler.doAfterUpdate(Trigger.new, Trigger.oldMap);
            }
    }
}