public without sharing class CourseInterestController {


    @AuraEnabled(cacheable=true)
    public static List<CourseEligibility> getEligibleCourses() {
        //Query courses being offered at the program for the student's academic provider
        StudentInformation studentInfo = StudentInformation.getStudentInfosForRunningUser();
        if (studentInfo.enrollment?.Course_Registration_Close_Date__c < System.today()) {
            throw new AuraHandledException('Course Registration Closed for Participant.');
        }
        if (studentInfo.academicProviderId == null) {
            throw new AuraHandledException('Academic Provider not set.');
        }
        List<Course> coursesAvailableAtProgram = new List<Course>();
        for(Course__c course :[
                SELECT Id, Name, Subject__c, Description__c, hasPrerequisites__c,
                (SELECT Credit_Hours__c, Prerequisite_Description__c, Corequisite_Description__c FROM Academic_Provider_Mappings__r WHERE Academic_Provider__c = :studentInfo.academicProviderId),
                (SELECT Course__c, Type__c, Group__c, Condition__c, Corequisite_Course__c, Corequisite_Course__r.Name FROM Course_Prerequisites__r)
                FROM Course__c
                WHERE Status__c = 'Active'
                AND Id IN (SELECT Course__c FROM Course_Offering__c WHERE Program__c = :studentInfo.currentProgramId)
                AND Id IN (SELECT Course__c FROM Academic_Provider_Mapping__c WHERE Academic_Provider__c = :studentInfo.academicProviderId)
                ORDER BY Name ASC
        ]) {
            Course courseObject = new Course(course);
            courseObject.creditHours = (Integer) course.Academic_Provider_Mappings__r[0]?.Credit_Hours__c;
            coursesAvailableAtProgram.add(courseObject);
        }
        if (coursesAvailableAtProgram.isEmpty()) {
            throw new AuraHandledException('No courses available at program for Academic Provider.');
        }
        List<Transcript_Evaluation__c> evaluations = [
            SELECT Id, College_Credit_Received_For__c, Prerequisites_Satisfied_For__c,
            Math_Completed__c, Spanish_Completed__c, Junior_Year_English_Grade__c, GPA__c,
            Transcript_Type__c, Comments__c 
            FROM Transcript_Evaluation__c 
            WHERE Student__c = :studentInfo.accountId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if(evaluations.isEmpty()) {
            throw new AuraHandledException('No Transcript Evaluation on file.');
        }
        if (!coursesAvailableAtProgram.isEmpty()) {
            return TranscriptEvaluation.getCourseEligibilityForSelectCourses(
                evaluations[0],
                coursesAvailableAtProgram
            );
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static void saveCourseSelection(
        List<Course> primaryChoices,
        List<Course> altChoices
    ) {
        try {
            StudentInformation studentInfo = StudentInformation.getStudentInfosForRunningUser();
            List<Course_Interest__c> courseInterests = new List<Course_Interest__c>();
            for (Integer i = 0; i < primaryChoices.size(); i++) {
                courseInterests.add(new Course_Interest__c(
                    Enrollment_Record__c = studentInfo.enrollment.Id,
                    Course__c = primaryChoices[i].id,
                    Credit_Hours__c = primaryChoices[i].creditHours,
                    Preference_Rank__c = String.valueOf(i + 1),
                    Type__c = 'Primary'
                ));
            }
            for (Integer i = 0; i < altChoices.size(); i++) {
                courseInterests.add(new Course_Interest__c(
                    Enrollment_Record__c = studentInfo.enrollment.Id,
                    Course__c = altChoices[i].id,
                    Credit_Hours__c = altChoices[i].creditHours,
                    Preference_Rank__c = String.valueOf(i + 1),
                    Type__c = 'Alternative'
                ));
            }
            if (!courseInterests.isEmpty()) {
                delete [SELECT Id FROM Course_Interest__c WHERE Enrollment_Record__c = :studentInfo.enrollment.Id];
                insert courseInterests;
            }
            update new Enrollment_Record__c(
                Id = studentInfo.enrollment.Id,
                Course_Interest_Submitted__c = true
            );
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
            //create unhandled Exception record.
        }
    }

    /* private Boolean evaluateIfAllCoursesEligible(List<CourseEligibility> courseEligibility) {
        //for each item do the following:
        //check if each course eligibility is marked as true
        //check if the corequisite requirements are met
    } */

    /* private void evaluateForCorequisiteRequirement(List<CourseEligibility> courseEligibility) {
        //put each item into a map of name + object for quicker lookup validations later
        //for each course that's evaluated, check to see if a corequisite is required
        //if false, continue to next course
        //if true, search the other items in the collection (map keySet) to see if the corequisite is included
        //=> then if it is within the collection, continue to the next course
        //=> if not, throw an exception
        //=> => throw new AuraHandledException([coreqCourseName] + ' is a corequisite course of ' + [currentItemName] + ' and must be included.');
    } */
}