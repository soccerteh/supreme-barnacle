@IsTest
public with sharing class InquiryTriggerHandlerTests {
    
    @IsTest
    static void testAfterInsert() {
        
        Test.startTest();
        insert new Campaign(
            Name = 'Leads Five9 List',
            RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByName().get('Five9').getRecordTypeId()
        );
        insert getSampleStudentInquiry();
        insert getSampleParentInquiry();
        Test.stopTest();
        System.assertEquals(
            1,
            [SELECT Id FROM Inquiry__c WHERE Persona__c = 'Prospective Student'].size(),
            'Expected one successful inquiry inserted.'
        );
        System.assertEquals(
            1,
            [SELECT Id FROM Inquiry__c WHERE Persona__c = 'Prospective Parent'].size(),
            'Expected one successful inquiry inserted.'
        );
    }

    @IsTest
    static void testBulkAfterInsert() {
        insert new Campaign(
            Name = 'Leads Five9 List',
            RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByName().get('Five9').getRecordTypeId()
        );
        List<Inquiry__c> inquiriesToInsert = new List<Inquiry__c>();
        for (Integer i = 0; i < 50; i++) {
            Inquiry__c sampleInquiry = getSampleStudentInquiry();
            sampleInquiry.Email__c += String.valueOf(i);
            inquiriesToInsert.add(sampleInquiry);
        }
        TriggerHandler.suppressHandler('LeadTriggerHandler');
        Test.startTest();
        insert inquiriesToInsert;
        TriggerHandler.clearSuppressedHandlers();
        System.assertEquals(
            50,
            [SELECT Id FROM Inquiry__c WHERE Persona__c = 'Prospective Student'].size(),
            'Expected 200 successful inquiries inserted.'
        );
    }

    private static Inquiry__c getSampleStudentInquiry() {
        return new Inquiry__c(
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
    }
    private static Inquiry__c getSampleParentInquiry() {
        return new Inquiry__c(
            Persona__c = 'Prospective Parent',
            Parent_First_Name__c = 'Sample',
            Parent_Last_Name__c = 'Parent',
            Parent_Email__c = 'SampleParent@Test.org',
            Parent_Phone_Number__c = '888-888-8888',
            First_Name__c = 'Sample',
            Last_Name__c = 'Student',
            Year_of_Graduation__c = String.valueOf(System.today().year()),
            RecordTypeId = Schema.sObjectType.Inquiry__c.getRecordTypeInfosByName().get('Parent').getRecordTypeId()
        );
    }
}