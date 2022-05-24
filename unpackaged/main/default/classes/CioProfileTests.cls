@IsTest
public with sharing class CioProfileTests {
    
    @IsTest
    static void testBuildFromInquiry() {
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
        String profileData = JSON.serializePretty(
            new CioProfile().build(sampleInquiry),
            true
        );
        Test.stopTest();
    }

    @IsTest
    static void testBuildFromLead() {
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
        String profileData = JSON.serializePretty(
            new CioProfile().build(sampleLead),
            true
        );
        Test.stopTest();
    }
}