@isTest
public with sharing class ContentVersionTriggerHandler_Tests {
    @TestSetup
    static void makeData() {
        Account accountRecord = new Account(
            Name = 'Test Account',
            First_Name__c = 'Test',
            Last_Name__c = 'Account'
        );
        insert accountRecord;
        Opportunity opportunityRecord = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = accountRecord.Id,
            StageName = 'Qualification',
            CloseDate = System.today().addDays(7)
        );
        insert opportunityRecord;
    }
    @IsTest
    static void testUpdateFormSubmissions() {
        Opportunity opportunityRecord = [SELECT Id, AccountId, StageName, CloseDate FROM Opportunity LIMIT 1];
        Test.startTest();
        FilesUtils.createFileFromStringAttachedToRecord(
            'High School Transcript',
            opportunityRecord.Id
        );
        FilesUtils.createFileFromStringAttachedToRecord(
            '500 Word Writing Sample',
            opportunityRecord.Id
        );
        FilesUtils.createFileFromStringAttachedToRecord(
            'Letter of Recommendation',
            opportunityRecord.Id
        );
        Account accountRecord = [SELECT Id, Check_High_School_Transcript__c, D_High_School_Transcript_Submitted_On__c,
                                Check_500_Word_Writing_Sample__c, D_500_Word_Writing_Sample_Submitted_On__c,
                                Check_1st_Letter_of_Recommendation__c, D1_Letter_of_Recommendation_Submitted_On__c
                                FROM Account LIMIT 1];
        Test.stopTest();
        System.assertEquals(
            True, 
            accountRecord.Check_High_School_Transcript__c, 
            'Expected to find the High School Transcript checkbox marked as true'
        );
        System.assertEquals(
            System.today(),
            accountRecord.D_High_School_Transcript_Submitted_On__c,
            'Expected to find the High School Transcript Submitted On set as the current date'
        );
        System.assertEquals(
            True, 
            accountRecord.Check_500_Word_Writing_Sample__c, 
            'Expected to find the 500 Word Writing Sample checkbox marked as true'
        );
        System.assertEquals(
            System.today(),
            accountRecord.D_500_Word_Writing_Sample_Submitted_On__c,
            'Expected to find the 500 Word Writing Sample Submitted On set as the current date'
        );
        System.assertEquals(
            True, 
            accountRecord.Check_1st_Letter_of_Recommendation__c, 
            'Expected to find the Letter of Recommendation checkbox marked as true'
        );
        System.assertEquals(
            System.today(),
            accountRecord.D1_Letter_of_Recommendation_Submitted_On__c,
            'Expected to find the Letter of Recommendation Submitted On set as the current date'
        );
    }

    @isTest
    static void testRelocateFile() {
        Opportunity opportunityRecord = [SELECT Id, AccountId, StageName, CloseDate FROM Opportunity LIMIT 1];
        Test.startTest();
        FilesUtils.createFileFromStringAttachedToRecord(
            'Hello World',
            opportunityRecord.Id
        );
        List<ContentVersion> accountFiles = FilesUtils.getFilteredAttachmentsForRecord(
            FilesUtils.genericFileType.ALL,
            opportunityRecord.AccountId
        );
        List<ContentVersion> opportunityFiles = FilesUtils.getFilteredAttachmentsForRecord(
            FilesUtils.GenericFileType.ALL,
            opportunityRecord.Id
        );
        Test.stopTest();
        System.assertEquals(
            1,
            accountFiles.size(),
            'Expected to find 1 file associated to the account'
        );
        System.assertEquals(
            1,
            opportunityFiles.size(),
            'Expected to find 1 file associated to the account'
        );
    }
}