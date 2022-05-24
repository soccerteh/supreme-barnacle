public with sharing class ApplicationTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {
        CioIntegrationServices.syncRecords(
            CIO_Integration_Setting__mdt.getInstance('Application_Completed'),
            Trigger.newMap
        );
    }
}