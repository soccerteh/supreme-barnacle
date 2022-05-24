@IsTest
public with sharing class CioEventTests {
    
    @IsTest
    static void testBuildFromApplication() {
        insert new Campaign(
            Name = 'Leads Five9 List',
            RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByName().get('Five9').getRecordTypeId()
        );
        Application__c sampleApplication = new Application__c(
            Applicant_First_Name__c = 'Sample',
            Applicant_Last_Name__c = 'Applicant',
            Applicant_Email__c = 'SampleApplication@Test.org',
            Application_Status__c = 'In Review',
            Preferred_Name__c = 'Preferred Name',
            Applicant_Phone__c = '888-888-8888',
            Date_of_Birth__c = System.today().addYears(-18),
            Sex__c = 'Male',
            Race_Ethnicity__c = 'I prefer not to say',
            Hispanic_or_Latino_a_x__c = 'No',
            Citizen_Status__c = 'U.S. Citizen or U.S. National',
            First_Generation_College_Student__c = 'No',
            Post_Verto_Plans__c = 'I’m interested in learning more about Verto’s partner schools.',
            Street__c = '1111 Fake St',
            City__c = 'Faketown',
            State_Province__c = 'California',
            Postal_Code__c = '11111',
            GPA_Scale__c = '4.0',
            GPA__c = 4.0,
            Year_of_High_School_Graduation__c = String.valueOf(System.today().year()),
            High_School_Counselor_First_Name__c = 'Sample',
            High_School_Counselor_Last_Name__c = 'Counselor',
            High_School_Counselor_Email__c = 'SampleCounselor@Test.org',
            High_School_Counselor_Phone__c = '999-999-9999',
            Disciplinary_Violation__c = 'No',
            Criminal_Conviction__c = 'No',
            Parent_First_Name__c = 'Sample',
            Parent_Last_Name__c = 'Parent',
            Parent_Email__c = 'SampleParent@Test.org',
            Parent_Phone_Number__c = '777-777-7777',
            Parents_Guardians_Marital_Status__c = 'Separated',
            RecordTypeId = Schema.sObjectType.Application__c.getRecordTypeInfosByName().get('Traditional Enrollment').getRecordTypeId()
        );
        insert sampleApplication;
        Test.startTest();
        String eventData = JSON.serializePretty(
            new CioEvent().setName('Application_Submitted').build(sampleApplication),
            true
        );
        Test.stopTest();
        System.assertEquals(
            true,
            eventData.contains('"data"'),
            'Expected JSON object with data as a property.'
        );
    }

    @IsTest
    static void testBuildFromEnrollmentRecord() {
        insert new Location__c(
            Name = 'Example Location',
            Status__c = 'Actively Enrolling'
        );
        insert new Semester__c(
            Name = 'Sample Semester ' + String.valueOf(System.today().year()),
            Delivery_Method__c = 'Abroad',
            Semester_Start_Date__c = System.today().addDays(10),
            Semester_End_Date__c = System.today().addDays(10).addMonths(3),
            Deposit_Due_Date__c = System.today().addDays(10).addMonths(3),
            Tuition_Due_Date__c = System.today().addDays(-10).addMonths(3)
        );
        insert new Program__c(
            Name = 'Sample Program',
            Program_Start_Date__c = System.today().addDays(10),
            Program_End_Date__c = System.today().addDays(10).addMonths(3),
            Semester__c = [SELECT Id FROM Semester__c LIMIT 1].Id,
            Location__c = [SELECT Id FROM Location__c LIMIT 1].Id
        );
        Account sampleAccount = new Account(
            Name = 'Sample Student',
            First_Name__c = 'Sample',
            Last_Name__c = 'Student',
            Phone = '888-888-8888',
            Email__c = 'SampleStudent@Test.org',
            Persona__c = 'US High School Student',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId()
        );
        insert sampleAccount;
        Opportunity sampleOpp = new Opportunity(
            Name = 'Sample Oppportunity',
            AccountId = [SELECT Id FROM Account WHERE Name = 'Sample Student' LIMIT 1].Id,
            StageName = 'Qualified',
            CloseDate = System.today(),
            RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Traditional Enrollment').getRecordTypeId()
        );
        insert sampleOpp;
        Enrollment_Record__c sampleEnrollmentRecord = new Enrollment_Record__c(
            Student_Account__c = sampleAccount.Id,
            Opportunity__c = sampleOpp.Id,
            Owner__c = System.Label.User_GeneralSalesforceAdmin,
            Program__c = [SELECT Id FROM Program__c LIMIT 1].Id
        );
        insert sampleEnrollmentRecord;
        Test.startTest();
        String eventData = JSON.serializePretty(
            new CioEvent().setName('Enrollment_Update').build(sampleEnrollmentRecord),
            true
        );
        Test.stopTest();
        System.assertEquals(
            true,
            eventData.contains('"data"'),
            'Expected JSON object with data as a property.'
        );
    }

    @IsTest
    static void testBuildFromInquiry() {
        insert new Campaign(
            Name = 'Leads Five9 List',
            RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByName().get('Five9').getRecordTypeId()
        );
        Inquiry__c sampleInquiry = new Inquiry__c(
            Persona__c = 'Prospective Student',
            First_Name__c = 'Sample',
            Last_Name__c = 'Student',
            Email__c = 'SampleStudent@Test.org',
            Phone__c = '888-888-8888',
            Zip_Postal_Code__c = '11111',
            Country__c = 'United States',
            Stage__c = 'Open',
            Year_of_Graduation__c = String.valueOf(System.today().year())
        );
        insert sampleInquiry;
        Test.startTest();
        String eventData = JSON.serializePretty(
            new CioEvent().setName('Inquiry_Update').build(sampleInquiry),
            true
        );
        Test.stopTest();
        System.assertEquals(
            true,
            eventData.contains('"data"'),
            'Expected JSON object with data as a property.'
        );
    }

    @IsTest
    static void testBuildFromLead() {
        insert new Campaign(
            Name = 'Leads Five9 List',
            RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByName().get('Five9').getRecordTypeId()
        );
        Lead sampleLead = new Lead(
            FirstName = 'Sample',
            LastName = 'Lead',
            Company = 'Sample Company',
            Email = 'SampleLead@Test.org',
            Persona__c = 'US High School Student',
            Status = 'Open',
            Phone = '888-888-8888',
            RecordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get('Traditional Enrollment').getRecordTypeId()
        );
        insert sampleLead;
        Test.startTest();
        String eventData = JSON.serializePretty(
            new CioEvent().setName('Lead_Update').build(sampleLead),
            true
        );
        Test.stopTest();
        System.assertEquals(
            true,
            eventData.contains('"data"'),
            'Expected JSON object with data as a property.'
        );
    }

    @IsTest
    static void testBuildFromOpportunity() {
        Opportunity sampleOpp = new Opportunity(
            Name = 'Sample Oppportunity',
            StageName = 'Qualified',
            CloseDate = System.today(),
            RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Traditional Enrollment').getRecordTypeId()
        );
        insert sampleOpp;
        Test.startTest();
        String eventData = JSON.serializePretty(
            new CioEvent().setName('Opportunity_Submitted').build(sampleOpp),
            true
        );
        Test.stopTest();
        System.assertEquals(
            true,
            eventData.contains('"data"'),
            'Expected JSON object with data as a property.'
        );
    }
}