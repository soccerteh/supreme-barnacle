@IsTest
public with sharing class ApplicationTriggerHandlerTests {

    @TestSetup
    static void makeData(){
        //There's a flow relying on an instance of a campaign record, creating the campaign record to prevent the flow from failing temporarily.
        insert new Campaign(
            Name = 'Leads Five9 List',
            RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByName().get('Five9').getRecordTypeId()
        );    
    }

    @IsTest
    static void testAfterInsert() {
        Test.startTest();
        insert getSampleApplication();
        Test.stopTest();
        System.assertEquals(
            1,
            [SELECT Id FROM Application__c].size(),
            'Expected one successful application inserted.'
        );
    }

    @IsTest
    static void testBulkAfterInsert() {
        List<Application__c> applicationsToInsert = new List<Application__c>();
        Test.startTest();
        for (Integer i = 0; i < 50; i++) {
            applicationsToInsert.add(getSampleApplication());
        }
        insert applicationsToInsert;
        System.assertEquals(
            50,
            [SELECT Id FROM Application__c].size(),
            'Expected 200 successful applications inserted.'
        );
    }

    private static Application__c getSampleApplication() {
        return new Application__c(
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
    }
}