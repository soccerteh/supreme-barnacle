@IsTest
public with sharing class StudentInformationTests {

    @TestSetup
    static void makeData(){
        TriggerHandler.suppressHandler('AccountTriggerHandler');
        TriggerHandler.suppressHandler('OpportunityTriggerHandler');
        TriggerHandler.suppressHandler('EnrollmentRecordTriggerHandler');
        TestDataFactory.insertMockCommunityUser();
        TestDataFactory.insertMockPrograms();
        TestDataFactory.insertOpportunityAndEnrollmentForAccount([SELECT Id, Name FROM Account WHERE RecordType.Name = 'Student Account' LIMIT 1]);
        update new Enrollment_Record__c(
            Id = [SELECT Id FROM Enrollment_Record__c LIMIT 1].Id,
            Program__c = [SELECT Id FROM Program__c WHERE Name LIKE '%Fall 2022' LIMIT 1].Id
        );
        TriggerHandler.clearSuppressedHandlers();
    }

    @IsTest
    static void testGetStudentInformation() {
        StudentInformation studentInfo;
        User contextUser = [SELECT Id, Contact.AccountId FROM User WHERE Username = 'CommunityUser@Test.org' LIMIT 1];
        Test.startTest();
        System.runAs(contextuser){
            studentInfo = StudentInformation.getStudentInfosForRunningUser();
        }
        Test.stopTest();
        System.assertEquals(
            contextUser.Contact.AccountId,
            studentInfo.accountId,
            'Expected StudentInformation accountId property to match the Account Id of the running user.'
        );
        System.assertNotEquals(
            null,
            studentInfo.enrollment,
            'Expected enrollment record to be set.'
        );
    }

    @IsTest
    static void testgetAllStudentInfosByAccountIdNoEnrollment() {
        StudentInformation studentInfo;
        delete [SELECT Id FROM Enrollment_Record__c];
        User contextUser = [SELECT Id, Contact.AccountId FROM User WHERE Username = 'CommunityUser@Test.org' LIMIT 1];
        Test.startTest();
        System.runAs(contextuser){
            studentInfo = StudentInformation.getStudentInfosForRunningUser();
        }
        Test.stopTest();
        System.assertNotEquals(
            null,
            studentInfo.accountId,
            'Expected StudentInformation accountId to not be null.'
        );
        System.assertEquals(
            contextUser.Contact.AccountId,
            studentInfo.accountId,
            'Expected StudentInformation accountId property to match the Account Id of the running user.'
        );
        System.assertEquals(
            null,
            studentInfo.enrollment,
            'Expected no enrollment record to be set.'
        );
    }

    @IsTest
    static void testGetAllStudentInfosByAccountId() {
        Id studentAccountId = [SELECT Id FROM Account WHERE Name = 'Community User' LIMIT 1].Id;
        Test.startTest();
        StudentInformation studentInfos = new StudentInformation().getAllStudentInfosByAccountId(studentAccountId);
        Test.stopTest();
        System.assertEquals(
            studentAccountId,
            studentInfos.accountId,
            'Expected accountId queried to match the object\'s accountId property value.'
        );
        System.assertEquals(
            [SELECT Name FROM Program__c LIMIT 1].Name,
            studentInfos.currentProgramName,
            'Expected the Program\'s name from the setup to match the object\'s currentProgramName property value.'
        );
    }
}