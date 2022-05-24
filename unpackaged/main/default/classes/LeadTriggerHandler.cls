public with sharing class LeadTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        CioIntegrationServices.syncRecords(
            CIO_Integration_Setting__mdt.getInstance('Lead_Created'),
            Trigger.newMap
        );
    }
    
    public override void beforeUpdate() {
        CioIntegrationServices.syncRecords(
            CIO_Integration_Setting__mdt.getInstance('Lead_Update'),
            Trigger.newMap,
            Trigger.oldMap
        );
    }
}