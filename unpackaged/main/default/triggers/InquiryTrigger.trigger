trigger InquiryTrigger on Inquiry__c (
    before insert,
    before update,
    after insert,
    after update
) {
    new InquiryTriggerHandler().run();
}