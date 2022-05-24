@isTest
public with sharing class GuestFileUtilsTests {

    @TestSetup
    static void makeData(){
        Account sampleAccount = new Account(
            Name = 'Sample Account',
            First_Name__c = 'Sample',
            Last_Name__c = 'Account',
            RecordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId()
        );
        insert sampleAccount;
    }

    @IsTest
    static void testSetGuestFileRelatedRecord(){
        Id relatedRecordId = [SELECT Id FROM Account WHERE Name = 'Sample Account' LIMIT 1].Id;
        Test.startTest();
        ContentVersion file = new ContentVersion(
            VersionData = Blob.valueOf('Hello World'),
            Title = 'Sample File',
            Guest_Site_fileupload__c = relatedRecordId,
            PathOnClient = 'Sample File.pdf'
        );
        insert file;
        Test.stopTest();
        System.assertEquals(
            1,
            [SELECT Id FROM ContentVersion].size(),
            'Expected 1 ContentVersion uploaded, indicating the file was successfully inserted.'
        );
        System.assertEquals(
            1,
            [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :relatedRecordId].size(),
            'Expected 1 ContentDocumentLink tagged to the sample record, indicating it was successfully related.'
        );
    }
}