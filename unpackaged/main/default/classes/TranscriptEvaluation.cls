public with sharing class TranscriptEvaluation {
    
    private static Transcript_Evaluation__c transcriptEvaluation;

    public static void updateEvaluationWithCourseEligibility(Transcript_Evaluation__c evaluation) {
        List<CourseEligibility> eligibilities = getAllCourseEligibility(evaluation);
        Map<String, List<CourseEligibility>> eligibilityMap = sortCourseEligibilities(eligibilities);
        evaluation.Eligible_To_Take__c = getSemicolonSeperateCourseEligibilityList(eligibilityMap.get('Eligible'));
        evaluation.Eligible_Courses__c = getJsonCourseEligibilitySerialization(eligibilityMap.get('Eligible'));
        evaluation.Ineligible_To_Take__c = getSemicolonSeperateCourseEligibilityList(eligibilityMap.get('Ineligible'));
        evaluation.Ineligible_Courses__c = getJsonCourseEligibilitySerialization(eligibilityMap.get('Ineligible') );
    }


    public static List<CourseEligibility> getAllCourseEligibility(Transcript_Evaluation__c evaluation) {
        return getCourseEligibilityForSelectCourses(evaluation, getAllCourses());
    }

    public static List<CourseEligibility> getCourseEligibilityForSelectCourses(
        Transcript_Evaluation__c evaluation,
        List<Course> coursesToEvaluationEligibility
    ) {
        transcriptEvaluation = evaluation;
        List<CourseEligibility> result = new List<CourseEligibility>();
        for (Course course :coursesToEvaluationEligibility) {
            if (evaluateReceivedPriorCollegeCredit(course.name)) {
                //if the student has received prior college credit, the course is ineligible
                result.add(
                    new CourseEligibility()
                    .setCourse(course)
                    .setIsEligible(false)
                );
                continue;
            }
            if (!course.hasPrerequisites) {
                result.add(
                    new CourseEligibility()
                    .setCourse(course)
                    .setIsEligible(true)  
                );
                continue;
            }
            //if previous check is false, then check to see if the course has prerequisites
            if (evaluatePrequalified(course.name)) {
                //if prequalified by auditer, then course is eligible.
                result.add(
                    new CourseEligibility()
                        .setCourse(course)
                        .setIsEligible(true)
                );
                continue;
            }
            //After above checks, let the CourseEligibility class handle evaluating if eligible, etc.
            result.add(
                new CourseEligibility()
                    .setCourse(course)
                    .evaluateEligibility(evaluation)
            );
        }
        return result;
    }

    private static List<Course> getAllCourses() {
        List<Course> courses = new List<Course>();
        for (Course__c course :[
            SELECT Id, Name, Subject__c, hasPrerequisites__c, Highest_Prerequisite_Group__c, Description__c,
                (
                    SELECT Course__c, Type__c, Group__c, Condition__c, Corequisite_Course__c, Corequisite_Course__r.Name
                    FROM Course_Prerequisites__r
                )
            FROM Course__c
            WHERE Status__c = 'Active'
            WITH SECURITY_ENFORCED
            ORDER BY Name ASC
        ]) {
            courses.add(new Course(
               course
            ));
        }
        return courses;
    }

    private static boolean evaluatePrequalified(String courseName) {
        if (transcriptEvaluation?.Prerequisites_Satisfied_For__c == null) {
            return false;
        }
        List<String> eligibleCourses = transcriptEvaluation.Prerequisites_Satisfied_For__c.contains(';') ?
            transcriptEvaluation.Prerequisites_Satisfied_For__c.split(';') :
            new List<String>{transcriptEvaluation.Prerequisites_Satisfied_For__c};
        if (eligibleCourses == null) {
            return false;
        }
        return eligibleCourses.contains(courseName);
    }

    private static boolean evaluateReceivedPriorCollegeCredit(String courseName) {
        if (transcriptEvaluation?.College_Credit_Received_For__c == null) {
            return false;
        }
        List<String> ineligibleCourses = transcriptEvaluation.College_Credit_Received_For__c.contains(';') ?
            transcriptEvaluation.College_Credit_Received_For__c.split(';') :
            new List<String>{transcriptEvaluation.College_Credit_Received_For__c};
        return ineligibleCourses.contains(courseName);
    }

    private static Map<String, List<CourseEligibility>> sortCourseEligibilities(
        List<CourseEligibility> eligibilities
    ) {
        Map<String, List<CourseEligibility>> sortedEligibility = new Map<String, List<CourseEligibility>>{
            'Eligible' => new List<CourseEligibility>(),
            'Ineligible' => new List<CourseEligibility>()
        };
        for (CourseEligibility eligibility :eligibilities) {
            if (eligibility.isEligible) {
                sortedEligibility.get('Eligible').add(eligibility);
            } else {
                sortedEligibility.get('Ineligible').add(eligibility);
            }
        }
        return sortedEligibility;
    }

    private static String getJsonCourseEligibilitySerialization(List<CourseEligibility> courseEligibilities) {
        return JSON.serializePretty(courseEligibilities, true);
    }

    private static String getSemicolonSeperateCourseEligibilityList(List<CourseEligibility> courseEligibilities) {
        List<String> courseNames = new List<String>();
        for (CourseEligibility courseEligibility :courseEligibilities) {
            courseNames.add(courseEligibility.course.name);
        }
        return String.join(courseNames, '; ');
    }
}