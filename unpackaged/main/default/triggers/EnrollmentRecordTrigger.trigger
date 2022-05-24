trigger EnrollmentRecordTrigger on Enrollment_Record__c (
    before update,
    after insert
) {
    new EnrollmentRecordTriggerHandler().run();
}