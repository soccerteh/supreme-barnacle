@IsTest
public with sharing class LeadTriggerHandlerTests {

    @TestSetup
    static void makeData(){
        insert new Campaign(
            Name = 'Leads Five9 List',
            RecordTypeId = Schema.sObjectType.Campaign.getRecordTypeInfosByName().get('Five9').getRecordTypeId()
        );
    }

    @IsTest
    static void testAfterInsert() {
        
        Test.startTest();
        insert getSampleLead();
        Test.stopTest();
        System.assertEquals(
            1,
            [SELECT Id FROM Lead].size(),
            'Expected one successful lead inserted.'
        );
    }

    @IsTest
    static void testBulkAfterInsert() {
        Test.startTest();
        List<Lead> leadsToInsert = new List<Lead>();
        for(Integer i = 0; i < 50; i++) {
            leadsToInsert.add(getSampleLead());
        }
        insert leadsToInsert;
        Test.stopTest();
        System.assertEquals(
            50,
            [SELECT Id FROM Lead].size(),
            'Expected 200 successful leads inserted.'
        );
    }

    @IsTest
    static void testBeforeUpdate() {
        Test.startTest();
        Lead sampleLead = getSampleLead();
        insert sampleLead;
        sampleLead.Most_Recent_Call_Date__c = System.today();
        update sampleLead;
        Test.stopTest();
        sampleLead = [SELECT Id, CreatedDate, LastModifiedDate FROM Lead WHERE ID = :sampleLead.Id];
        System.assertEquals(
            0,
            [SELECT Id FROM Lead WHERE Most_Recent_Call_Date__c = null].size(),
            'Expected all leads to have a Most Recent Call Date.'
        );
    }

    @IsTest
    static void testBulkBeforeUpdate() {
        List<Lead> leadsToInsert = new List<Lead>();
        for(Integer i = 0; i < 50; i++) {
            leadsToInsert.add(getSampleLead());
        }
        insert leadsToInsert;
        Test.startTest();
        List<Lead> leadsToUpdate = [SELECT Id, Most_Recent_Call_Date__c FROM Lead LIMIT 200];
        for(Lead each :leadsToUpdate) {
            each.Most_Recent_Call_Date__c = System.today();
        }
        update leadsToUpdate;
        Test.stopTest();
        System.assertEquals(
            0,
            [SELECT Id FROM Lead WHERE Most_Recent_Call_Date__c = null].size(),
            'Expected all leads to have a Most Recent Call Date.'
        );
    }

    private static Lead getSampleLead() {
        return new Lead(
            FirstName = 'Sample',
            LastName = 'Lead',
            Company = 'Sample Company',
            Email = 'SampleLead@Test.org',
            Persona__c = 'US High School Student',
            Status = 'Open',
            Phone = '888-888-8888',
            RecordTypeId = Schema.sObjectType.Lead.getRecordTypeInfosByName().get('Traditional Enrollment').getRecordTypeId()
        );
    }
}