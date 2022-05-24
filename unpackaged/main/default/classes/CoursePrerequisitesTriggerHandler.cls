public with sharing class CoursePrerequisitesTriggerHandler {
    public CoursePrerequisitesTriggerHandler() {

    }
    public static void handleBeforeInsert(List<Course_Prerequisite__c> prerequisites) {
        List<Id> courseIdsToUpdate = new List<Id>();
        List<Course_Prerequisite__c> corequisites = new List<Course_Prerequisite__c>();
        for (Course_Prerequisite__c prerequisite : prerequisites) {
            if (prerequisite.Type__c == 'Corequisite') {
                corequisites.add(prerequisite);
            }
            courseIdsToUpdate.add(prerequisite.Course__c);
        }
        if (!corequisites.isEmpty()) {
            insertRequiredCorequisites(corequisites);
        }
        if (!courseIdsToUpdate.isEmpty()) {
            updateCoursePrerequisiteGroups(courseIdsToUpdate);
        }
    }

    private static void insertRequiredCorequisites(List<Course_Prerequisite__c> corequisites) {
        List<Course_Prerequisite__c> mirroredCorequisites = new List<Course_Prerequisite__c>();
        for (Course_Prerequisite__c prereq :corequisites) {
            if (prereq.Type__c == 'Corequisite' && prereq.Group__c == null) {
                Course.Corequisite corequisite = new Course.Corequisite(prereq);
                mirroredCorequisites.add(corequisite.establishStrictRequirement());
            }
        }
        if (!mirroredCorequisites.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(mirroredCorequisites, false);
            for (Database.SaveResult result : results) {
                if (result.success) {
                    continue;
                }
                //handle unhandled exception
            }
        }
    }

    private static void updateCoursePrerequisiteGroups(List<Id> courseIds) {
        List<Course__c> coursesToUpdate = new List<Course__c>();
        for (Course__c course :[
            SELECT Id, Highest_Prerequisite_Group__c,
            (SELECT Id, Group__c FROM Course_Prerequisites__r ORDER BY Group__c DESC) 
            FROM Course__c
            WHERE ID IN :courseIds
            WITH SECURITY_ENFORCED
        ]) {
            if (course.Course_Prerequisites__r.isEmpty()) {
                continue;
            }
            String highestPrerequisiteGroup;
            for (Course_Prerequisite__c preReq :course.Course_Prerequisites__r) {
                if (preReq.Group__c != null) {
                    if (highestPrerequisiteGroup < preReq.Group__c) {
                        highestPrerequisiteGroup = preReq.Group__c;
                    }
                }
            }
            if (
                highestPrerequisiteGroup != null && 
                highestPrerequisiteGroup != course.Highest_Prerequisite_Group__c
            ) {
                course.Highest_Prerequisite_Group__c = highestPrerequisiteGroup;
                coursesToUpdate.add(course);
            }
        }
        if (!coursesToUpdate.isEmpty() && Schema.sObjectType.Course__c.isUpdateable()) {
            List<Database.SaveResult> results = Database.update(coursesToUpdate);
            /* if (!results.isSuccess()) {
                //handle errors
            } */
        }
    }
}