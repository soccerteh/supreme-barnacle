@IsTest
public with sharing class CourseTests {

    @TestSetup
    static void makeData(){
        TestDataFactory.insertMockCoursesWithPrerequisites();
    }

    @IsTest
    static void testDefaultConstructor() {
        Test.startTest();
        Course course = new Course();
        Test.stopTest();
        System.assertEquals(
            null,
            course.name,
            'Expected name property to be null.'
        );
        System.assertEquals(
            new Map<String, List<Course.Prerequisite>>(),
            course.prerequisites,
            'Expected prerequisites property to be uninitialized.'
        );
    }

    @IsTest
    static void testConstructorWithoutPrerequisitesIncluded() {
        Course__c sampleCourse = [
            SELECT Id, Name, Description__c, Subject__c, hasPrerequisites__c 
            FROM Course__c 
            LIMIT 1
        ];
        Test.startTest();
        Course course = new Course(sampleCourse);
        Course nullCourse = new Course();
        Test.stopTest();
        System.assertEquals(
            sampleCourse.name,
            course.name,
            'Expected name property to match the course record\'s name'
        );
        System.assertEquals(
            new Map<String, List<Course.Prerequisite>>(),
            course.prerequisites,
            'Expected prerequisites property to be uninitialized.'
        );
    }

    @IsTest
    static void testConstructorWithPrerequisitesIncluded() {
        Course__c sampleCourse = [
            SELECT Id, Name, Description__c, Subject__c, hasPrerequisites__c,
            (
                SELECT Id, Course__c, Question__c, Condition__c, 
                Group__c, Type__c, Corequisite_Course__c
                FROM Course_Prerequisites__r
                WHERE Type__c = 'Prerequisite'
            )
            FROM Course__c 
            LIMIT 1
        ];
        Test.startTest();
        Course course = new Course(sampleCourse);
        Test.stopTest();
        System.assertEquals(
            sampleCourse.name,
            course.name,
            'Expected name property to match the course record\'s name'
        );
        System.assertNotEquals(
            new Map<String, List<Course.Prerequisite>>(),
            course.prerequisites,
            'Expected prerequisites property to be initialized with the prerequisites.'
        );
        System.assertEquals(
            new List<Course.Corequisite>(),
            course.corequisites,
            'Expected corequisite property to be unitialized.'
        );
    }

    @IsTest
    static void testConstructorWithCorequisitesIncluded() {
        Course__c sampleCourse = [
            SELECT Id, Name, Description__c, Subject__c, hasPrerequisites__c,
            (
                SELECT Id, Course__c, Condition__c, Group__c,
                Type__c, Corequisite_Course__c, Corequisite_Course__r.Name
                FROM Course_Prerequisites__r
                WHERE Type__c = 'Corequisite'
            )
            FROM Course__c 
            LIMIT 1
        ];
        Test.startTest();
        Course course = new Course(sampleCourse);
        Test.stopTest();
        System.assertEquals(
            sampleCourse.name,
            course.name,
            'Expected name property to match the course record\'s name'
        );
        System.assertEquals(
            new Map<String, List<Course.Prerequisite>>(),
            course.prerequisites,
            'Expected prerequisites property to be unitialized.'
        );
        System.assertNotEquals(
            new List<Course.Corequisite>(),
            course.corequisites,
            'Expected corequisite property to be initialized with the corequisites.'
        );
    }

    @IsTest
    static void testConditionlessPrerequisiteBeingMet() {
        Course_Prerequisite__c coursePrereq = [
            SELECT Id, Course__c, Question__c, Condition__c, 
            Group__c, Type__c, Corequisite_Course__c
            FROM Course_Prerequisite__c
            WHERE Type__c = 'Prerequisite'
            AND Condition__c != null
            LIMIT 1
        ];
        coursePrereq.Condition__c = null;
        Test.startTest();
        Course.Prerequisite prerequisite = new Course.Prerequisite(coursePrereq);
        Boolean expectedPass = prerequisite.isConditionMet(new Set<String>{});
        System.assertEquals(
            true,
            expectedPass,
            'Expected the returned result from isConditionMet to be true.'
        );
    }

    @IsTest
    static void testPrerequisiteConditionMet() {
        Course_Prerequisite__c coursePrereq = [
            SELECT Id, Course__c, Question__c, Condition__c, 
            Group__c, Type__c, Corequisite_Course__c
            FROM Course_Prerequisite__c
            WHERE Type__c = 'Prerequisite'
            AND Condition__c != null
            LIMIT 1
        ];
        Test.startTest();
        Course.Prerequisite prerequisite = new Course.Prerequisite(coursePrereq);
        Boolean expectedPass = prerequisite.isConditionMet(new Set<String>{coursePrereq.Condition__c});
        Boolean expectedFail = prerequisite.isConditionMet(new Set<String>{'Hello World'});
        Test.stopTest();
        System.assertEquals(
            true,
            expectedPass,
            'Expected the returned result from isConditionMet to be true.'
        );
        System.assertEquals(
            false,
            expectedFail,
            'Expected the returned result from isConditionMet to be false'
        );
    }

    @IsTest
    static void testCorequisiteEstablishStrictRequirement() {
        Course_Prerequisite__c courseCorequisite = [
            SELECT Id, Course__c, Condition__c, Group__c,
            Type__c, Corequisite_Course__c, Corequisite_Course__r.Name
            FROM Course_Prerequisite__c
            WHERE Type__c = 'Corequisite'
            LIMIT 1
        ];
        courseCorequisite.Group__c = null;
        Test.startTest();
        Course_Prerequisite__c mirroredCorequisite = new Course.Corequisite(courseCorequisite).establishStrictRequirement();
        Test.stopTest();
        System.assertEquals(
            mirroredCorequisite.Course__c,
            courseCorequisite.Corequisite_Course__c,
            'Expected Course Id and Corequisite Course Id to be switched for the mirroredCorequisite'
        );
    }
   
}