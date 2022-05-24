@IsTest
public with sharing class TranscriptEvaluationTriggerHandlerTests {
    
    @TestSetup
    static void makeData(){
        TriggerHandler.suppressHandler('AccountTriggerHandler');
        Account communityUserAccount = new Account(
            Name = 'Community User',
            First_Name__c = 'Community',
            Last_Name__c = 'User',
            Email__c = 'CommunityUser@Test.org',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId()
        );
        insert communityUserAccount;
        Contact communityUserContact = new Contact(
            AccountId = communityUserAccount.Id,
            FirstName = 'Community',
            LastName = 'User',
            Email = 'CommunityUser@Test.org',
            Persona__c = 'US High School Student',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId()
        );
        insert communityUserContact;
        insert new User(
            FirstName = 'Context',
            LastName = 'User',
            Email = 'ContextUser@Test.test',
            Username = 'ContextUser@Test.test',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User - Verto' LIMIT 1].Id,
            Alias = 'CUser',
            TimezoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        TriggerHandler.clearSuppressedHandlers();
    }


    @IsTest
    static void testProvisionStudentPortalUsers() {
        Test.startTest();
        Transcript_Evaluation__c evaluation = getDefaultTranscriptEvaluation();
        evaluation.Student__c = [SELECT Id FROM Account WHERE Name = 'Community User' LIMIT 1].Id;
        insert evaluation;
        Test.stopTest();
        System.debug([SELECT Id, Name, UserName, UserType FROM User WHERE CreatedDate = TODAY]);
        System.assertEquals(
            1,
            [SELECT Id FROM User WHERE ProfileId = :getCommunityUserProfile() AND CreatedDate = TODAY].size(),
            'Expected one provisioned student portal user created.'
        );
    }

    @IsTest
    static void tesProvisionStudentPortalUserAsInternalUser() {
        User contextUser = [SELECT Id FROM User WHERE Name = 'Context User' LIMIT 1];
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (PermissionSetGroup permissiongroup :[SELECT Id FROM PermissionSetGroup WHERE MasterLabel IN ('Course Registration - Administration','All Internal Users')]) {
            assignments.add(new PermissionSetAssignment(
            	AssigneeId = contextUser.Id,
                PermissionSetGroupId = permissiongroup.Id
            ));
        }
        insert assignments;
        Test.startTest();
        System.debug([SELECT Id, Name, UserName, UserType FROM User WHERE CreatedDate = TODAY]);
        System.runAs(contextUser) {
            Transcript_Evaluation__c evaluation = getDefaultTranscriptEvaluation();
            evaluation.Student__c = [SELECT Id FROM Account WHERE Name = 'Community User' LIMIT 1].Id;
            insert evaluation;
        }
        Test.stopTest();
        System.assertEquals(
            1,
            [SELECT Id FROM User WHERE ProfileId = :getCommunityUserProfile() AND CreatedDate = TODAY].size(),
            'Expected one provisioned student portal user created.'
        );
    }

    private static Transcript_Evaluation__c getDefaultTranscriptEvaluation() {
        return new Transcript_Evaluation__c(
            Math_Completed__c = 'Algebra II',
            Spanish_Completed__c = 'One Year',
            Junior_Year_English_Grade__c = 'B- or Higher',
            GPA__c = 3.0
        );
    }

    private static Id getCommunityUserProfile() {
        return [
            SELECT Id
            FROM Profile
            WHERE Name = 'Student Portal User'
            LIMIT 1
        ].Id;
    }
}