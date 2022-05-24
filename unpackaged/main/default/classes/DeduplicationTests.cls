@isTest
private with sharing class DeduplicationTests {

    @TestSetup
    static void makeData(){
        List<String> highSchoolNames = new List<String>{'TEST HIGH SCHOOL', 'Test High School'};
        for(Integer i = 0; i < 2; i++){
            insert new Account(
                Name = highSchoolNames[i],
                First_Name__c = 'Test',
                Last_Name__c = 'High School',
                BillingStreet = '1337 Fake St',
                BillingCity = 'Portland',
                BillingState = 'Oregon',
                BillingCountry = 'United States',
                RecordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('High School Account').getRecordTypeId()
            );
        }
    }

    @isTest
    static void validateCorrectMatches() {
        Test.startTest();
            /* List<Account> accounts = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, 
                                        ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, High_School_Import__c 
                                        FROM Account 
                                        WHERE RecordTypeId = :Schema.sObjectType.Account.getRecordTypeInfosByName().get('High School Account').getRecordTypeId() AND Name LIKE 'TEST HIGH SCHOOL%'];
            Deduplication.findDuplicates(accounts); */
            List<Account> accounts = [SELECT Id FROM Account];
            Id batchId = Database.executeBatch(new DeduplicationBatchClass());
            System.debug([SELECT Id FROM DuplicateRecordSet].size());
        Test.stopTest();
        System.assertEquals(
            [SELECT Id FROM DuplicateRecordSet WHERE ID IN (SELECT DuplicateRecordSetId FROM DuplicateRecordItem WHERE RecordId IN :accounts)].size(),
            1, 
            'Expected to have one DuplicateRecordSet created, related to the records inserted.'
        );
    }

}