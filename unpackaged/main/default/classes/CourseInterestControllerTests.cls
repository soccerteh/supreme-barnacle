@IsTest
public with sharing class CourseInterestControllerTests {

    @TestSetup
    static void makeData(){
        TriggerHandler.suppressHandler('AccountTriggerHandler');
        TriggerHandler.suppressHandler('OpportunityTriggerHandler');
        TriggerHandler.suppressHandler('EnrollmentRecordTriggerHandler');
        TestDataFactory.insertMockCommunityUser();
        TestDataFactory.insertMockPrograms();
        TestDataFactory.insertMockCoursesWithPrerequisites();
        TestDataFactory.insertOpportunityAndEnrollmentForAccount([SELECT Id, Name FROM Account WHERE Name = 'Community User' LIMIT 1]);
        Account sampleAcademicProvider = new Account(
            Name = 'Sample Academic Provider',
            First_Name__c = 'Sample',
            Last_Name__c = 'Academic Provider',
            School_of_Record__c = true,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId()
        );
        insert sampleAcademicProvider;
        update new Enrollment_Record__c (
            Id = [SELECT Id FROM Enrollment_Record__c LIMIT 1].Id,
            School_of_Record__c = sampleAcademicProvider.Id,
            Program__c = [SELECT Id FROM Program__c WHERE Semester__r.Name LIKE '%Fall 2022' LIMIT 1].Id
        );
        TriggerHandler.clearSuppressedHandlers();
    }

    @IsTest
    static void testGetEligibleCoursesWithoutAcademicProviderMappings() {
        Boolean caughtException = false;
        List<CourseEligibility> eligibilityForOfferedCourses;
        User contextUser = [SELECT Id, Contact.AccountId FROM User WHERE Username = 'CommunityUser@Test.org' LIMIT 1];
        Id programId = [SELECT Program__c FROM Enrollment_Record__c LIMIT 1].Program__c;
        List<SObject> programOfferings = new List<SObject>();
        Transcript_Evaluation__c evaluation = getMockTranscriptEvaluation();
        evaluation.Student__c = contextUser.Contact.AccountId;
        insert evaluation;
        for (Course__c course :[SELECT Id FROM Course__c]) {
            programOfferings.add(new Course_Offering__c(
                Program__c = programId,
                Course__c = course.Id
            ));
        }
        if (!programOfferings.isEmpty()) {
            insert programOfferings;
        }
        Test.startTest();
        try {
            System.runAs(contextuser){
                eligibilityForOfferedCourses = CourseInterestController.getEligibleCourses();
            }
        } catch (AuraHandledException ex) {
            caughtException = true;
        }
        Test.stopTest();
        System.assertEquals(
            null,
            eligibilityForOfferedCourses,
            'Expected eligibility to be empty due to no academic provider mappings.'
        );
    }

    @IsTest
    static void testGetEligibleCoursesWithoutCourseOfferings() {
        Boolean caughtException = false;
        List<CourseEligibility> eligibilityForOfferedCourses;
        User contextUser = [SELECT Id, Contact.AccountId FROM User WHERE Username = 'CommunityUser@Test.org' LIMIT 1];
        Id academicProviderId = [SELECT Id FROM Account WHERE School_of_Record__c = true LIMIT 1].Id;
        List<SObject> programOfferings = new List<SObject>();
        Transcript_Evaluation__c evaluation = getMockTranscriptEvaluation();
        evaluation.Student__c = contextUser.Contact.AccountId;
        insert evaluation;
        for (Course__c course :[SELECT Id FROM Course__c]) {
            programOfferings.add(new Academic_Provider_Mapping__c(
                Academic_Provider__c = academicProviderId,
                Course__c = course.Id
            ));
        }
        if (!programOfferings.isEmpty()) {
            insert programOfferings;
        }
        Test.startTest();
        try {
            System.runAs(contextuser){
                eligibilityForOfferedCourses = CourseInterestController.getEligibleCourses();
            }
        } catch (AuraHandledException ex) {
            caughtException = true;
        }
        Test.stopTest();
        System.assertEquals(
            null,
            eligibilityForOfferedCourses,
            'Expected eligibility to be empty due to no course offerings.'
        );
    }

    @IsTest
    static void testGetEligibleCoursesWithCoursesFullyMapped() {
        List<CourseEligibility> eligibilityForOfferedCourses;
        User contextUser = [SELECT Id, Contact.AccountId FROM User WHERE Username = 'CommunityUser@Test.org' LIMIT 1];
        Id programId = [SELECT Program__c FROM Enrollment_Record__c LIMIT 1].Program__c;
        Id academicProviderId = [SELECT Id FROM Account WHERE School_of_Record__c = true LIMIT 1].Id;
        List<SObject> programOfferings = new List<SObject>();
        Transcript_Evaluation__c evaluation = getMockTranscriptEvaluation();
        evaluation.Student__c = contextUser.Contact.AccountId;
        insert evaluation;
        for (Course__c course :[SELECT Id FROM Course__c]) {
            programOfferings.add(new Course_Offering__c(
                Program__c = programId,
                Course__c = course.Id
            ));
            programOfferings.add(new Academic_Provider_Mapping__c(
                Academic_Provider__c = academicProviderId,
                Course__c = course.Id
            ));
        }
        if (!programOfferings.isEmpty()) {
            insert programOfferings;
        }
        Test.startTest();
        System.runAs(contextuser){
            eligibilityForOfferedCourses = CourseInterestController.getEligibleCourses();
        }
        Test.stopTest();
        System.assertNotEquals(
            null,
            eligibilityForOfferedCourses,
            'Expected eligibility to not be empty.'
        );
    }

    @IsTest
    static void testSaveCourseSelection() {
        User contextUser = [SELECT Id, Contact.AccountId FROM User WHERE Username = 'CommunityUser@Test.org' LIMIT 1];
        Course sampleCourse = new Course();
        System.debug([SELECT Id FROM Course__c]);
        sampleCourse.Id = [SELECT Id FROM Course__c WHERE Name = 'Sample Course' LIMIT 1].Id;
        sampleCourse.creditHours = 3;
        Course sampleCorequisiteCourse = new Course();
        sampleCorequisiteCourse.Id = [SELECT Id FROM Course__c WHERE Name = 'Sample Corequisite Course' LIMIT 1].Id;
        sampleCorequisiteCourse.creditHours = 3;
        Test.startTest();
        System.runAs(contextUser) {
            CourseInterestController.saveCourseSelection(
                new List<Course>{sampleCourse}, 
                new List<Course>{sampleCorequisiteCourse}
            );
        }
        Test.stopTest();
        List<Course_Interest__c> courseInterests = [
            SELECT Id, Course__c, Enrollment_Record__c, Credit_Hours__c, Preference_Rank__c, Type__c 
            FROM Course_Interest__c
            WHERE Enrollment_Record__r.Student_Account__c = :contextUser.Contact.AccountId
        ];
        System.assertEquals(
            2,
            courseInterests.size(),
            'Expected 2 Course Interests to be created.'
        );
    }

    private static Transcript_Evaluation__c getMockTranscriptEvaluation() {
        return new Transcript_Evaluation__c(
            College_Credit_Received_For__c = null,
            Eligible_Courses__c = null,
            GPA__c = 3.5,
            Math_Completed__c = 'Algebra II',
            Junior_Year_English_Grade__c = 'B- or Higher',
            Spanish_Completed__c = 'One Year'
        );
    }
}