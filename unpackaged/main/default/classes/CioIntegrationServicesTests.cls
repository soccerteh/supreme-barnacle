@IsTest
public with sharing class CioIntegrationServicesTests {

    @TestSetup
    static void makeData(){
        insert new Account(
            Name = 'Sample Student',
            First_Name__c = 'Sample',
            Last_Name__c = 'Student',
            Phone = '888-888-8888',
            Email__c = 'SampleStudent@Test.org',
            Persona__c = 'US High School Student',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId()
        );
        insert new Opportunity(
            Name = 'Sample Oppportunity',
            AccountId = [SELECT Id FROM Account WHERE Name = 'Sample Student' LIMIT 1].Id,
            StageName = 'Qualified',
            CloseDate = System.today(),
            RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Traditional Enrollment').getRecordTypeId()
        );
    }
    
    @IsTest
    static void testSyncRecords() {
        Boolean exceptionThrown = false;
        String exceptionMessage;
        Test.startTest();
        Opportunity oldOpp = [
            SELECT Id, StageName, Current_Program__c, Family_Interview_Booked_Date__c,
            Deposit_Date__c, Enrollment_Agreement_Signed_Date_Time__c, OwnerId
            FROM Opportunity 
            LIMIT 1
        ];
        Opportunity newOpp = oldOpp.clone(true, true, true);
        newOpp.StageName = 'Family Admissions Calls';
        try {
            CioIntegrationServices.syncRecords(
                getSampleIntegrationSetting(),
                new Map<Id, SObject>(new List<Opportunity>{oldOpp}),
                new Map<Id, SObject>(new List<Opportunity>{newOpp})
            );
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assertEquals(
            null,
            exceptionMessage,
            'Expected no exception message.'
        );
        System.assertEquals(
            false,
            exceptionThrown,
            'Expected no exceptions to be thrown.'
        );
    }


    @IsTest
    static void testGetIntegrationSyncRequired() {
        Test.startTest();
        Boolean integrationSyncRequired;
        Opportunity oldOpp = [
            SELECT Id, StageName, Current_Program__c, Family_Interview_Booked_Date__c,
            Deposit_Date__c, Enrollment_Agreement_Signed_Date_Time__c 
            FROM Opportunity 
            LIMIT 1
        ];
        Opportunity newOpp = oldOpp.clone(true, true, true);
        newOpp.StageName = 'Family Admissions Calls';
        integrationSyncRequired = CioIntegrationServices.getIntegrationSyncRequired(
            (SObject)oldOpp,
            (SObject)newOpp,
            'Current_Program__c,StageName'
        );
        System.assertEquals(
            true,
            integrationSyncRequired,
            'Expected integration sync required to be true.'
        );
    }

    @IsTest
    static void testGetFieldsToWatch() {
        
    }

    @IsTest
    static void testGetQueryResults() {

    }

    @IsTest
    static void testGetPayload() {

    }

    @IsTest
    static void testGetEmail() {

    }

    private static CIO_Integration_Setting__mdt getSampleIntegrationSetting() {
        return CIO_Integration_Setting__mdt.getInstance('Opportunity_Update');
    }

    private class HttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setHeader('Content-Type', 'application/json');
            response.setBody('Hello World.');
            return response;
        }
    }
}