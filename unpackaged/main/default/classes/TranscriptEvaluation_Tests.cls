@isTest
public with sharing class TranscriptEvaluation_Tests {
    
    @TestSetup
    static void insertCourses(){
        List<Course__c> coursesWithPrerequisites = new List<Course__c>();
        List<Course__c> coursesWithoutPrerequisites = new List<Course__c>();
        Course__c rhetoricAndResearch = new Course__c(
            Name = 'Rhetoric & Research',
            Course_Type__c = 'Lecture Only',
            Status__c = 'Active',
            Subject__c = 'English'
        );
        coursesWithPrerequisites.add(rhetoricAndResearch);
        Course__c britishLiterature = new Course__c(
            Name = 'British Literature II',
            Course_Type__c = 'Lecture Only',
            Status__c = 'Active',
            Subject__c = 'English'
        );
        coursesWithoutPrerequisites.add(britishLiterature);
        Course__c introductionToStatistics = new Course__c(
            Name = 'Introduction to Statistics',
            Course_Type__c = 'Lecture Only',
            Status__c = 'Active',
            Subject__c = 'Mathematics'
        );
        coursesWithPrerequisites.add(introductionToStatistics);
        Course__c intermediateSpanishI = new Course__c(
            Name = 'Intermediate Spanish I',
            Course_Type__c = 'Lecture Only',
            Status__c = 'Active',
            Subject__c = 'Mathematics'
        );
        coursesWithPrerequisites.add(intermediateSpanishI);
        Course__c aLP = new Course__c(
            Name = 'ALP',
            Course_Type__c = 'Lecture Only',
            Status__c = 'Active',
            Subject__c = 'English'
        );
        coursesWithoutPrerequisites.add(aLP);
        insert coursesWithPrerequisites;
        insert coursesWithoutPrerequisites;
        List<Course_Prerequisite__c> coursePrereqs = new List<Course_Prerequisite__c>();
        coursePrereqs.add(new Course_Prerequisite__c(
            Course__c = rhetoricAndResearch.Id,
            Question__c = 'What was the students Junior year English grade?',
            Condition__c = 'B- or Higher',
            Group__c = 'A',
            Type__c = 'Prerequisite'
        ));
        coursePrereqs.add(new Course_Prerequisite__c(
            Course__c = britishLiterature.Id,
            Question__c = 'What was the students Junior year English grade?',
            Condition__c = 'B- or Higher',
            Group__c = 'A',
            Type__c = 'Prerequisite'
        ));
        coursePrereqs.add(new Course_Prerequisite__c(
            Course__c = rhetoricAndResearch.Id,
            Question__c = 'What was the students Junior year English grade?',
            Condition__c = 'C+ or Lower',
            Group__c = 'B',
            Corequisite_Course__c = aLP.Id,
            Type__c = 'Corequisite'
        ));
        coursePrereqs.add(new Course_Prerequisite__c(
            Course__c = aLP.Id,
            Question__c = 'What was the students Junior year English grade?',
            Condition__c = 'C+ or Lower',
            Group__c = 'A',
            Type__c = 'Prerequisite'
        ));
        coursePrereqs.add(new Course_Prerequisite__c(
            Course__c = introductionToStatistics.Id,
            Question__c = 'What is the students highest level of math completed with a C or greater?',
            Condition__c = 'Pre-Calculus',
            Group__c = 'A',
            Type__c = 'Prerequisite'
        ));
        coursePrereqs.add(new Course_Prerequisite__c(
            Course__c = intermediateSpanishI.Id,
            Question__c = 'How many years of High School Spanish has the student completed with a C or greater?',
            Condition__c = 'Two Years',
            Group__c = 'A',
            Type__c = 'Prerequisite'
        ));
        insert coursePrereqs;
        insert new Account(
            First_Name__c = 'Timmy',
            Last_Name__c = 'Trumpet',
            Name = 'Timmy Trumpet',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId()
        );
    }

    @IsTest
    static void testNoCourseElegible(){
        
        Test.startTest();
        Transcript_Evaluation__c evaluation = new Transcript_Evaluation__c(
            Student__c = [SELECT Id FROM Account WHERE Name = 'Timmy Trumpet'].Id,
            Transcript_Type__c = 'Final'            
        );
        insert evaluation;
        Test.stopTest();
        evaluation = [SELECT Id, Eligible_To_Take__c, Ineligible_To_Take__c FROM Transcript_Evaluation__c];
        System.assertEquals(
            null,
            evaluation.Eligible_To_Take__c,
            'Expected Eligible Courses to be empty/null.'
        );
        System.assertEquals(
            true,
            evaluation.Ineligible_To_Take__c.contains('Rhetoric & Research'),
            'Expected Ineligible Courses to contain Rhetoric & Research I.'
        );
        System.assertEquals(
            true,
            evaluation.Ineligible_To_Take__c.contains('Intermediate Spanish I'),
            'Expected Ineligible Courses to contain Intermediate Spanish I.'
        );
        System.assertEquals(
            true,
            evaluation.Ineligible_To_Take__c.contains('Introduction to Statistics'),
            'Expected Ineligible Courses to contain Introduction to Statistics.'
        );
        System.assertEquals(
            true,
            evaluation.Ineligible_To_Take__c.contains('ALP'),
            'Expected Ineligible Courses to contain ALP.'
        );
        System.assertEquals(
            5,
            evaluation.Ineligible_To_Take__c.split(';').size(),
            'Expected 4 Ineligible Courses to be listed.'
        );
    }

    @IsTest
    static void testPrequalifiedEligibleCourses() {
        Test.startTest();
        /* System.runAs(contextuser){
        
        } */
        Transcript_Evaluation__c firstEvaluation = new Transcript_Evaluation__c(
            Student__c = [SELECT Id FROM Account WHERE Name = 'Timmy Trumpet'].Id,
            Transcript_Type__c = 'Final',
            Prerequisites_Satisfied_For__c = 'British Literature II'           
        );
        insert firstEvaluation;
        Transcript_Evaluation__c secondEvaluation = new Transcript_Evaluation__c(
            Student__c = [SELECT Id FROM Account WHERE Name = 'Timmy Trumpet'].Id,
            Transcript_Type__c = 'Final',
            Prerequisites_Satisfied_For__c = 'British Literature II;Intermediate Spanish I'
        );
        insert secondEvaluation;
        Test.stopTest();
        firstEvaluation = [SELECT Id, Eligible_To_Take__c, Ineligible_To_Take__c FROM Transcript_Evaluation__c WHERE ID = :firstEvaluation.Id];
        secondEvaluation = [SELECT Id, Eligible_To_Take__c, Ineligible_To_Take__c FROM Transcript_Evaluation__c WHERE ID = :secondEvaluation.Id];
        System.assertEquals(
            true,
            firstEvaluation.Eligible_To_Take__c?.contains('British Literature II'),
            'Expected Eligible Courses to contain Rhetoric & Research I.'
        );
        System.assertEquals(
            true,
            secondEvaluation.Eligible_To_Take__c?.contains('British Literature II'),
            'Expected Eligible Courses to contain Rhetoric & Research I.'
        );
        System.assertEquals(
            true,
            secondEvaluation.Eligible_To_Take__c?.contains('Intermediate Spanish I'),
            'Expected Eligible Courses to contain Intermediate Spanish I.'
        );
    }

    @IsTest
    static void testCourseWithSingleGroup(){
        
        Test.startTest();
        /* System.runAs(contextuser){
            
        } */
        Test.stopTest();
        
    }

    @IsTest
    static void testCourseWithMultipleGroups(){
        
        Test.startTest();
        /* System.runAs(contextuser){
            
        } */
        Test.stopTest();
        
    }

    @IsTest
    static void testMultipleCoursesEligible(){
        
        Test.startTest();
        /* System.runAs(contextuser){
            
        } */
        Test.stopTest();
        
    }

    @IsTest    
    static void testEligibilityWithoutPrerequisites() {
        //delete all prerequisites and run evaluation
    }


    @IsTest
    static void testBulkEvaluating(){
        
        Test.startTest();
        /* System.runAs(contextuser){
            
        } */
        Test.stopTest();
        
    }

    @IsTest
    static void  testCorequisiteLoading() {
        Test.startTest();
        /* System.runAs(contextuser){

        } */
        insert new Course_Prerequisite__c(
            Course__c = [SELECT Id FROM Course__c WHERE Name = 'Rhetoric & Research' LIMIT 1].Id,
            Corequisite_Course__c = [SELECT Id FROM Course__c WHERE Name = 'ALP' LIMIT 1].Id,
            Type__c = 'Corequisite',
            Group__c = null
        );
        Test.stopTest();
    }
}