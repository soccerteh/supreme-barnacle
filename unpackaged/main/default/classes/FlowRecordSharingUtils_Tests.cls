@isTest
public with sharing class FlowRecordSharingUtils_Tests {

    @TestSetup
    static void makeData(){
        Account studentAccount = new Account(
            Name = 'Sample Student',
            First_Name__c = 'Sample',
            Last_Name__c = 'Student',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId()
        );
        insert studentAccount;
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
            Source__c = 'Website'
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
            Associated_Application__c = studentApplication.Id
        );
        studentOpps.add(firstSemesterOpportunity);
        insert studentOpps;
        Enrollment_Record__c enrollmentRecord = [SELECT Id FROM Enrollment_Record__c WHERE Opportunity__c = :firstSemesterOpportunity.Id LIMIT 1];
        enrollmentRecord.Owner__c = UserInfo.getUserId();
        update enrollmentRecord;
        Id enrollmentRecordId = enrollmentRecord.Id;
        List<SObject> additionalRecords = new List<SObject>();
        Health_Form__c healthForm = new Health_Form__c(
            Name = 'Sample Health Form',
            Enrollment_Record__c = enrollmentRecordId,
            Account__c = studentAccount.Id
        );
        additionalRecords.add(healthForm);
        Checkpoint__c checkpoint = new Checkpoint__c(
            Enrollment_Record__c = enrollmentRecordId,
            Due_Date__c = System.today().addMonths(1)
        );
        additionalRecords.add(checkpoint);
        insert additionalRecords;
        Account portalAccount = new Account(
            Name = 'London',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Verto Company').getRecordTypeId()
        );
        insert portalAccount;
        List<Contact> portalContacts = new List<Contact>();
        Contact sampleUserContact = new Contact(
            FirstName = 'Sample',
            LastName = 'User',
            Email = 'SampleUser@VertoEducation.org',
            AccountId = portalAccount.Id,
            Persona__c = 'SLC',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Program Staff').getRecordTypeId()
        );
        portalContacts.add(sampleUserContact);
        Contact additionalUserContact = new Contact(
            FirstName = 'Additional',
            LastName = 'User',
            Email = 'AdditionalUser@VertoEducation.org',
            AccountId = portalAccount.Id,
            Persona__c = 'ASC',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Program Staff').getRecordTypeId()
        );
        portalContacts.add(additionalUserContact);
        insert portalContacts;
        List<User> users = new List<User>();
        User sampleUser = new User(
            FirstName = 'Sample',
            LastName = 'User',
            Alias = 'SUser',
            Email = 'SampleUser@VertoEducation.org',
            EmailEncodingKey = 'UTF-8',
            isActive = true,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner Community User - Verto' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'SampleUser@VertoEducation.org',
            ContactId = sampleUserContact.Id
        );
        users.add(sampleUser);
        User additionalUser = new User(
            FirstName = 'Additional',
            LastName = 'User',
            Alias = 'SUser',
            Email = 'AdditionalUser@VertoEducation.org',
            EmailEncodingKey = 'UTF-8',
            isActive = true,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner Community User - Verto' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'AdditionalUser@VertoEducation.org',
            ContactId = additionalUserContact.Id
        );
        users.add(additionalUser);
        insert users;
    }

    @IsTest
    static void testAccountSharing(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'SampleUser@VertoEducation.org'];
        FlowRecordSharingUtils.ShareRecordProfile shareProfile = new FlowRecordSharingUtils.ShareRecordProfile();
        Id accountId = [SELECT Id FROM Account WHERE Name = 'Sample Student' LIMIT 1].Id;
        shareProfile.recordId = accountId;
        shareProfile.userOrGroupId = contextUser.Id;
        shareProfile.lookupField = 'AccountId';
        shareProfile.sObjectName = 'Account';
        shareProfile.shareSObjectName = 'AccountShare';
        shareProfile.accessLevel = 'Read';
        shareProfile.accessFieldName = 'AccountAccessLevel';
        shareProfile.deleteExistingSharingRecords = false;
        Test.startTest();
        System.runAs(contextuser){
            FlowRecordSharingUtils.getShareRecords(new List<FlowRecordSharingUtils.ShareRecordProfile>{shareProfile});
            System.assertEquals(
                1,
                [SELECT Id FROM Account WHERE RecordType.Name = 'Student Account'].size(),
                'Expected to see 1 account shared with user.'
            );
        }
        Test.stopTest();
        List<AccountShare> shareRecords = [SELECT Id, AccountId, UserOrGroupId, RowCause, AccountAccessLevel 
            FROM AccountShare 
            WHERE UserOrGroupId = :contextUser.Id
            AND AccountId = :accountId
        ];
        System.assertEquals(
            1,
            shareRecords.size(),
            'Expected to find 1 AccountShare record created.'
        );
        System.assertEquals(
            'Manual',
            shareRecords[0].RowCause,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            'Read',
            shareRecords[0].AccountAccessLevel,
            'Expected RowCause to be Manual sharing.'
        );
    }

    @IsTest
    static void testAccountSharingAndUnsharing(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'SampleUser@VertoEducation.org' LIMIT 1];
        User additionalUser = [SELECT Id FROM User WHERE UserName = 'AdditionalUser@VertoEducation.org' LIMIT 1];
        Id accountId = [SELECT Id FROM Account WHERE Name = 'Sample Student' LIMIT 1].Id;
        FlowRecordSharingUtils.ShareRecordProfile shareProfile = new FlowRecordSharingUtils.ShareRecordProfile();
        shareProfile.recordId = accountId;
        shareProfile.userOrGroupId = additionalUser.Id;
        shareProfile.previousUserOrGroupId = contextUser.Id;
        shareProfile.lookupField = 'AccountId';
        shareProfile.sObjectName = 'Account';
        shareProfile.shareSObjectName = 'AccountShare';
        shareProfile.accessLevel = 'Read';
        shareProfile.accessFieldName = 'AccountAccessLevel';
        shareProfile.deleteExistingSharingRecords = true;
        AccountShare oldShare = new AccountShare(
            AccountId = accountId,
            UserOrGroupId = contextUser.Id,
            AccountAccessLevel = 'Read',
            OpportunityAccessLevel = 'Read'
        );
        insert oldShare;
        Test.startTest();
        System.runAs(contextuser){
            FlowRecordSharingUtils.getShareRecords(new List<FlowRecordSharingUtils.ShareRecordProfile>{shareProfile});
            System.assertEquals(
                0,
                [SELECT Id FROM Account WHERE RecordType.Name = 'Student Account'].size(),
                'Expected to see no accounts shared with user.'
            );
        }
        Test.stopTest();
        List<AccountShare> shareRecords = [SELECT Id, AccountId, UserOrGroupId, RowCause, AccountAccessLevel 
            FROM AccountShare 
            WHERE UserOrGroupId = :additionalUser.Id
            AND AccountId = :accountId
        ];
        System.assertEquals(
            1,
            shareRecords.size(),
            'Expected to find 1 AccountShare record created.'
        );
        System.assertEquals(
            'Manual',
            shareRecords[0].RowCause,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            'Read',
            shareRecords[0].AccountAccessLevel,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            additionalUser.Id,
            shareRecords[0].UserOrGroupId,
            'Expected to be the shared with Additional User.'
        );
    }

    @IsTest
    static void testOpportunitySharing(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'SampleUser@VertoEducation.org'];
        Id opportunityId = [SELECT Id FROM Opportunity WHERE Account.Name = 'Sample Student' LIMIT 1].Id;
        FlowRecordSharingUtils.ShareRecordProfile shareProfile = new FlowRecordSharingUtils.ShareRecordProfile();
        shareProfile.recordId = opportunityId;
        shareProfile.userOrGroupId = contextUser.Id;
        shareProfile.lookupField = 'OpportunityId';
        shareProfile.sObjectName = 'Opportunity';
        shareProfile.shareSObjectName = 'OpportunityShare';
        shareProfile.accessLevel = 'Read';
        shareProfile.accessFieldName = 'OpportunityAccessLevel';
        shareProfile.deleteExistingSharingRecords = false;
        Test.startTest();
        System.runAs(contextuser){
            FlowRecordSharingUtils.getShareRecords(new List<FlowRecordSharingUtils.ShareRecordProfile>{shareProfile});
            System.assertEquals(
                1,
                [SELECT Id FROM Opportunity WHERE Id = :opportunityId LIMIT 1].size(),
                'Expected to see 1 Opportunity shared with user.'
            );
        }
        Test.stopTest();
        List<OpportunityShare> shareRecords = [SELECT Id, OpportunityId, UserOrGroupId, RowCause, OpportunityAccessLevel 
            FROM OpportunityShare 
            WHERE UserOrGroupId = :contextUser.Id
            AND OpportunityId = :opportunityId
        ];
        System.assertEquals(
            1,
            shareRecords.size(),
            'Expected to find 1 OpportunityShare record created.'
        );
        System.assertEquals(
            'Manual',
            shareRecords[0].RowCause,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            'Read',
            shareRecords[0].OpportunityAccessLevel,
            'Expected RowCause to be Manual sharing.'
        );
    }

    @IsTest
    static void testOpportunitySharingAndUnsharing(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'SampleUser@VertoEducation.org'];
        User additionalUser = [SELECT Id FROM User WHERE UserName = 'AdditionalUser@VertoEducation.org' LIMIT 1];
        Id opportunityId = [SELECT Id FROM Opportunity WHERE Account.Name = 'Sample Student' LIMIT 1].Id;
        FlowRecordSharingUtils.ShareRecordProfile shareProfile = new FlowRecordSharingUtils.ShareRecordProfile();
        shareProfile.recordId = opportunityId;
        shareProfile.userOrGroupId = additionalUser.Id;
        shareProfile.previousUserOrGroupId = contextUser.Id;
        shareProfile.lookupField = 'OpportunityId';
        shareProfile.sObjectName = 'Opportunity';
        shareProfile.shareSObjectName = 'OpportunityShare';
        shareProfile.accessLevel = 'Read';
        shareProfile.accessFieldName = 'OpportunityAccessLevel';
        shareProfile.deleteExistingSharingRecords = true;
        OpportunityShare oldShare = new OpportunityShare(
            OpportunityId = opportunityId,
            UserOrGroupId = contextUser.Id,
            OpportunityAccessLevel = 'Read'
        );
        insert oldShare;
        Test.startTest();
        System.runAs(contextuser){
            FlowRecordSharingUtils.getShareRecords(new List<FlowRecordSharingUtils.ShareRecordProfile>{shareProfile});
            System.assertEquals(
                0,
                [SELECT Id FROM Opportunity WHERE Id = :opportunityId LIMIT 1].size(),
                'Expected to see no opportunities shared with user.'
            );
        }
        Test.stopTest();
        List<OpportunityShare> shareRecords = [SELECT Id, OpportunityId, UserOrGroupId, RowCause, OpportunityAccessLevel 
            FROM OpportunityShare 
            WHERE UserOrGroupId = :additionalUser.Id
            AND OpportunityId = :opportunityId
        ];
        System.assertEquals(
            1,
            shareRecords.size(),
            'Expected to find 1 OpportunityShare record created.'
        );
        System.assertEquals(
            'Manual',
            shareRecords[0].RowCause,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            'Read',
            shareRecords[0].OpportunityAccessLevel,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            additionalUser.Id,
            shareRecords[0].UserOrGroupId,
            'Expected to be the shared with Additional User.'
        );
    }
    
    @IsTest
    static void testApplicationSharing(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'SampleUser@VertoEducation.org'];
        Id applicationId = [SELECT Id FROM Application__c WHERE Account__r.Name = 'Sample Student' LIMIT 1].Id;
        FlowRecordSharingUtils.ShareRecordProfile shareProfile = new FlowRecordSharingUtils.ShareRecordProfile();
        shareProfile.recordId = applicationId;
        shareProfile.userOrGroupId = contextUser.Id;
        shareProfile.lookupField = 'ParentId';
        shareProfile.sObjectName = 'Application__c';
        shareProfile.shareSObjectName = 'Application__Share';
        shareProfile.accessLevel = 'Read';
        shareProfile.accessFieldName = 'AccessLevel';
        shareProfile.deleteExistingSharingRecords = false;
        Test.startTest();
        System.runAs(contextuser){
            FlowRecordSharingUtils.getShareRecords(new List<FlowRecordSharingUtils.ShareRecordProfile>{shareProfile});
            System.assertEquals(
                1,
                [SELECT Id FROM Application__c WHERE Id = :applicationId].size(),
                'Expected to see 1 application shared with user.'
            );
        }
        Test.stopTest();
        List<Application__Share> shareRecords = [SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel 
            FROM Application__Share 
            WHERE UserOrGroupId = :contextUser.Id
            AND ParentId = :applicationId
        ];
        System.assertEquals(
            1,
            shareRecords.size(),
            'Expected to find 1 Application__Share record created.'
        );
        System.assertEquals(
            'Manual',
            shareRecords[0].RowCause,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            'Read',
            shareRecords[0].AccessLevel,
            'Expected RowCause to be Manual sharing.'
        );
    }

    @IsTest
    static void testApplicationSharingAndUnsharing(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'SampleUser@VertoEducation.org' LIMIT 1];
        User additionalUser = [SELECT Id FROM User WHERE UserName = 'AdditionalUser@VertoEducation.org' LIMIT 1];
        Id applicationId = [SELECT Id FROM Application__c WHERE Account__r.Name = 'Sample Student' LIMIT 1].Id;
        FlowRecordSharingUtils.ShareRecordProfile shareProfile = new FlowRecordSharingUtils.ShareRecordProfile();
        shareProfile.recordId = applicationId;
        shareProfile.userOrGroupId = additionalUser.Id;
        shareProfile.previousUserOrGroupId = contextUser.Id;
        shareProfile.lookupField = 'ParentId';
        shareProfile.sObjectName = 'Application__c';
        shareProfile.shareSObjectName = 'Application__Share';
        shareProfile.accessLevel = 'Read';
        shareProfile.accessFieldName = 'AccessLevel';
        shareProfile.deleteExistingSharingRecords = true;
        Application__Share oldShare = new Application__Share(
            ParentId = applicationId,
            UserOrGroupId = contextUser.Id,
            AccessLevel = 'Read'
        );
        insert oldShare;
        Test.startTest();
        System.runAs(contextuser){
            FlowRecordSharingUtils.getShareRecords(new List<FlowRecordSharingUtils.ShareRecordProfile>{shareProfile});
            System.assertEquals(
                0,
                [SELECT Id FROM Application__c WHERE Id = :applicationId].size(),
                'Expected to see no application shared with user.'
            );
        }
        Test.stopTest();
        List<Application__Share> shareRecords = [SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel 
            FROM Application__Share 
            WHERE UserOrGroupId = :additionalUser.Id
            AND ParentId = :applicationId
        ];
        System.assertEquals(
            1,
            shareRecords.size(),
            'Expected to find 1 Application__Share record created.'
        );
        System.assertEquals(
            'Manual',
            shareRecords[0].RowCause,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            'Read',
            shareRecords[0].AccessLevel,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            additionalUser.Id,
            shareRecords[0].UserOrGroupId,
            'Expected to be the shared with Additional User.'
        );
    }

    @IsTest
    static void testHealthFormSharing(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'SampleUser@VertoEducation.org'];
        Id healthFormId = [SELECT Id FROM Health_Form__c WHERE Enrollment_Record__r.Student_Account__r.Name = 'Sample Student' LIMIT 1].Id;
        FlowRecordSharingUtils.ShareRecordProfile shareProfile = new FlowRecordSharingUtils.ShareRecordProfile();
        shareProfile.recordId = healthFormId;
        shareProfile.userOrGroupId = contextUser.Id;
        shareProfile.lookupField = 'ParentId';
        shareProfile.sObjectName = 'Health_Form__c';
        shareProfile.shareSObjectName = 'Health_Form__Share';
        shareProfile.accessLevel = 'Read';
        shareProfile.accessFieldName = 'AccessLevel';
        shareProfile.deleteExistingSharingRecords = false;
        Test.startTest();
        System.runAs(contextuser){
            FlowRecordSharingUtils.getShareRecords(new List<FlowRecordSharingUtils.ShareRecordProfile>{shareProfile});
            System.assertEquals(
                1,
                [SELECT Id FROM Health_Form__c WHERE Id = :healthFormId].size(),
                'Expected to see 1 health form shared with user.'
            );
        }
        Test.stopTest();
        List<Health_Form__Share> shareRecords = [SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel 
            FROM Health_Form__Share 
            WHERE UserOrGroupId = :contextUser.Id
            AND ParentId = :healthFormId
        ];
        System.assertEquals(
            1,
            shareRecords.size(),
            'Expected to find 1 Health_Form__Share record created.'
        );
        System.assertEquals(
            'Manual',
            shareRecords[0].RowCause,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            'Read',
            shareRecords[0].AccessLevel,
            'Expected RowCause to be Manual sharing.'
        );
    }

    @IsTest
    static void testHealthFormSharingAndUnsharing(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'SampleUser@VertoEducation.org' LIMIT 1];
        User additionalUser = [SELECT Id FROM User WHERE UserName = 'AdditionalUser@VertoEducation.org' LIMIT 1];
        Id healthFormId = [SELECT Id FROM Health_Form__c WHERE Enrollment_Record__r.Student_Account__r.Name = 'Sample Student' LIMIT 1].Id;
        FlowRecordSharingUtils.ShareRecordProfile shareProfile = new FlowRecordSharingUtils.ShareRecordProfile();
        shareProfile.recordId = healthFormId;
        shareProfile.userOrGroupId = additionalUser.Id;
        shareProfile.previousUserOrGroupId = contextUser.Id;
        shareProfile.lookupField = 'ParentId';
        shareProfile.sObjectName = 'Health_Form__c';
        shareProfile.shareSObjectName = 'Health_Form__Share';
        shareProfile.accessLevel = 'Read';
        shareProfile.accessFieldName = 'AccessLevel';
        shareProfile.deleteExistingSharingRecords = true;
        Health_Form__Share oldShare = new Health_Form__Share(
            ParentId = healthFormId,
            UserOrGroupId = contextUser.Id,
            AccessLevel = 'Read'
        );
        insert oldShare;
        Test.startTest();
        System.runAs(contextuser){
            FlowRecordSharingUtils.getShareRecords(new List<FlowRecordSharingUtils.ShareRecordProfile>{shareProfile});
            System.assertEquals(
                0,
                [SELECT Id FROM Health_Form__c WHERE Id = :healthFormId].size(),
                'Expected to see no health form shared with user.'
            );
        }
        Test.stopTest();
        List<Health_Form__Share> shareRecords = [SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel 
            FROM Health_Form__Share 
            WHERE UserOrGroupId = :additionalUser.Id
            AND ParentId = :healthFormId
        ];
        System.assertEquals(
            1,
            shareRecords.size(),
            'Expected to find 1 Health_Form__Share record created.'
        );
        System.assertEquals(
            'Manual',
            shareRecords[0].RowCause,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            'Read',
            shareRecords[0].AccessLevel,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            additionalUser.Id,
            shareRecords[0].UserOrGroupId,
            'Expected to be the shared with Additional User.'
        );
    }

    @IsTest
    static void testCheckpointSharing(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'SampleUser@VertoEducation.org'];
        Id checkpointId = [SELECT Id FROM Checkpoint__c WHERE Enrollment_Record__r.Student_Account__r.Name = 'Sample Student' LIMIT 1].Id;
        FlowRecordSharingUtils.ShareRecordProfile shareProfile = new FlowRecordSharingUtils.ShareRecordProfile();
        shareProfile.recordId = checkpointId;
        shareProfile.userOrGroupId = contextUser.Id;
        shareProfile.lookupField = 'ParentId';
        shareProfile.sObjectName = 'Checkpoint__c';
        shareProfile.shareSObjectName = 'Checkpoint__Share';
        shareProfile.accessLevel = 'Read';
        shareProfile.accessFieldName = 'AccessLevel';
        shareProfile.deleteExistingSharingRecords = false;
        Test.startTest();
        System.runAs(contextuser){
            FlowRecordSharingUtils.getShareRecords(new List<FlowRecordSharingUtils.ShareRecordProfile>{shareProfile});
            System.assertEquals(
                1,
                [SELECT Id FROM Checkpoint__c WHERE Id = :checkpointId].size(),
                'Expected to see 1 health form shared with user.'
            );
        }
        Test.stopTest();
        List<Checkpoint__Share> shareRecords = [SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel 
            FROM Checkpoint__Share 
            WHERE UserOrGroupId = :contextUser.Id
            AND ParentId = :checkpointId
        ];
        System.assertEquals(
            1,
            shareRecords.size(),
            'Expected to find 1 Health_Form__Share record created.'
        );
        System.assertEquals(
            'Manual',
            shareRecords[0].RowCause,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            'Read',
            shareRecords[0].AccessLevel,
            'Expected RowCause to be Manual sharing.'
        );
    }

    @IsTest
    static void testCheckpointSharingAndUnsharing(){
        User contextUser = [SELECT Id FROM User WHERE UserName = 'SampleUser@VertoEducation.org' LIMIT 1];
        User additionalUser = [SELECT Id FROM User WHERE UserName = 'AdditionalUser@VertoEducation.org' LIMIT 1];
        Id checkpointId = [SELECT Id FROM Checkpoint__c WHERE Enrollment_Record__r.Student_Account__r.Name = 'Sample Student' LIMIT 1].Id;
        FlowRecordSharingUtils.ShareRecordProfile shareProfile = new FlowRecordSharingUtils.ShareRecordProfile();
        shareProfile.recordId = checkpointId;
        shareProfile.userOrGroupId = additionalUser.Id;
        shareProfile.previousUserOrGroupId = contextUser.Id;
        shareProfile.lookupField = 'ParentId';
        shareProfile.sObjectName = 'Checkpoint__c';
        shareProfile.shareSObjectName = 'Checkpoint__Share';
        shareProfile.accessLevel = 'Read';
        shareProfile.accessFieldName = 'AccessLevel';
        shareProfile.deleteExistingSharingRecords = true;
        Checkpoint__Share oldShare = new Checkpoint__Share(
            ParentId = checkpointId,
            UserOrGroupId = contextUser.Id,
            AccessLevel = 'Read'
        );
        insert oldShare;
        Test.startTest();
        System.runAs(contextuser){
            FlowRecordSharingUtils.getShareRecords(new List<FlowRecordSharingUtils.ShareRecordProfile>{shareProfile});
            System.assertEquals(
                0,
                [SELECT Id FROM Checkpoint__c WHERE Id = :checkpointId].size(),
                'Expected to see no health form shared with user.'
            );
        }
        Test.stopTest();
        List<Checkpoint__Share> shareRecords = [SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel 
            FROM Checkpoint__Share 
            WHERE UserOrGroupId = :additionalUser.Id
            AND ParentId = :checkpointId
        ];
        System.assertEquals(
            1,
            shareRecords.size(),
            'Expected to find 1 Health_Form__Share record created.'
        );
        System.assertEquals(
            'Manual',
            shareRecords[0].RowCause,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            'Read',
            shareRecords[0].AccessLevel,
            'Expected RowCause to be Manual sharing.'
        );
        System.assertEquals(
            additionalUser.Id,
            shareRecords[0].UserOrGroupId,
            'Expected to be the shared with Additional User.'
        );
    }
    
    @isTest
    static void testNullPreviousUserOrGroupIdProperty() {
        Boolean caughtException = false;
        String exceptionType;
        String exceptionMessage;
        User contextUser = [SELECT Id FROM User WHERE UserName = 'SampleUser@VertoEducation.org' LIMIT 1];
        User additionalUser = [SELECT Id FROM User WHERE UserName = 'AdditionalUser@VertoEducation.org' LIMIT 1];
        Id checkpointId = [SELECT Id FROM Checkpoint__c WHERE Enrollment_Record__r.Student_Account__r.Name = 'Sample Student' LIMIT 1].Id;
        FlowRecordSharingUtils.ShareRecordProfile shareProfile = new FlowRecordSharingUtils.ShareRecordProfile();
        shareProfile.recordId = checkpointId;
        shareProfile.userOrGroupId = additionalUser.Id;
        shareProfile.previousUserOrGroupId = null;
        shareProfile.lookupField = 'ParentId';
        shareProfile.sObjectName = 'Checkpoint__c';
        shareProfile.shareSObjectName = 'Checkpoint__Share';
        shareProfile.accessLevel = 'Read';
        shareProfile.accessFieldName = 'AccessLevel';
        shareProfile.deleteExistingSharingRecords = true;
        Test.startTest();
        System.runAs(contextuser){
            try {
                FlowRecordSharingUtils.getShareRecords(new List<FlowRecordSharingUtils.ShareRecordProfile>{shareProfile});
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
            'Expected an IllegalArgumentException due to null previousUserOrGroupId'
        );
        System.assertEquals(
            'Non-null previousUserOrGroupId is required.', 
            exceptionMessage, 
            'Expected FlowRecordSharingUtils.queryExistingShareRecords to throw an IllegalArgumentException with \'Non-null previousUserOrGroupId is required.\' as the message.'
        );
    }

    @isTest
    static void testRecordIdProperty() {
        Boolean caughtException = false;
        String exceptionType;
        String exceptionMessage;
        User contextUser = [SELECT Id FROM User WHERE UserName = 'SampleUser@VertoEducation.org' LIMIT 1];
        FlowRecordSharingUtils.ShareRecordProfile shareProfile = new FlowRecordSharingUtils.ShareRecordProfile();
        shareProfile.recordId = null;
        shareProfile.userOrGroupId = contextUser.Id;
        shareProfile.lookupField = 'ParentId';
        shareProfile.sObjectName = 'Checkpoint__c';
        shareProfile.shareSObjectName = 'Checkpoint__Share';
        shareProfile.accessLevel = 'Read';
        shareProfile.accessFieldName = 'AccessLevel';
        Test.startTest();
        System.runAs(contextuser){
            try {
                FlowRecordSharingUtils.getShareRecords(new List<FlowRecordSharingUtils.ShareRecordProfile>{shareProfile});
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
            'Expected an IllegalArgumentException due to null recordId.'
        );
        System.assertEquals(
            'Non-null recordId is required.', 
            exceptionMessage, 
            'Expected FlowRecordSharingUtils.getShareRecords to throw an IllegalArgumentException with \'Non-null recordId is required.\' as the message.'
        );
    }
}