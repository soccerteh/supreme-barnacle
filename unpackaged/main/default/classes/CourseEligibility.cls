public with sharing class CourseEligibility {
    @AuraEnabled
    public Course course {get; set;}
    @AuraEnabled
    public List<String> prerequisiteGroupsSatisfied {get; set;}
    @AuraEnabled
    public Boolean isEligible {get; set;}
    @AuraEnabled
    public Boolean requiresCorequisite {get; set;}
    @AuraEnabled
    public Id corequisiteCourseId {get; set;}
    @AuraEnabled
    public String corequisiteCourseName {get; set;}
    
    

    public CourseEligibility() {
        this.prerequisiteGroupsSatisfied = new List<String>();
    }

    public CourseEligibility setCourse(Course course) {
        this.course = course;
        return this;
    }

    public CourseEligibility setIsEligible(Boolean isEligible) {
        this.isEligible = isEligible;
        return this;
    }

    public CourseEligibility evaluateEligibility(Transcript_Evaluation__c evaluation) {
        if (this.course == null) {
            throw new CourseEligibilityException('No course set to evaluate.');
        }
        this.evaluatePrerequisites(evaluation);
        this.evaluateCorequisites();
        this.isEligible = !this.prerequisiteGroupsSatisfied.isEmpty();
        return this;
    }

    private CourseEligibility evaluatePrerequisites(Transcript_Evaluation__c evaluation) {
        if (!this.course.hasPrerequisites) {
            this.isEligible = true;
            this.requiresCorequisite = false;
            return this;
        } else {
            Set<String> answeredQuestions = new Set<String>();
            answeredQuestions.add(evaluation.Math_Completed__c);
            answeredQuestions.add(evaluation.Spanish_Completed__c);
            answeredQuestions.add(evaluation.Junior_Year_English_Grade__c);
            answeredQuestions.remove(null);
            for (String groupLetter :this.course.prerequisites.keySet()) {
                List<Boolean> conditionEvaluationResults = new List<Boolean>();
                for (Course.Prerequisite prereq :this.course.prerequisites.get(groupLetter)) {
                    conditionEvaluationResults.add(
                        prereq.isConditionMet(answeredQuestions)
                    );
                }
                if (conditionEvaluationResults.contains(false)) {
                    continue;
                }
                this.prerequisiteGroupsSatisfied.add(groupLetter);
            }
        }
        return this;
    }

    private void evaluateCorequisites() {
        if (this.course.hasCorequisites) {
            Set<String> groupsNotRequiringCorequisite = new Set<String>(this.prerequisiteGroupsSatisfied);
            Map<String, Course.Corequisite> groupsRequiringCorequisite = new Map<String, Course.Corequisite>();
            for (Course.Corequisite corequisite :this.course.corequisites) {
                if (corequisite.strictRequirement) {
                    this.corequisiteCourseId = corequisite.corequisiteId;
                    this.corequisiteCourseName = corequisite.corequisiteName;
                    groupsNotRequiringCorequisite.clear();
                    break;
                }
                if (this.prerequisiteGroupsSatisfied.contains(corequisite.corequisiteGroup)) {
                    groupsNotRequiringCorequisite.remove(corequisite.corequisiteGroup);
                    groupsRequiringCorequisite.put(corequisite.corequisiteGroup, corequisite);
                }
            }
            this.requiresCorequisite = groupsNotRequiringCorequisite.isEmpty();
            if (groupsNotRequiringCorequisite.isEmpty()) {
                for (String prerequisiteGroup :this.prerequisiteGroupsSatisfied) {
                    if (groupsRequiringCorequisite.containsKey(prerequisiteGroup)) {
                        Course.Corequisite corequisite = groupsRequiringCorequisite.get(prerequisiteGroup);
                        this.corequisiteCourseId = corequisite.corequisiteId;
                        this.corequisiteCourseName = corequisite.corequisiteName;
                    }
                }
            }
        }
    }

    public class CourseEligibilityException extends Exception {

    }
}