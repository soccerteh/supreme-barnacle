@isTest
public with sharing class ContentDocumentTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Account accountRecord = new Account(
            Name = 'Test Account',
            First_Name__c = 'Test',
            Last_Name__c = 'Account'
        );
        insert accountRecord;
    }
    
    @isTest
    static void testRenamedFileUpdatingAccount() {
        Account acct = [SELECT Id, Check_500_Word_Writing_Sample__c, D_500_Word_Writing_Sample_Submitted_On__c, LastModifiedDate FROM Account];
        System.debug(acct);
        Test.startTest();
        FilesUtils.createFileFromStringAttachedToRecord(
            'Sample File',
            acct.Id
        );
        ContentDocument file = [SELECT Fields(Standard) FROM ContentDocument WHERE Title = 'Sample File.pdf'];
        file.Title = '500 Word Writing Sample';
        update file;
        Test.stopTest();
        acct = [SELECT Id, Check_500_Word_Writing_Sample__c, D_500_Word_Writing_Sample_Submitted_On__c, LastModifiedDate FROM Account];
        System.debug(acct);
        System.assertEquals(
            True,
            acct.Check_500_Word_Writing_Sample__c,
            'Expected to find flag set for Account'
        );
        System.assertEquals(
            System.today(),
            acct.D_500_Word_Writing_Sample_Submitted_On__c,
            'Expected to find the date set to Today for Account'
        );
    }
}