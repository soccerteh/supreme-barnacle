@IsTest
public with sharing class OpportunityTriggerHandlerTests {

    @TestSetup
    static void makeData(){
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
        User limitsUser = new User(
            FirstName = 'Limit',
            LastName = 'User',
            Alias = 'LUser',
            Email = 'LimitUser@Test.org',
            UserName = 'LimitUser@Test.org',
            EmailEncodingKey = 'UTF-8',
            isActive = true,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert limitsUser;
        System.runAs(limitsUser) {
            insert new PermissionSetAssignment(
                AssigneeId = limitsUser.Id,
                PermissionSetGroupId = [SELECT Id FROM PermissionSetGroup WHERE MasterLabel = 'Digital Product Team' LIMIT 1].Id
            );
        }
    }
    
    @IsTest
    static void testAfterInsert() {
        
        Test.startTest();
        insert getSampleOpportunity();
        Test.stopTest();
        System.assertEquals(
            1,
            [SELECT Id FROM Opportunity].size(),
            'Expected one successful opportunity inserted.'
        );
    }

    @IsTest
    static void testBulkAfterInsert() {
        Test.startTest();
        List<Opportunity> oppsToInsert = new List<Opportunity>();
        for(Integer i = 0; i < 100; i++) {
            oppsToInsert.add(getSampleOpportunity());
        }
        insert oppsToInsert;
        Test.stopTest();
        System.assertEquals(
            100,
            [SELECT Id FROM Opportunity].size(),
            'Expected 200 successful opportunities inserted.'
        );
    }

    @IsTest
    static void testBeforeUpdate() {
        Opportunity sampleOpp = getSampleOpportunity();
        insert sampleOpp;
        Test.startTest();
        sampleOpp.Current_Program__c = [SELECT Id FROM Program__c LIMIT 1].Id;
        update sampleOpp;
        Test.stopTest();
        System.assertEquals(
            0,
            [SELECT Id FROM Opportunity WHERE Current_Program__c = null].size(),
            'Expected all opportunities to have been updated with a Current Program value.'
        );
    }

    @IsTest
    static void testBulkBeforeUpdate() {
        User contextUser = [SELECT Id FROM User WHERE Username = 'LimitUser@Test.Org' LIMIT 1];
        System.runAs(contextUser) {
            List<Opportunity> oppsToInsert = new List<Opportunity>();
            //currently limiting to 100 records to update, due to CPU limit being hit from process builder.
            for(Integer i = 0; i < 100; i++) {
                oppsToInsert.add(getSampleOpportunity());
            }
            insert oppsToInsert;
        }
        Test.startTest();
        List<Opportunity> oppsToUpdate = [SELECT Id, Current_Program__c FROM Opportunity LIMIT 100];
        Id programId = [SELECT Id FROM Program__c LIMIT 1].Id;
        for(Opportunity each :oppsToUpdate) {
            each.Current_Program__c = programId;
        }
        update oppsToUpdate;
        Test.stopTest();
        System.assertEquals(
            0,
            [SELECT Id FROM Opportunity WHERE Current_Program__c = null].size(),
            'Expected all opportunities to have been updated with a Current Program value.'
        );
    }

    private static Opportunity getSampleOpportunity() {
        return new Opportunity(
            Name = 'Sample Oppportunity',
            StageName = 'Qualified',
            CloseDate = System.today(),
            RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Traditional Enrollment').getRecordTypeId()
        );
    }
}