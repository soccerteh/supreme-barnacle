public with sharing class EnrollmentRecordTriggerHandler extends TriggerHandler {

    public override void beforeUpdate() {
        //Eventually move this logic to an Enrollment Record service class.
        CioIntegrationServices.syncRecords(
            CIO_Integration_Setting__mdt.getInstance('Enrollment_Update'),
            Trigger.newMap
        );
    }

    public override void afterInsert() {
        CioIntegrationServices.syncRecords(
            CIO_Integration_Setting__mdt.getInstance('Enrollment_Started'),
            Trigger.newMap
        );
    }
}