trigger OpportunityTrigger on Opportunity (
    before update,
    after insert
) {
    new OpportunityTriggerHandler().run();
}