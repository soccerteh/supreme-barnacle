public with sharing class Course {
    @AuraEnabled
    public Id id {get; set;}
    @AuraEnabled
    public String name {get; set;}
    @AuraEnabled
    public String description {get; set;}
    @AuraEnabled
    public Integer creditHours {get; set;}
    @AuraEnabled 
    public String subject {get; set;}
    @AuraEnabled
    public String prerequisiteDescription {get; set;}
    @AuraEnabled
    public String corequisiteDescription {get; set;}
    public Boolean hasPrerequisites;
    public Boolean hasCorequisites;
    public Map<String, List<Prerequisite>> prerequisites;
    public Set<String> corequisiteGroups;
    public List<Corequisite> corequisites;

    public String highestGroupLetter;

    public Course() {
        this.prerequisites = new Map<String, List<Prerequisite>>();
        this.corequisites = new List<Corequisite>();
    }
    
    public Course(
        Course__c vertoCourse
    ) {
        this.id = vertoCourse.Id;
        this.name = vertoCourse.Name;
        this.description = vertoCourse.Description__c;
        this.subject = vertoCourse.Subject__c;
        this.hasPrerequisites = vertoCourse.hasPrerequisites__c;
        this.prerequisites = new Map<String, List<Prerequisite>>();
        this.corequisites = new List<Corequisite>();
        this.constructPrequisiteMatrix(vertoCourse.Course_Prerequisites__r);
    }



    private void constructPrequisiteMatrix(List<Course_Prerequisite__c> prerequisites) {
        Set<String> corequisiteGroups = new Set<String>();
        List<Prerequisite> temp;
        Map<String, Prerequisite[]> prerequisiteMatrix = new Map<String, Prerequisite[]>();
        //iterate over prerequisites to put them in a matrix for evaluating AND/OR logic effectively.
        for (Course_Prerequisite__c prerequisite :prerequisites) {
            if (prerequisite.Type__c == 'Corequisite') {
                this.corequisites.add(new Corequisite(prerequisite));
                continue;
            } 
            temp = prerequisiteMatrix.get(prerequisite.Group__c);
            if (temp == null) {
                prerequisiteMatrix.put(prerequisite.Group__c, temp = new List<Prerequisite>());
            } 
            temp.add(new Prerequisite(
                prerequisite
            ));
        }
        this.hasCorequisites = !this.corequisites.isEmpty();      
        this.corequisiteGroups = corequisiteGroups;
        this.prerequisites = prerequisiteMatrix;
    }


    public class Prerequisite {
        private Id prerequisiteId;
        private String condition;
        private String prereqGroup;

        /* An Explanation of Prerequisite Groups:
         * Because prerequesite requirements are complex rules, these rules are segmented into a series of conditions of AND/OR logic.
         * Some courses can have prerequesite requirements that are satieted by many conditions being met (AND statements) or conversely,
         * a course can have many different requirements that allow for eligibility as long as any of the requirements are met (OR statements).
         * Additionally, these can become further complex, combining a mix of the two aforementioned types (AND and/or OR statements).
         * To define this in the database schema and for evaluation rules, there is a field called Group__c on the Course_Prerequisite__c object
         * that is used to allow these rules to be set effectively. The logic for how groups are to be handled is as follows:
         * 
         *  1. ANY conditions that share the same group identifier are considered to be corequiried.
         *      Every condition must be met for the group to be considered satieted.
         *  2. If ANY group is satieted, the course is considered eligible for enrollment.
         *      Zero to many groups can be satieted, some with additional requirements.
         * 
         * The instructions of the Course class is to facilitate the evaluation of the course for eligibility of enrollment by creating a matrix of the conditions
         * with conditions being organized into their respective grouping as arrays, with their Group identifier as the key of the map. 
         * Each array is then evaluated for all true values of condition(s) being met. If at least one array is all true values, the course
         * is deemed eligible for enrollment. Whether or not the only groups that were satieted have any additional requirements or corequisites may
         * be also passed along to whatever resource requested eligibility for enrollment. 
        */


        public Prerequisite(Course_Prerequisite__c prerequisite) {
            this.condition = prerequisite.Condition__c;
        }

        public Boolean isConditionMet(Set<String> answers) {
            if (
                this.condition == null
            ) {
                return true;
            }
            return answers?.contains(this.condition);
        }
    }

    public class Corequisite {
        public Id courseId;
        public Id corequisiteId;
        public String corequisiteName;
        public Boolean strictRequirement;
        public String corequisiteGroup;
        

        public Corequisite(Course_Prerequisite__c corequisite) {
            this.courseId = corequisite.Course__c;
            this.corequisiteId = corequisite.Corequisite_Course__c;
            this.corequisiteName = corequisite.Corequisite_Course__r.Name;
            this.strictRequirement = (corequisite.Group__c == null && corequisite.Condition__c == null);
            if (!this.strictRequirement) {
                corequisiteGroup = corequisite.Group__c;
            }
        }

        public Course_Prerequisite__c establishStrictRequirement() {
            if (this.corequisiteGroup != null) {
                throw new IllegalArgumentException('Corequisite must not be part of a group.');
            }
            return new Course_Prerequisite__c(
                Course__c = this.corequisiteId,
                Corequisite_Course__c = this.courseId
            );
        }
    }

    
}