public without sharing class VertoPassportUploadHelperWS {

    public static SObject insertRecord(SObject record) {
        if(record == null) {
            return null;
        }
        insert record;
        return record;
    }

    public static Enrollment_Record__c getEnrollmentRecord(
        Id accountId,
        Id programId    
    ) {
        if(
            String.valueOf(accountId.getSobjectType()) != String.valueOf(Account.getSObjectType()) || 
            String.valueOf(programId.getSobjectType()) != String.valueOf(Program__c.getSObjectType())
        ) {
           throw new IllegalArgumentException('Invalid parameters received.'); 
        }
        return [SELECT Id, Owner__c
        FROM Enrollment_Record__c
        WHERE Student_Account__c = :accountId
        AND Program__c = :programId
        LIMIT 1];
    }
}