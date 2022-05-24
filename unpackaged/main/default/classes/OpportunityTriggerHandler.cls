public with sharing class OpportunityTriggerHandler extends TriggerHandler{
    
    public override void afterInsert() {
        CioIntegrationServices.syncRecords(
            CIO_Integration_Setting__mdt.getInstance('Opportunity_Created'),
            Trigger.newMap
        );
    }
    
    public override void beforeUpdate() {
        CioIntegrationServices.syncRecords(
            CIO_Integration_Setting__mdt.getInstance('Opportunity_Update'),
            Trigger.oldMap,
            Trigger.newMap
        );   
    }
}