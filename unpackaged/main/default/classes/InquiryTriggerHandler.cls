public with sharing class InquiryTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        CioIntegrationServices.syncRecords(
            CIO_Integration_Setting__mdt.getInstance('Inquiry_Created'),
            Trigger.newMap
        );
    }
}