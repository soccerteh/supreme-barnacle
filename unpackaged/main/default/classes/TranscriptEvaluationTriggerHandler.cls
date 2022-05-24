public with sharing class TranscriptEvaluationTriggerHandler extends TriggerHandler{
    
    public override void beforeInsert() {
        Set<Id> accountIds = new Set<Id>();
        for (Transcript_Evaluation__c each :(List<Transcript_Evaluation__c>)Trigger.new) {
            TranscriptEvaluation.updateEvaluationWithCourseEligibility(each);
            accountIds.add(each.Student__c);    
        }
        provisionStudentPortalUsers(accountIds);
    }

    private static void provisionStudentPortalUsers(Set<Id> accountIds) {
        Id studentPortalProfileId = [
            SELECT Id 
            FROM Profile 
            WHERE Name = 'Student Portal User' 
            LIMIT 1
        ].Id;
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Email
            FROM Contact
            WHERE AccountId IN :accountIds
            AND Persona__c LIKE  '%High School Student'
            AND Id NOT IN (
                SELECT ContactId
                FROM User
                WHERE ProfileId = :studentPortalProfileId
                AND isActive = true
            )
        ];
        if (!contacts.isEmpty()) {
            CommunityUserServices.createCommunityUsersFromContacts(
                studentPortalProfileId, 
                contacts
            );
        }
    }
}