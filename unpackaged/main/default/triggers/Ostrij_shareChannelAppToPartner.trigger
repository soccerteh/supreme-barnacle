trigger Ostrij_shareChannelAppToPartner on Application__c (after insert, after update) {
//TEH 3/17/2022 - This trigger is breaking all Channel Opportunities. Unable to perform UAT for Project Istanbul. Temporarily disabling until the issue with this code is resolved.
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            channelAppTriggerHandler.doAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            channelAppTriggerHandler.doAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}