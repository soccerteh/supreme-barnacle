trigger CoursePrerequisiteTrigger on Course_Prerequisite__c (before insert) {
    switch on Trigger.OperationType {
        when BEFORE_INSERT {
            CoursePrerequisitesTriggerHandler.handleBeforeInsert(Trigger.new);
        }
    }
}