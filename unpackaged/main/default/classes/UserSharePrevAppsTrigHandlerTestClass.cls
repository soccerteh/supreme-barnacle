@isTest(SeeAllData=false)
public class UserSharePrevAppsTrigHandlerTestClass{

    @isTest
    static void UserSharePreviousAppsTriggerHandler(){
        Account acc = new Account();
        acc.recordtypeid = System.Label.RT_Account_Partner;
        acc.First_Name__c = 'firstNametestData';
        acc.Last_Name__c = 'lastName';
        acc.Name = 'name';
        
        insert acc;
        Account accId = [select id from account where First_Name__c = 'firstNametestData' limit 1];
        
        Opportunity opp = new Opportunity();
        opp.recordtypeid = System.Label.RT_Opp_TraditionalEnrollment;
        //This can be set using: opp.RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Channel Enrollment').getRecordTypeId();
        opp.name = 'oppNametestData';
        opp.accountid = accId.id;
        opp.stagename = 'Qualified';
        opp.closedate = date.today();
        opp.phone_number__c = 'phonetestnumber';

        
        insert opp;
        
        Opportunity oppId = [select id from opportunity where phone_number__c = 'phonetestnumber' limit 1];
        
        Account accUni = new Account();
        accUni.recordtypeid = System.Label.RT_Account_Partner;
        accUni.First_Name__c = 'firstNametestDataUni';
        accUni.Last_Name__c = 'lastName';
        accUni.name = 'name';
        
        insert accUni;
        Account accIdUni = [select id from account where First_Name__c = 'firstNametestDataUni' limit 1];
        
        Contact uniContact = new Contact();
        uniContact.recordtypeid = System.Label.RT_Contact_University;
        uniContact.lastname = 'lastNametestDataUniContact';
        uniContact.accountid = accIdUni.id;
        uniContact.persona__c = 'Verto University Partner';
        
        insert uniContact;
        Contact partnerContact = [select id from contact where lastname = 'lastNametestDataUniContact' limit 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community User - Verto'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='123stan123darduser@123testorg.com');
        u.contactId = partnerContact.id;
        insert u;
        
        User partnerUser = [select id from user where UserName = '123stan123darduser@123testorg.com' limit 1];
        partnerContact.SF_ID18_User__c = partnerUser.id;
        update partnerContact;
        
        Counseling__c sampleCounselingRecord = new Counseling__c();
        insert sampleCounselingRecord;

        College_Application__c cApp = new College_Application__c();
        cApp.opportunity__c = oppId.id;
        cApp.university__c = accIdUni.id;
        cApp.Counseling__c = sampleCounselingRecord.Id;
        
        insert cApp;      
        
        Contact uniContact2 = new Contact();
        uniContact2.recordtypeid = System.Label.RT_Contact_University;
        uniContact2.lastname = 'lastNametestDataUniContact2';
        uniContact2.accountid = accIdUni.id;
        uniContact2.persona__c = 'Verto University Partner';

        Application__c studentApplication = new Application__c(
            Name = 'Sample Application__c - ' + System.today().addMonths(-3) + ' - Traditional',
            Applicant_First_Name__c = 'Sample',
            Applicant_Last_Name__c = 'Student',
            Applicant_Email__c = 'SampleStudent@VertoEducation.org',
            Sex__c = 'Male',
            Race_Ethnicity__c = 'I prefer not to say',
            GPA_Scale__c = '4.0',
            GPA__c = 4.0,
            Application_Status__c = 'Unqualified',
            Source__c = 'Website'
        );
        insert studentApplication;

        List<Counseling__Share> counselingShares = new List<Counseling__Share>();
        List<AccountShare> accountShares = new List<AccountShare>();
        
        String counselingToShare = cApp.Counseling__c;
        String universityToShareTo = cApp.University__c;
        
        counselingShares.add(new Counseling__Share(
            ParentId = counselingToShare, 
            AccessLevel = 'Edit', 
            UserOrGroupId = u.Id
        ));
                    
        accountShares.add(new AccountShare(
            AccountId = universityToShareTo,
            AccountAccessLevel = 'Edit',
            OpportunityAccessLevel = 'Edit',
            UserOrGroupId = u.Id
        ));

        insert new Application__Share(
            ParentId = studentApplication.Id,
            AccessLevel = 'Edit',
            UserOrGroupId = u.Id
        );
        
        if (!counselingShares.isEmpty()) {
            insert counselingShares;
        }
        if (!accountShares.isEmpty()) {
            insert accountShares;
        }

        insert uniContact2;
        Contact partnerContact2 = [select id from contact where lastname = 'lastNametestDataUniContact2' limit 1];
        Test.startTest();
        User u2 = new User(Alias = 'standa', Email='standarduset@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='1234stan123darduser@123testorg.com');
        u2.contactId = partnerContact2.id;
        insert u2;     
        Test.stopTest();
    }
}