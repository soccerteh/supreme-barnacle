@isTest(SeeAllData=false)
public class CollegeAppTriggerHandlerTestClass{

    @isTest
    static void CollegeAppTriggerHandler(){
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
        /* cApp.Application_Status__c = 'Sent To University'; */
        
        insert cApp;

        cApp.Application_Status__c = 'Sent To University';
        update cApp;
        
    }
}