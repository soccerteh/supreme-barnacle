@IsTest
public with sharing class CourseEligibilityTests {

    @TestSetup
    static void makeData(){
        TestDataFactory.insertMockCoursesWithPrerequisites();
        TriggerHandler.suppressHandler('AccountTriggerHandler');
        TriggerHandler.suppressHandler('TranscriptEvaluationTriggerHandler');
        Account sampleAccount = new Account(
            Name = 'Sample Account',
            First_Name__c = 'Sample',
            Last_Name__c = 'Account',
            Email__c = 'SampleAccount@Test.org',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId()
        );
        insert sampleAccount;
        insert new Transcript_Evaluation__c(
            Student__c = sampleAccount.Id,
            College_Credit_Received_For__c = null,
            Eligible_Courses__c = null,
            GPA__c = 3.5,
            Math_Completed__c = 'Algebra II',
            Junior_Year_English_Grade__c = 'B- or Higher',
            Spanish_Completed__c = 'One Year'
        );
        TriggerHandler.clearSuppressedHandlers();
    }

    @IsTest
    static void testDefaultConstructor() {
        Test.startTest();
        CourseEligibility eligibility = new CourseEligibility();
        Test.stopTest();
        System.assertNotEquals(
            null,
            eligibility.prerequisiteGroupsSatisfied,
            'Expected prerequisiteGroupsSatisfied property to be initialized to a new collection.'
        );
        System.assertEquals(
            new List<String>(),
            eligibility.prerequisiteGroupsSatisfied,
            'Expected prerequisiteGroupsSatisfied property to be initialized to a new collection.'
        );
    }

    @IsTest
    static void testSetCourse() {
        Test.startTest();
        CourseEligibility eligibility = new CourseEligibility().setCourse(getCourseObjectByName('Sample Course'));
        Test.stopTest();
        System.assertNotEquals(
            null,
            eligibility.course,
            'Expected course property to be initialized as a new course object.'
        );
        System.assertNotEquals(
            null, 
            eligibility.course.id, 
            'Expected the course\'s id property to be initialized.'
        );
    }

    @IsTest
    static void testSetIsEligible() {
        Test.startTest();
        CourseEligibility eligible = new CourseEligibility().setIsEligible(true);
        CourseEligibility ineligible = new CourseEligibility().setIsEligible(false);
        Test.stopTest();
        System.assertEquals(
            true,
            eligible.isEligible,
            'Expected isEligible to be true for the Eligible object.'
        );
        System.assertEquals(
            false,
            ineligible.isEligible,
            'Expected isEligible to be false for the Ineligible object.'
        );
    }

    @IsTest
    static void testEvaluateEligibilityWithoutCourseSet() {
        Boolean exceptionThrown = false;
        Transcript_Evaluation__c evaluation = [
            SELECT Id, College_Credit_Received_For__c, Eligible_Courses__c,
            GPA__c, Math_Completed__c, Junior_Year_English_Grade__c,
            Spanish_Completed__c
            FROM Transcript_Evaluation__c
            LIMIT 1
        ];
        Test.startTest();
        try {
            CourseEligibility eligibility = new CourseEligibility().evaluateEligibility(evaluation);
        } catch (CourseEligibility.CourseEligibilityException ex) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assertEquals(
            true,
            exceptionThrown,
            'Expected exceptionThrown to be set as true after catching the custom exception.'
        );
    }

    @IsTest
    static void testEvaluateEligibility() {
        Boolean exceptionThrown = false;
        Transcript_Evaluation__c evaluation = [
            SELECT Id, College_Credit_Received_For__c, Eligible_Courses__c,
            GPA__c, Math_Completed__c, Junior_Year_English_Grade__c,
            Spanish_Completed__c
            FROM Transcript_Evaluation__c
            LIMIT 1
        ];
        Test.startTest();
        try {
            CourseEligibility eligibility = new CourseEligibility()
                                                .setCourse(getCourseObjectByName('Sample Course'))
                                                .evaluateEligibility(evaluation);
        } catch (CourseEligibility.CourseEligibilityException ex) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assertEquals(
            false,
            exceptionThrown,
            'Expected exceptionThrown to be set as true after catching the custom exception.'
        );
    }

    private static Course getCourseObjectByName(String name) {
        return new Course([
            SELECT Id, Name, Subject__c, Description__c, hasPrerequisites__c,
            (SELECT Credit_Hours__c, Prerequisite_Description__c, Corequisite_Description__c FROM Academic_Provider_Mappings__r),
            (SELECT Course__c, Type__c, Group__c, Condition__c, Corequisite_Course__c, Corequisite_Course__r.Name FROM Course_Prerequisites__r)
            FROM Course__c
            WHERE Name = :name
        ]);
    }
}