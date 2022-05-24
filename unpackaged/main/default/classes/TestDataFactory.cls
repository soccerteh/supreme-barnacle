@IsTest
public with sharing class TestDataFactory {
    
    public static void insertMockCommunityUser() {
        Id communityProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Student Portal User'
            LIMIT 1
        ].Id;
        Account communityUserAccount = new Account(
            Name = 'Community User',
            First_Name__c = 'Community',
            Last_Name__c = 'User',
            Email__c = 'CommunityUser@Test.org',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId()
        );
        insert communityUserAccount;
        Contact communityUserContact = new Contact(
            AccountId = communityUserAccount.Id,
            FirstName = 'Community',
            LastName = 'User',
            Email = 'CommunityUser@Test.org',
            Persona__c = 'US High School Student',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId()
        );
        insert communityUserContact;
        insert new User(
            FirstName = 'Commmunity',
            LastName = 'User',
            Email = 'CommunityUser@Test.org',
            ContactId = communityUserContact.Id,
            ProfileId = communityProfileId,
            Username = 'CommunityUser@Test.org',
            Alias = 'CommUser',
            CommunityNickname = 'Community User',
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
    }

    /* public static void insertMockPartnerUser() {

    } */

    public static void insertOpportunityAndEnrollmentForAccount(Account account) {
        if ([SELECT Id FROM Program__c].isEmpty()) {
            insertMockPrograms();
        }
        Opportunity firstSemesterOpportunity = new Opportunity(
            Name = account.Name + ' - ' + System.today().addMonths(-3),
            AccountId = account.Id,
            StageName = 'Qualified',
            CloseDate = System.today().addMonths(-3),
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Traditional Enrollment').getRecordTypeId()
        );
        insert firstSemesterOpportunity;
        insert new Enrollment_Record__c(
            Student_Account__c = account.Id,
            Opportunity__c = firstSemesterOpportunity.Id,
            Program__c = [SELECT Id FROM Program__c LIMIT 1].Id,
            Owner__c = System.Label.User_GeneralSalesforceAdmin,
            RecordTypeId = Schema.sObjectType.Enrollment_Record__c.getRecordTypeInfosByName().get('First Semester').getRecordTypeId()
        );
    }

    public static void insertMockCoursesWithPrerequisites() {
        Course__c sampleCourse = new Course__c(
            Name = 'Sample Course',
            Description__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            Subject__c = 'Mathematics',
            Status__c = 'Active'
        );
        Course__c sampleCorequisiteCourse = new Course__c(
            Name = 'Sample Corequisite Course',
            Subject__c = 'Mathematics',
            Status__c = 'Active'
        );
        insert new List<Course__c>{sampleCourse, sampleCorequisiteCourse};
        List<Course_Prerequisite__c> prerequisites = new List<Course_Prerequisite__c>();
        prerequisites.add( new Course_Prerequisite__c(
            Course__c = sampleCourse.Id,
            Question__c = 'What is the students highest level of math completed with a C or greater?',
            Condition__c = 'Algebra II',
            Group__c = 'A',
            Type__c = 'Prerequisite'
        ));
        prerequisites.add( new Course_Prerequisite__c(
            Course__c = sampleCourse.Id,
            Question__c = 'What is the students highest level of math completed with a C or greater?',
            Condition__c = 'Geometry',
            Group__c = 'B',
            Type__c = 'Prerequisite'
        ));
        prerequisites.add( new Course_Prerequisite__c(
            Course__c = sampleCourse.Id,
            Type__c = 'Corequisite',
            Corequisite_Course__c = sampleCorequisiteCourse.Id
        ));
        insert prerequisites;
    }

    public static void insertMockPrograms() {
        Semester__c semester = new Semester__c(
            Name = 'Fall ' + System.today().year(),
            Delivery_Method__c = 'Abroad',
            Semester_Start_Date__c = System.today().addDays(10),
            Semester_End_Date__c = System.today().addDays(10).addMonths(3),
            Deposit_Due_Date__c = System.today().addDays(10).addMonths(3),
            Tuition_Due_Date__c = System.today().addDays(-10).addMonths(3)
        );
        insert semester;
        List<Location__c> locations = new List<Location__c>();
        locations.add(new Location__c(
            Name = 'England',
            Status__c = 'Actively Enrolling'
        ));
        locations.add(new Location__c(
            Name = 'Costa Rica',
            Status__c = 'Actively Enrolling'
        ));
        locations.add(new Location__c(
        	Name = 'Buenos Aires',
            Status__c = 'Actively Enrolling'
        ));
        insert locations;
        List<Program__c> programs = new List<Program__c>();
        for (Location__c location :locations) {
            programs.add(new Program__c(
                Name = location.Name + ' - ' + semester.Name,
                Semester__c = semester.Id,
                Location__c = location.Id,
                Status__c = 'Active',
                Program_Start_Date__c = System.today(),
                Program_End_Date__c = System.today().addMonths(3)
            ));
        }
        insert programs;
    }

}