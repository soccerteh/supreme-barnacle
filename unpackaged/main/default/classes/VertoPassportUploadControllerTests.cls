@isTest
public with sharing class VertoPassportUploadControllerTests {

    @TestSetup
    static void makeData(){
        User studentSuccessUser = new User(
            FirstName = 'Student Success',
            LastName = 'User',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User - Verto' LIMIT 1].Id,
            UserName = 'StudentSuccess@VertoEducation.org',
            Email = 'StudentSuccess@VertoEducation.org',
            Alias = 'example',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert studentSuccessUser;
        User guestSiteUser = new User(
            FirstName = 'Public',
            LastName = 'Site',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Passport Upload Profile' LIMIT 1].Id,
            UserName = 'PublicSite@VertoEducation.org',
            Email = 'PublicSite@VertoEducation.org',
            Alias = 'example',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert guestSiteUser;
        Account sampleAccount = new Account(
            Name = 'Sample Account',
            First_Name__c = 'Sample',
            Last_Name__c = 'Account',
            RecordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId()
        );
        insert sampleAccount;
        Opportunity sampleOpportunity = new Opportunity(
            Name = 'Sample Opportunity',
            AccountId = sampleAccount.Id,
            CloseDate = System.today().addDays(30),
            StageName = 'Qualification'
        );
        insert sampleOpportunity;
        Program__c sampleProgram = new Program__c(
            Name = 'Sample Program',
            Status__c = 'Planning',
            Program_Start_Date__c = System.today(),
            Program_End_Date__c = System.today().addMonths(3)
        );
        insert sampleProgram;
        Enrollment_Record__c sampleEnrollmentRecord = new Enrollment_Record__c(
            Student_Account__c = sampleAccount.Id,
            Opportunity__c = sampleOpportunity.Id,
            Owner__c = studentSuccessUser.Id,
            Program__c = sampleProgram.Id
        );
        insert sampleEnrollmentRecord;
    }

    @IsTest
    static void testPageLoad() {
        Enrollment_Record__c sampleEnrollmentRecord = [SELECT Id, Student_Account__c, Program__c, Opportunity__c FROM Enrollment_Record__c LIMIT 1];
        Test.startTest();
        User siteUser = [SELECT Id FROM User WHERE UserName = 'PublicSite@VertoEducation.org' LIMIT 1];
        PermissionSetAssignment guestSiteUserPermissions = new PermissionSetAssignment(
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Create_Verto_Form_Submission' LIMIT 1].Id,
            AssigneeId = siteUser.Id
        );
        insert guestSiteUserPermissions;
        System.runAs(siteUser){
            PageReference pageInfo = Page.VertoPassportUpload;
            Test.setCurrentPage(pageInfo);
            pageInfo.getParameters().put('aid', sampleEnrollmentRecord.Student_Account__c);
            pageInfo.getParameters().put('program', sampleEnrollmentRecord.Program__c);
            ApexPages.StandardController controller = new ApexPages.StandardController(new Verto_Form_Submission__c());
            VertoPassportUploadController page = new VertoPassportUploadController(controller);
            page.getCountries();
            page.getYesOrNo();
            page.getNewOrRenewing();
            page.getPrograms();
            page.getPassportSex();
            System.assertEquals(
                false,
                page.showThankYou,
                'Expected false, as no ThankYou parameter was included in the page URL'
            );
            System.assertEquals(
                2,
                ApexPages.currentPage().getParameters().size(),
                'There should only be two parameters passed to the page, Account ID and Program ID.'
            );
            //TODO Once encryption is added for url, update this assertion.
            System.assertEquals(
                sampleEnrollmentRecord.Student_Account__c,
                ApexPages.currentPage().getParameters().get('aid'),
                'Enrollment Record Student_Account__r.Id matches the AID value.'
            );
        }
        Test.stopTest();
        
    }

    @isTest
    static void testCancelSubmission() {
        Enrollment_Record__c sampleEnrollmentRecord = [SELECT Id, Student_Account__c, Program__c, Opportunity__c FROM Enrollment_Record__c LIMIT 1];
        Test.startTest();
        User siteUser = [SELECT Id FROM User WHERE UserName = 'PublicSite@VertoEducation.org' LIMIT 1];
        PermissionSetAssignment guestSiteUserPermissions = new PermissionSetAssignment(
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Create_Verto_Form_Submission' LIMIT 1].Id,
            AssigneeId = siteUser.Id
        );
        insert guestSiteUserPermissions;
        System.runAs(siteUser){
            PageReference pageInfo = Page.VertoPassportUpload;
            Test.setCurrentPage(pageInfo);
            pageInfo.getParameters().put('aid', sampleEnrollmentRecord.Student_Account__c);
            pageInfo.getParameters().put('program', sampleEnrollmentRecord.Program__c);
            ApexPages.StandardController controller = new ApexPages.StandardController(new Verto_Form_Submission__c());
            VertoPassportUploadController page = new VertoPassportUploadController(controller);
            PageReference redirectedPage = page.cancelSubmission();
            System.assertEquals(
                0,
                redirectedPage.getParameters().size(),
                'Expected no parameters to be present in the redirected page.'
            );
            System.assertEquals(
                false,
                redirectedPage.getUrl().contains('ThankYou'),
                'Thank you page should not be displaying after method call. Thank you page is controlled by showThankYou variable value.'
            );

            System.assertEquals(
                false,
                page.showError,
                'Expected false, as no ThankYou parameter is to be included in PageReference from this method.'
            );
            System.assertEquals(
                false,
                page.showThankYou,
                'Expected false, as no ThankYou parameter is to be included in PageReference from this method.'
            );
        }
        System.assertEquals(
            0,
            [SELECT Id FROM Unhandled_Exception__c].size(),
            'No Unhandled Exception records should have been created, meaning the flow executed successfully.'
        );
        Test.stopTest();
    }

    @isTest
    static void testSubmitInformation() {
        Enrollment_Record__c sampleEnrollmentRecord = [SELECT Id, Student_Account__c, Program__c, Opportunity__c FROM Enrollment_Record__c LIMIT 1];
        Test.startTest();
        User siteUser = [SELECT Id FROM User WHERE UserName = 'PublicSite@VertoEducation.org' LIMIT 1];
        PermissionSetAssignment guestSiteUserPermissions = new PermissionSetAssignment(
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Create_Verto_Form_Submission' LIMIT 1].Id,
            AssigneeId = siteUser.Id
        );
        insert guestSiteUserPermissions;
        System.runAs(siteUser){
            PageReference pageInfo = Page.VertoPassportUpload;
            Test.setCurrentPage(pageInfo);
            pageInfo.getParameters().put('aid', sampleEnrollmentRecord.Student_Account__c);
            pageInfo.getParameters().put('program', sampleEnrollmentRecord.Program__c);
            ApexPages.StandardController controller = new ApexPages.StandardController(new Verto_Form_Submission__c());
            VertoPassportUploadController page = new VertoPassportUploadController(controller);
            page.program = 'Costa Rica';
            page.validPassport = 'Yes';
            page.record = new Verto_Form_Submission__c(
                Legal_Full_Name__c = 'Jane Doe',
                Passport_Number__c = String.valueOf(Math.random() * 100000000).left(10),
                Legal_Document_Issuing_Country__c = 'United States',
                Legal_Document_Sex__c = 'Female',
                Legal_Document_Issue_Date__c = System.today().addYears(-1),
                Legal_Document_Expiration_Date__c = System.today().addYears(9)
            );
            PageReference redirectedPage = page.submitInformation();
            /* System.assertEquals(
                True,
                redirectedPage.getUrl().contains('ThankYou'),
                'Expected URL to contain \'Thank You\' parameter.'
            );
            System.assertEquals(
                'Passport',
                redirectedPage.getParameters().get('ref'),
                'Expected Thank You message displayed should be for the Passport submitted event.'
            ); */
        }
        Test.stopTest();
        System.assertEquals(
            0,
            [SELECT Id FROM Unhandled_Exception__c].size(),
            'No Unhandled Exception records should have been created, meaning the records and files were inserted successfully.'
        );
        System.assertEquals(
            sampleEnrollmentRecord.Id,
            [SELECT Enrollment_Record__c FROM Verto_Form_Submission__c LIMIT 1].Enrollment_Record__c,
            'Expected to Verto_Form_Submission__c.Enrollment_Record__c to match the ID of sample Enrollment_Record__c record'
        );

    }

    @IsTest
    static void testNotifyRecordOwner(){
        Enrollment_Record__c sampleEnrollmentRecord = [SELECT Id, Student_Account__c, Program__c, Opportunity__c FROM Enrollment_Record__c LIMIT 1];
        Test.startTest();
        User siteUser = [SELECT Id FROM User WHERE UserName = 'PublicSite@VertoEducation.org' LIMIT 1];
        PermissionSetAssignment guestSiteUserPermissions = new PermissionSetAssignment(
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Create_Verto_Form_Submission' LIMIT 1].Id,
            AssigneeId = siteUser.Id
        );
        insert guestSiteUserPermissions;
        System.runAs(siteUser){
            PageReference pageInfo = Page.VertoPassportUpload;
            Test.setCurrentPage(pageInfo);
            pageInfo.getParameters().put('aid', sampleEnrollmentRecord.Student_Account__c);
            pageInfo.getParameters().put('program', sampleEnrollmentRecord.Program__c);
            ApexPages.StandardController controller = new ApexPages.StandardController(new Verto_Form_Submission__c());
            VertoPassportUploadController page = new VertoPassportUploadController(controller);
            PageReference redirectedPage = page.notifyRecordOwner();
            System.assertEquals(
                True,
                redirectedPage.getUrl().contains('ThankYou'),
                'Thank you page should be displaying after method call. Thank you page is controlled by showThankYou variable value.'
            );
            System.assertEquals(
                'Notify',
                redirectedPage.getParameters().get('ref'),
                'The Thank You message displayed should be for the Notify SOA event.'
            ); 
        }
        System.assertEquals(
            0,
            [SELECT Id FROM Unhandled_Exception__c].size(),
            'No Unhandled Exception records should have been created, meaning the flow executed successfully.'
        );
        Test.stopTest();
    }

    @IsTest
    static void testUnhandleExceptionLogging() {
        Enrollment_Record__c sampleEnrollmentRecord = [SELECT Id, Student_Account__c, Program__c, Opportunity__c FROM Enrollment_Record__c LIMIT 1];
        Test.startTest();
        User siteUser = [SELECT Id FROM User WHERE UserName = 'PublicSite@VertoEducation.org' LIMIT 1];
        PermissionSetAssignment guestSiteUserPermissions = new PermissionSetAssignment(
            PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Create_Verto_Form_Submission' LIMIT 1].Id,
            AssigneeId = siteUser.Id
        );
        insert guestSiteUserPermissions;
        System.runAs(siteUser){
            PageReference pageInfo = Page.VertoPassportUpload;
            Test.setCurrentPage(pageInfo);
            pageInfo.getParameters().put('aid', 'Invalid Record Id');
            pageInfo.getParameters().put('program', sampleEnrollmentRecord.Program__c);
            ApexPages.StandardController controller = new ApexPages.StandardController(new Verto_Form_Submission__c());
            VertoPassportUploadController page = new VertoPassportUploadController(controller);
            page.notifyRecordOwner();
            page.program = 'Costa Rica';
            page.record = new Verto_Form_Submission__c(
                Legal_Full_Name__c = 'Jane Doe',
                Passport_Number__c = String.valueOf(Math.random() * 100000000),
                Legal_Document_Issuing_Country__c = 'United States',
                Legal_Document_Sex__c = 'Female',
                Legal_Document_Issue_Date__c = System.today().addYears(-1),
                Legal_Document_Expiration_Date__c = System.today().addYears(9)
            );
            page.submitInformation();
        }
        Test.stopTest();
        System.assertEquals(
            2,
            [SELECT Id FROM Unhandled_Exception__c].size(),
            'Three expected Unhandled Exceptions inserted.'
        );
    }
}