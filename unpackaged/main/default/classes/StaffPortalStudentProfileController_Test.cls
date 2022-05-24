/**
 * @description       : 
 * @author            : Nick Holly
 * @group             : 
 * @last modified on  : 02-14-2022
 * @last modified by  : NickHolly
**/
@isTest
public with sharing class StaffPortalStudentProfileController_Test {
    /**
    * @description Test data setup. Creates the necessary records for a Portal-enabled User, a Student Account, Student Opportunity, Application__c, and corresponding Share Records.
    * @author Nick Holly | 12-04-2021 
    **/
    @TestSetup
    static void makeData(){
        Account portalAccount = new Account(
            Name = 'London',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Verto Company').getRecordTypeId()
        );
        insert portalAccount;
        Contact portalUserContact = new Contact(
            FirstName = 'Portal',
            LastName = 'User',
            Email = 'PortalUser@test.com',
            AccountId = portalAccount.Id,
            Persona__c = 'SLC',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Program Staff').getRecordTypeId()
        );
        insert portalUserContact;
        User portalUser = new User(
            FirstName = 'Portal',
            LastName = 'User',
            Alias = 'PUser',
            Email = 'PortalUser@test.com',
            EmailEncodingKey = 'UTF-8',
            isActive = true,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Concern Portal User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'PortalUser@test.com',
            ContactId = portalUserContact.Id
        );
        insert portalUser;
        List<SObject> programInfos = new List<SObject>();
        Semester__c semester = new Semester__c(
            Name = 'Spring ' + System.today().addYears(10).year(),
            Delivery_Method__c = 'Abroad',
            Deposit_Due_Date__c = System.today().addMonths(3),
            Tuition_Due_Date__c = System.today().addMonths(3)
        );
        programInfos.add(semester);
        Location__c location = new Location__c(
            Name = 'England',
            Status__c = 'Actively Enrolling'
        );
        programInfos.add(location);
        insert programInfos;
        Program__c firstProgram = new Program__c(
            Name = location.Name + ' - ' + semester.Name,
            Semester__c = semester.Id,
            Location__c = location.Id,
            Status__c = 'Active',
            Program_Start_Date__c = System.today(),
            Program_End_Date__c = System.today().addMonths(3)
        );
        insert firstProgram;
        List<SObject> studentInfos = new List<SObject>();
        Account studentAccount = new Account(
            Name = 'Sample Student',
            First_Name__c = 'Sample',
            Last_Name__c = 'Student',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId()
        );
        studentInfos.add(studentAccount);
        insert studentInfos;
        Application__c studentApplication = new Application__c(
            Name = 'Sample Application__c - ' + System.today().addMonths(-3) + ' - Traditional',
            Applicant_First_Name__c = 'Sample',
            Applicant_Last_Name__c = 'Student',
            Account__c = studentAccount.Id,
            Sex__c = 'Male',
            Race_Ethnicity__c = 'I prefer not to say',
            GPA_Scale__c = '4.0',
            GPA__c = 4.0,
            Application_Status__c = 'Unqualified',
            Source__c = 'Website',
            RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Traditional Enrollment').getRecordTypeId()
        );
        insert studentApplication;
        List<Contact> contacts = new List<Contact>();
        Contact firstParentContact = new Contact(
            AccountId = studentAccount.Id,
            FirstName = 'First',
            LastName = 'Parent',
            Persona__c = 'Parent'
        );
        contacts.add(firstParentContact);
        Contact secondParentContact = new Contact(
            AccountId = studentAccount.Id,
            FirstName = 'Second',
            LastName = 'Parent',
            Persona__c = 'Parent'
        );
        contacts.add(secondParentContact);
        insert contacts;
        List<Opportunity> studentOpps = new List<Opportunity>();
        Opportunity firstSemesterOpportunity = new Opportunity(
            Name = studentAccount.Name + ' - ' + System.today().addMonths(-3),
            AccountId = studentAccount.Id,
            StageName = 'Closed Won',
            CloseDate = System.today().addMonths(-3),
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Traditional Enrollment').getRecordTypeId(),
            Current_Program__c = firstProgram.Id,
            Associated_Application__c = studentApplication.Id
        );
        studentOpps.add(firstSemesterOpportunity);
        insert studentOpps;
        Health_Form__c healthForm = new Health_Form__c(
            Account__c = studentAccount.Id,
            Program__c = firstProgram.Id
        );
        insert healthForm;
        List<SObject> shareRecords = new List<SObject>();
        AccountShare accShare = new AccountShare(
            AccountId = studentAccount.Id,
            AccountAccessLevel = 'Read',
            UserOrGroupId = portalUser.Id,
            OpportunityAccessLevel = 'Read'
        );
        shareRecords.add(accShare);
        OpportunityShare oppShare = new OpportunityShare(
            OpportunityId = firstSemesterOpportunity.Id,
            OpportunityAccessLevel = 'Read',
            UserOrGroupId = portalUser.Id
        );
        shareRecords.add(oppShare);
        Application__Share appShare = new Application__Share(
            ParentId = studentApplication.Id,
            AccessLevel = 'Read',
            UserOrGroupId = portalUser.Id
        );
        shareRecords.add(appShare);
        Health_Form__Share healthFormShare = new Health_Form__Share(
            ParentId = healthForm.Id,
            AccessLevel = 'Read',
            UserOrGroupId = portalUser.Id
        );
        shareRecords.add(healthFormShare);
        List<Database.SaveResult> saveResult = Database.insert(shareRecords, false);
    }

    /**
    * @description Test method for validating a handled exception is thrown from the getParentContactIds method when a null argument is provided.
    * @author Nick Holly | 12-16-2021 
    **/
    @IsTest
    static void testGetParentContactIdsWithNullArg(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'PortalUser@test.com' AND UserType = 'PowerPartner' LIMIT 1];
        Boolean caughtException = false;
        String exceptionType;
        String exceptionMessage;
        Test.startTest();
        System.runAs(contextuser){
            try {
                List<Contact> results = StaffPortalStudentProfileController.getParentContactIds(null);
            } catch (Exception e) {
                caughtException = true;
                exceptionType = e.getTypeName();
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(
            'System.IllegalArgumentException',
            exceptionType,
            'Expected an IllegalArgumentException to be thrown for having a null parameter'
        );
        System.assertEquals(
            'Null inputs are not accepted.', 
            exceptionMessage, 
            'Expected the getParentContacts to throw an IllegalArgumentException with \'Null inputs are not accepted.\' as the message.'
        );
    }

    /**
    * @description Test method for validating a handled exception is thrown from the getParentContactIds method when a non-Account Id argument is provided.
    * @author Nick Holly | 12-16-2021 
    **/
    @IsTest
    static void testGetParentContactIdsWithInvalidArg(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'PortalUser@test.com' AND UserType = 'PowerPartner' LIMIT 1];
        Boolean caughtException = false;
        String exceptionType;
        String exceptionMessage;
        Test.startTest();
        System.runAs(contextuser){
            try {
                //Method expects an account Id, passing in a different ID, from current User, instead to ensure an exception is thrown.
                List<Contact> results = StaffPortalStudentProfileController.getParentContactIds(UserInfo.getUserId());
            } catch (Exception e) {
                caughtException = true;
                exceptionType = e.getTypeName();
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(
            'System.IllegalArgumentException',
            exceptionType,
            'Expected an IllegalArgumentException to be thrown for having a null parameter'
        );
        System.assertEquals(
            'Invalid type of argument received.', 
            exceptionMessage, 
            'Expected the getParentContacts to throw an IllegalArgumentException with \'Invalid type of argument received..\' as the message.'
        );
    }

    /**
    * @description Test method for validating that the appropriate results are returned from the getParentContacts method, given a valid input.
    * @author Nick Holly | 12-16-2021 
    **/
    @IsTest
    static void testGetParentContactIdsWithValidArg(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'PortalUser@test.com' AND UserType = 'PowerPartner' LIMIT 1];
        Boolean caughtException = false;
        Integer resultSize = 0;
        PermissionSetAssignment permissionAssignment = new PermissionSetAssignment(
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE Label = 'Contact Access - Read Only' LIMIT 1].Id,
            AssigneeId = contextUser.Id
        );
        insert permissionAssignment;
        Test.startTest();
        System.runAs(contextuser){
            try {
                Id accountId = [SELECT Id FROM Account WHERE Name = 'Sample Student' LIMIT 1].Id;
                List<Contact> results = StaffPortalStudentProfileController.getParentContactIds(accountId);
                resultSize = results.size();
            } catch (Exception e) {
                caughtException = true;
            }
        }
        Test.stopTest();
        System.assertEquals(
            false,
            caughtException, 
            'Expected no exceptions thrown, so caughtException must be false.'
        );
        System.assertEquals(
            2,
            resultSize,
            'Expected 2 Contacts to be returned.'
        );
    }

    /**
    * @description Test method for validating that a handled exception is thrown from the getParentContactIds method if the running user does not have field or object level access to Applications.
    * @author Nick Holly | 12-16-2021 
    **/
    @IsTest
    static void testGetParentContactIdsWithoutFieldAccess(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'PortalUser@test.com' AND UserType = 'PowerPartner' LIMIT 1];
        Boolean caughtException = false;
        String exceptionType;
        String exceptionMessage;
        Test.startTest();
        System.runAs(contextuser){
            try {
                Id accountId = [SELECT Id FROM Account WHERE Name = 'Sample Student' LIMIT 1].Id;
                List<Contact> results = StaffPortalStudentProfileController.getParentContactIds(accountId);
            } catch (Exception e) {
                caughtException = true;
                exceptionType = e.getTypeName();
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(
            true,
            caughtException, 
            'Expected an exception thrown, so caughtException must be true.'
        );
        System.assertEquals(
            'System.AuraHandledException',
            exceptionType,
            'Expected an AuraHandledException to be thrown when trying to access unpermitted fields.'
        );
        System.assertEquals(
            'Script-thrown exception', 
            exceptionMessage, 
            'Expected the getParentContacts to throw an IllegalArgumentException with \'Script Thrown Exception.\' as the message.'
        );
    }
    
    /**
    * @description Test method for validating a handled exception is thrown from the getMostRecentApplicationId method when a non-Account Id argument is provided.
    * @author Nick Holly | 12-16-2021 
    **/
    @IsTest
    static void testGetMostRecentApplicationIdWithNullArg(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'PortalUser@test.com' AND UserType = 'PowerPartner' LIMIT 1];
        Boolean caughtException = false;
        String exceptionType;
        String exceptionMessage;
        Test.startTest();
        System.runAs(contextuser){
            try {
                Id results = StaffPortalStudentProfileController.getMostRecentApplicationId(null);
            } catch (Exception e) {
                caughtException = true;
                exceptionType = e.getTypeName();
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(
            'System.IllegalArgumentException',
            exceptionType,
            'Expected an IllegalArgumentException to be thrown for having a null parameter'
        );
        System.assertEquals(
            'Null inputs are not accepted.', 
            exceptionMessage, 
            'Expected the getParentContacts to throw an IllegalArgumentException with \'Null inputs are not accepted.\' as the message.'
        );
    }

    /**
    * @description Test method for validating a handled exception is thrown from the getMostRecentApplicationId method when a non-Account Id argument is provided.
    * @author Nick Holly | 12-16-2021 
    **/
    @IsTest
    static void testGetMostRecentApplicationIdWithInvalidArg(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'PortalUser@test.com' AND UserType = 'PowerPartner' LIMIT 1];
        Boolean caughtException = false;
        String exceptionType;
        String exceptionMessage;
        Test.startTest();
        System.runAs(contextuser){
            try {
                //Method expects an account Id, passing in a different ID, from current User, instead to ensure an exception is thrown.
                Id results = StaffPortalStudentProfileController.getMostRecentApplicationId(UserInfo.getUserId());
            } catch (Exception e) {
                caughtException = true;
                exceptionType = e.getTypeName();
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(
            'System.IllegalArgumentException',
            exceptionType,
            'Expected an IllegalArgumentException to be thrown for having a null parameter'
        );
        System.assertEquals(
            'Invalid type of argument received.', 
            exceptionMessage, 
            'Expected the getParentContacts to throw an IllegalArgumentException with \'Invalid type of argument received..\' as the message.'
        );
    }

    /**
    * @description Test method for validating that the appropriate results are returned from the getMostRecentApplicationId method, given a valid input.
    * @author Nick Holly | 12-16-2021 
    **/
    @IsTest
    static void testGetMostRecentApplicationIdWithValidArg(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'PortalUser@test.com' AND UserType = 'PowerPartner' LIMIT 1];
        Boolean caughtException = false;
        Id resultId;
        PermissionSetAssignment permissionAssignment = new PermissionSetAssignment(
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE Label = 'Application Access - Read Only' LIMIT 1].Id,
            AssigneeId = contextUser.Id
        );
        insert permissionAssignment;
        Test.startTest();
        System.runAs(contextuser){
            try {
                Id accountId = [SELECT Id FROM Account WHERE Name = 'Sample Student' LIMIT 1].Id;
                resultId = StaffPortalStudentProfileController.getMostRecentApplicationId(accountId);

            } catch (Exception e) {
                caughtException = true;
            }
        }
        Test.stopTest();
        System.assertEquals(
            false,
            caughtException, 
            'Expected no exceptions thrown, so caughtException must be false.'
        );
        System.assertEquals(
            [SELECT Id FROM Application__c WHERE Account__r.Name = 'Sample Student' LIMIT 1].Id,
            resultId,
            'Expected Application ID from testSetup to be returned.'
        );
    }

    /**
    * @description Test method for validating that a handled exception is thrown from the getMostRecentApplicationId method if the running user does not have field or object level access to Applications.
    * @author Nick Holly | 12-16-2021 
    **/
    @IsTest
    static void testGetMostRecentApplicationIdWithoutFieldAccess(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'PortalUser@test.com' AND UserType = 'PowerPartner' LIMIT 1];
        Boolean caughtException = false;
        String exceptionType;
        String exceptionMessage;
        Test.startTest();
        System.runAs(contextuser){
            try {
                Id accountId = [SELECT Id FROM Account WHERE Name = 'Sample Student' LIMIT 1].Id;
                Id results = StaffPortalStudentProfileController.getMostRecentApplicationId(accountId);
            } catch (Exception e) {
                caughtException = true;
                exceptionType = e.getTypeName();
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(
            true,
            caughtException, 
            'Expected an exception thrown, so caughtException must be true.'
        );
        System.assertEquals(
            'System.AuraHandledException',
            exceptionType,
            'Expected an AuraHandledException to be thrown when trying to access unpermitted fields.'
        );
        System.assertEquals(
            'Script-thrown exception', 
            exceptionMessage, 
            'Expected the getParentContacts to throw an IllegalArgumentException with \'Script Thrown Exception.\' as the message.'
        );
    }
    /**
    * @description Test method for validating a handled exception is thrown from the getMostRecentHealthFormId method when a non-Account Id argument is provided.
    * @author Nick Holly | 12-16-2021 
    **/
    @IsTest
    static void testGetMostRecentHealthFormIdWithNullArg(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'PortalUser@test.com' AND UserType = 'PowerPartner' LIMIT 1];
        Boolean caughtException = false;
        String exceptionType;
        String exceptionMessage;
        Test.startTest();
        System.runAs(contextuser){
            try {
                Id results = StaffPortalStudentProfileController.getMostRecentHealthFormId(null);
            } catch (Exception e) {
                caughtException = true;
                exceptionType = e.getTypeName();
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(
            'System.IllegalArgumentException',
            exceptionType,
            'Expected an IllegalArgumentException to be thrown for having a null parameter'
        );
        System.assertEquals(
            'Null inputs are not accepted.', 
            exceptionMessage, 
            'Expected the getParentContacts to throw an IllegalArgumentException with \'Null inputs are not accepted.\' as the message.'
        );
    }

    /**
    * @description Test method for validating a handled exception is thrown from the getMostRecentHealthFormId method when a non-Account Id argument is provided.
    * @author Nick Holly | 12-16-2021 
    **/
    @IsTest
    static void testGetMostRecentHealthFormIdWithInvalidArg(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'PortalUser@test.com' AND UserType = 'PowerPartner' LIMIT 1];
        Boolean caughtException = false;
        String exceptionType;
        String exceptionMessage;
        Test.startTest();
        System.runAs(contextuser){
            try {
                //Method expects an account Id, passing in a different ID, from current User, instead to ensure an exception is thrown.
                Id results = StaffPortalStudentProfileController.getMostRecentHealthFormId(UserInfo.getUserId());
            } catch (Exception e) {
                caughtException = true;
                exceptionType = e.getTypeName();
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(
            'System.IllegalArgumentException',
            exceptionType,
            'Expected an IllegalArgumentException to be thrown for having a null parameter'
        );
        System.assertEquals(
            'Invalid type of argument received.', 
            exceptionMessage, 
            'Expected the getParentContacts to throw an IllegalArgumentException with \'Invalid type of argument received..\' as the message.'
        );
    }

    /**
    * @description Test method for validating that the appropriate results are returned from the getMostRecentHealthFormId method, given a valid input.
    * @author Nick Holly | 12-16-2021 
    **/
    @IsTest
    static void testGetMostRecentHealthFormIdWithValidArg(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'PortalUser@test.com' AND UserType = 'PowerPartner' LIMIT 1];
        Boolean caughtException = false;
        String exceptionType;
        String exceptionMessage;
        Id resultId;
        PermissionSetAssignment permissionAssignment = new PermissionSetAssignment(
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE Label = 'Health Form Access - Read Only' LIMIT 1].Id,
            AssigneeId = contextUser.Id
        );
        insert permissionAssignment;
        Test.startTest();
        System.runAs(contextuser){
            try {
                Id accountId = [SELECT Id FROM Account WHERE Name = 'Sample Student' LIMIT 1].Id;
                resultId = StaffPortalStudentProfileController.getMostRecentHealthFormId(accountId);
            } catch (Exception e) {
                caughtException = true;
                exceptionType = e.getTypeName();
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(
            false,
            caughtException, 
            'Expected no exceptions thrown, so caughtException must be false.'
        );
        System.assertEquals(
            [SELECT Id FROM Health_Form__c WHERE Account__r.Name = 'Sample Student' LIMIT 1].Id,
            resultId,
            'Expected healthForm ID from testSetup to be returned.'
        );
    }

    /**
    * @description Test method for validating that a handled exception is thrown from the getMostRecentHealthFormId method if the running user does not have field or object level access to Applications.
    * @author Nick Holly | 12-16-2021 
    **/
    @IsTest
    static void testGetMostRecentHealthFormIdWithoutFieldAccess(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'PortalUser@test.com' AND UserType = 'PowerPartner' LIMIT 1];
        Boolean caughtException = false;
        String exceptionType;
        String exceptionMessage;
        Test.startTest();
        System.runAs(contextuser){
            try {
                Id accountId = [SELECT Id FROM Account WHERE Name = 'Sample Student' LIMIT 1].Id;
                Id results = StaffPortalStudentProfileController.getMostRecentHealthFormId(accountId);
            } catch (Exception e) {
                caughtException = true;
                exceptionType = e.getTypeName();
                exceptionMessage = e.getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(
            true,
            caughtException, 
            'Expected an exception thrown, so caughtException must be true.'
        );
        System.assertEquals(
            'System.AuraHandledException',
            exceptionType,
            'Expected an AuraHandledException to be thrown when trying to access unpermitted fields.'
        );
        System.assertEquals(
            'Script-thrown exception', 
            exceptionMessage, 
            'Expected the getParentContacts to throw an IllegalArgumentException with \'Script Thrown Exception.\' as the message.'
        );
    }
}