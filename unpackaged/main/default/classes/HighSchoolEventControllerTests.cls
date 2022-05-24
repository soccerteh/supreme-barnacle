@isTest
public with sharing class HighSchoolEventControllerTests {
    
    @TestSetup
    static void makeData(){
        Account highSchool = new Account(
            Name = 'Example High School',
            RecordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('High School Account').getRecordTypeId()
        );
        insert highSchool;
        User counselor = new User(
            FirstName = 'Example',
            LastName = 'Counselor',
            TimeZoneSidKey = 'GMT',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User - Verto' LIMIT 1].Id,
            UserName = 'ExampleCounselor@VertoEducation.org',
            Email = 'ExampleCounselor@VertoEducation.org',
            Alias = 'ecoun',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert counselor;
        Event__c event = new Event__c(
            Counselor__c = counselor.Id,
            High_School__c = highSchool.Id,
            Event_Status__c = 'Scheduled',
            Event_Start__c = System.now().addHours(3)
        );
        insert event;
    }

    @isTest
    static void testPageLoad() {
        Test.startTest(); 
            PageReference pageInfo = Page.HighSchoolEvent;
        Test.setCurrentPage(pageInfo);
            Id cId = [SELECT Id FROM User WHERE Name = 'Example Counselor' LIMIT 1].Id;
            Id eId = [SELECT Id FROM Event__c LIMIT 1].Id;
            pageInfo.getParameters().put('cid', cId);
            pageInfo.getParameters().put('eid', eId);
            ApexPages.StandardController controller = new ApexPages.StandardController(new Inquiry__c());
            HighSchoolEventController page = new HighSchoolEventController(controller);
            page.getCountries();
            page.getYears();
        Test.stopTest();
        System.assertEquals(
            2,
            ApexPages.currentPage().getParameters().size(), 
            'Expected a map containing two parameters'
        );
        System.assertEquals(
            eId, 
            page.eventId, 
            'Expected the Event Id to be set via parameters'
        );
        System.assertEquals(
            cId, 
            page.counselorId, 
            'Expected the Counselor Id to be set via parameters'
        );
    }
    @isTest
    static void testSubmitInformation() {
        String email = 'Jane.Doe@VertoEducation.org';
        Test.startTest(); 
            PageReference pageInfo = Page.HighSchoolEvent;
        Test.setCurrentPage(pageInfo);
            pageInfo.getParameters().put('cid', [SELECT Id FROM User WHERE Name = 'Example Counselor' LIMIT 1].Id);
            pageInfo.getParameters().put('eid', [SELECT Id FROM Event__c LIMIT 1].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(new Inquiry__c());
            HighSchoolEventController page = new HighSchoolEventController(controller);
            Id eventId = page.eventId;
            page.studentInquiry.First_Name__c = 'Jane';
            page.studentInquiry.Last_Name__c = 'Doe';
            page.studentInquiry.Email__c = email;
            page.studentInquiry.Phone__c = '971-257-8918';
            page.studentInquiry.Country__c = 'United States';
            page.studentInquiry.Zip_Postal_Code__c = '99999';
            page.submitInformation();
        Test.stopTest();

        System.assertEquals(
            1, 
            new List<Inquiry__c>([SELECT Id FROM Inquiry__c WHERE Event__c = :eventId]).size(), 
            'Expected to find 1 Inquiry related to the test Event'
        );
        System.assertEquals(
            email.toLowerCase(), 
            [SELECT Email__c FROM Inquiry__c LIMIT 1].Email__c, 
            'Expected to find the Email__c for the inquiry to match the Test input.'
        );
    }

    @isTest
    static void testInvalidSubmitInformation() {
        Test.startTest(); 
            PageReference pageInfo = Page.HighSchoolEvent;
        Test.setCurrentPage(pageInfo);
            pageInfo.getParameters().put('eid', [SELECT Id FROM User WHERE Name = 'Example Counselor' LIMIT 1].Id);
            pageInfo.getParameters().put('cid', [SELECT Id FROM Event__c LIMIT 1].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(new Inquiry__c());
            HighSchoolEventController page = new HighSchoolEventController(controller);
            page.studentInquiry.First_Name__c = 'Jane';
            page.studentInquiry.Last_Name__c = 'Doe';
            page.submitInformation();
        Test.stopTest();
        System.assertEquals(
            0, 
            new List<Inquiry__c>([SELECT Id FROM Inquiry__c]).size(), 
            'Expected to find 0 Inquiry__c due to a thrown DML exception.'
        );
    }

    @isTest
    static void testCancelSubmission() {
        Test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(new Inquiry__c());
            HighSchoolEventController page = new HighSchoolEventController(controller);
            page.consent = true;
            page.cancelSubmission();
        Test.stopTest();
        Inquiry__c basicInquiry = new Inquiry__c(RecordTypeId = Schema.sObjectType.Inquiry__c.getRecordTypeInfosByName().get('Request for Information').getRecordTypeId());
        System.assertEquals(
            basicInquiry, 
            page.studentInquiry, 
            'Expected the Inquiry__c record to be null/reset to its default value.'
        );
        System.assertEquals(
            false, 
            page.consent, 
            'Expected the consent attribute to be null/reset to its default value.'
        );
    }

}