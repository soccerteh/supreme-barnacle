public with sharing class StaffPortalStudentProfileController {

    @AuraEnabled(cacheable=true)
    public static Id getMostRecentHealthFormId(String recordId) {
        if (recordId == null) {
            throw new IllegalArgumentException('Null inputs are not accepted.');
        }
        Id accountId = Id.valueOf(recordId);
        if (String.valueOf(accountId.getSobjectType()) != Account.getSObjectType().getDescribe().getName()) {
            throw new IllegalArgumentException('Invalid type of argument received.');
        }
        try {
            return [
                SELECT Id
                FROM Health_Form__c
                WHERE Account__c = :accountId
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC
                LIMIT 1
            ]?.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getParentContactIds(String recordId) {
        if (recordId == null) {
            throw new IllegalArgumentException('Null inputs are not accepted.');
        }
        Id accountId = Id.valueOf(recordId);
        if (String.valueOf(accountId.getSobjectType()) != Account.sObjectType.getDescribe().getName()) {
            throw new IllegalArgumentException('Invalid type of argument received.');
        }
        try {
            return [
                SELECT Id, Name
                FROM Contact
                WHERE AccountId = :accountId
                AND Persona__c = 'Parent'
                WITH SECURITY_ENFORCED
            ];
        } catch (QueryException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Id getMostRecentApplicationId(String recordId) {
        if (recordId == null) {
            throw new IllegalArgumentException('Null inputs are not accepted.');
        }
        Id accountId = Id.valueOf(recordId);
        if (String.valueOf(accountId.getSobjectType()) != Account.getSObjectType().getDescribe().getName()) {
            throw new IllegalArgumentException('Invalid type of argument received.');
        }
        try {
            return [
                SELECT Id
                FROM Application__c
                WHERE Account__c = :accountId
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC
                LIMIt 1
            ]?.Id;
        } catch (QueryException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}