@IsTest
public with sharing class SObjectHelperTests {

    @IsTest
    static void testSetCurrentValues() {
        Test.startTest();
        Account sampleAccount = new Account(
            Name = 'Sample Account',
            First_Name__c = 'Sample',
            Last_Name__c = 'Account'
        );
        SObjectHelper objectHelper = new SObjectHelper().setCurrentValues(sampleAccount);
        Test.stopTest();
        System.assertEquals(
            sampleAccount,
            objectHelper.getCurrentValues(),
            'Expected the sample account to be set as the record property for SObjectHelper instance.'
        );
    }

    @IsTest
    static void testSetOldValues() {
        String exceptionMessage;
        Test.startTest();
        Account sampleAccount = new Account(
            Name = 'Sample Account',
            First_Name__c = 'Sample',
            Last_Name__c = 'Account'
        );
        SObjectHelper objectHelper = new SObjectHelper().setOldValues(sampleAccount);
        try {
            Account firstAccount = new Account(
                Name = 'Sample Account',
                First_Name__c = 'First',
                Last_Name__c = 'Account'
            );
            insert firstAccount;
            Account secondAccount = new Account(
                Name = 'Sample Account',
                First_Name__c = 'Second',
                Last_Name__c = 'Account'
            );
            insert secondAccount;
            new SObjectHelper().setCurrentValues(firstAccount).setOldValues(secondAccount);
        } catch (SObjectHelper.SObjectHelperException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(
            sampleAccount,
            objectHelper.getOldValues(),
            'Expected the sample account to be set as the oldRecord property for SObjectHelper instance.'
        );
        System.assertEquals(
            'Values must be for the same record.',
            exceptionMessage,
            'Expected an exception to be thrown when setting old values for a different record.'    
        );
    }

    @IsTest
    static void testGetChangedFields() {
        String exceptionMessage;
        Test.startTest();
        try {
            new SObjectHelper().getChangedFields();
        } catch (SObjectHelper.SObjectHelperException e) {
            exceptionMessage = e.getMessage();
        }
        SObjectHelper objectHelper = new SObjectHelper().setOldValues(new Account(
            Name = 'Sample Account',
            First_Name__c = 'Sample',
            Last_Name__c = 'Account'
        ));
        objectHelper.setCurrentValues(new Account(
            Name = 'Sample Account',
            First_Name__c = 'New',
            Last_Name__c = 'Name',
            Phone = '888-888-8888'
        ));
        List<String> changedFields = objectHelper.getChangedFields();
        Test.stopTest();
        System.assertEquals(
            'Current Values and Old Values must be set before evaluation.',
            exceptionMessage,
            'Expected an exception to be thrown when the current and old values are not set.'
        );
        System.assertEquals(
            3,
            changedFields.size(),
            'Expected three fields to be identified as changed.'
        );
        System.assertEquals(
            true,
            changedFields.contains('First_Name__c'),
            'Expected changed fields to include First_Name__c.'
        );
        System.assertEquals(
            true,
            changedFields.contains('Last_Name__c'),
            'Expected changed fields to include Last_Name__c.'
        );
        System.assertEquals(
            true,
            changedFields.contains('Phone'),
            'Expected changed fields to include Phone.'
        );
    }
}