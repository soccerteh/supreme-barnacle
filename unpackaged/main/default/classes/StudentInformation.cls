public without sharing class StudentInformation {
    @AuraEnabled
    public Id academicProviderId {get;set;}
    @AuraEnabled
    public String academicProviderName {get;set;}
    @AuraEnabled
    public String accountId {get;set;}
    @AuraEnabled
    public Boolean channelStudent {get;set;}
    @AuraEnabled
    public Id channelSchoolId {get;set;}
    @AuraEnabled
    public String channelSchoolName {get;set;}
    @AuraEnabled
    public Id currentProgramId {get;set;}
    @AuraEnabled
    public String currentProgramName {get;set;}
    public Enrollment_Record__c enrollment;


    @AuraEnabled(cacheable=true)
    public static StudentInformation getStudentInfosForRunningUser() {
        return new StudentInformation()
            .getAllStudentInfosByAccountId(
                getRunningUserAccountId()
            );
    }

    public StudentInformation getAllStudentInfosByAccountId(Id accountId) {
        this.accountId = accountId;
        this.getCurrentEnrollmentRecord();
        return this;
    }
    
    @TestVisible
    private void getCurrentEnrollmentRecord() {
        if (this.accountId == null) {
            throw new StudentInformationException('Account Id is required');
        }
        //In future iteration, omit this constant and replace with dynamic query once program architecture can support it.
        final String semester = '%Fall 2022';
        List<Enrollment_Record__c> enrollments = [
            SELECT Id, Program__c, Program__r.Name, 
                School_of_Record__c, School_of_Record__r.Name,
                Course_Interest_Submitted__c, Course_Registration_Close_Date__c,
                Opportunity__r.RecordType.Name
            FROM Enrollment_Record__c
            WHERE Program__r.Name LIKE :semester
            AND Student_Account__c = :this.accountId
            AND Enrollment_Status__c = 'Enrolled'
            ORDER BY CreatedDate DESC
        ];
        if (!enrollments.isEmpty()) {
            this.enrollment = enrollments[0];
        }
        this.setStudentInfosFromCurrentEnrollmentRecord();
    }
    private void setStudentInfosFromCurrentEnrollmentRecord() {
        if (this.enrollment == null) {
            return;
        }
        this.academicProviderId = this.enrollment.School_of_Record__c;
        this.academicProviderName = this.enrollment.School_of_Record__r.Name;
        this.channelStudent = this.enrollment.Opportunity__r.RecordType.Name.contains('Channel');
        this.currentProgramId = this.enrollment.Program__c;
        this.currentProgramName = this.enrollment.Program__r.Name;
    }

    private static Id getRunningUserAccountId() {
        return [
            SELECT Contact.AccountId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ].Contact.AccountId;
    }

    public class StudentInformationException extends Exception {}

}