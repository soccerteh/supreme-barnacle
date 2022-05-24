@IsTest
public with sharing class EnrollmentRecordTriggerHandlerTests {
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
        insert new Account(
            Name = 'Sample Student',
            First_Name__c = 'Sample',
            Last_Name__c = 'Student',
            Phone = '888-888-8888',
            Email__c = 'SampleStudent@Test.org',
            Persona__c = 'US High School Student',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId()
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
        User contextUser = [SELECT Id FROM User WHERE UserName = 'LimitUser@Test.org' LIMIT 1];
        System.runAs(contextUser) {
            insertSampleOpportunities(1);
        }
        Test.startTest();
        Enrollment_Record__c sampleEnrollment = getSampleFirstSemester();
        insert sampleEnrollment;
        Test.stopTest();
        System.assertEquals(
            1,
            [SELECT Id FROM Enrollment_Record__c].size(),
            'Expected one successful enrollment record inserted.'
        );
    }
 
    @IsTest
    static void testBulkAfterInsert() {
        User contextUser = [SELECT Id FROM User WHERE UserName = 'LimitUser@Test.org' LIMIT 1];
        List<Enrollment_Record__c> enrollmentRecordsToInsert = new List<Enrollment_Record__c>();
        System.runAs(contextUser) {
            Id studentId = [SELECT Id FROM Account WHERE Name = 'Sample Student' LIMIT 1].Id;
            Id programId = [SELECT Id FROM Program__c LIMIT 1].Id;
            List<Opportunity> parentOpportunities = insertSampleOpportunities(50);
            for (Integer i = 0; i < 50; i++) {
                enrollmentRecordsToInsert.add(getSampleFirstSemester(
                    studentId,
                    parentOpportunities[i].Id,
                    programId
                ));
            }
        }
        Test.startTest();
        insert enrollmentRecordsToInsert;
        Test.stopTest();
        System.assertEquals(
            50,
            [SELECT Id FROM Enrollment_Record__c].size(),
            'Expected 50 successful enrollment records inserted.'
        );
    }

    @IsTest
    static void testBeforeUpdate() {
        insertSampleOpportunities(1);
        Enrollment_Record__c sampleEnrollment = getSampleFirstSemester();
        insert sampleEnrollment;
        Test.startTest();
        sampleEnrollment.Enrollment_Status__c = 'Enrolled';
        update sampleEnrollment;
        Test.stopTest();
        System.assertEquals(
            1,
            [SELECT Id FROM Enrollment_Record__c WHERE Enrollment_Status__c = 'Enrolled'].size(),
            'Expected one successful enrollment record updated.'
        );
    }

    @IsTest
    static void testBulkBeforeUpdate() {
        User contextUser = [SELECT Id FROM User WHERE UserName = 'LimitUser@Test.org' LIMIT 1];
        List<Enrollment_Record__c> enrollmentRecordsToInsert = new List<Enrollment_Record__c>();
        System.runAs(contextUser) {
            Id studentId = [SELECT Id FROM Account WHERE Name = 'Sample Student' LIMIT 1].Id;
            Id programId = [SELECT Id FROM Program__c LIMIT 1].Id;
            List<Opportunity> parentOpportunities = insertSampleOpportunities(50);
            for (Integer i = 0; i < 50; i++) {
                enrollmentRecordsToInsert.add(getSampleFirstSemester(
                    studentId,
                    parentOpportunities[i].Id,
                    programId
                ));
            }
            insert enrollmentRecordsToInsert;
        }
        Test.startTest();
        List<Enrollment_Record__c> enrollmentRecordsToUpdate = [SELECT Id, Enrollment_Status__c FROM ENrollment_Record__c LIMIT 200];
        for (Enrollment_Record__c each : enrollmentRecordsToUpdate) {
            each.Enrollment_Status__c = 'Enrolled';
        }
        update enrollmentRecordsToUpdate;
        Test.stopTest();
        System.assertEquals(
            50,
            [SELECT Id FROM Enrollment_Record__c WHERE Enrollment_Status__c = 'Enrolled'].size(),
            'Expected 50 successful enrollment records updated.'
        );
    }

    private static List<Opportunity> insertSampleOpportunities(Integer count) {
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        Id accountId = [SELECT Id FROM Account WHERE Name = 'Sample Student' LIMIT 1].Id;
        for (Integer i = 0; i < count; i++) {
            opportunitiesToInsert.add(new Opportunity(
                Name = 'Sample Oppportunity',
                AccountId = accountId,
                StageName = 'Qualified',
                CloseDate = System.today(),
                RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Traditional Enrollment').getRecordTypeId()
            ));
        }
        TriggerHandler.suppressHandler('OpportunityTriggerHandler');
        insert opportunitiesToInsert;
        TriggerHandler.clearSuppressedHandlers();
        return opportunitiesToInsert;
    }

    private static Enrollment_Record__c getSampleFirstSemester() {
        return new Enrollment_Record__c(
            Student_Account__c = [SELECT Id FROM Account WHERE Name = 'Sample Student' LIMIT 1].Id,
            Opportunity__c = [SELECT Id FROM Opportunity LIMIT 1].Id,
            Program__c = [SELECT Id FROM Program__c LIMIT 1].Id,
            Owner__c = System.Label.User_GeneralSalesforceAdmin,
            RecordTypeId = Schema.sObjectType.Enrollment_Record__c.getRecordTypeInfosByName().get('First Semester').getRecordTypeId()
        );
    }

    private static Enrollment_Record__c getSampleFirstSemester(
        Id studentId,
        Id opportunityId,
        Id programId
    ) {
        return new Enrollment_Record__c(
            Student_Account__c = studentId,
            Opportunity__c = opportunityId,
            Program__c = programId,
            Owner__c = System.Label.User_GeneralSalesforceAdmin,
            RecordTypeId = Schema.sObjectType.Enrollment_Record__c.getRecordTypeInfosByName().get('First Semester').getRecordTypeId()
        );
    }
}