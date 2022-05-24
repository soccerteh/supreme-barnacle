@isTest(SeeAllData=false)
public class channelAppTriggerHandlerTestClass{

    @isTest
    static void ChannelAppTriggerHandler(){
        Account acc = new Account();
        acc.recordtypeid = '0123h0000015Nm4AAE';
        acc.First_Name__c = 'firstNametestData';
        acc.Last_Name__c = 'lastName';
        acc.Name = 'name';
        
        insert acc;
        Account accId = [select id from account where First_Name__c = 'firstNametestData' limit 1];
        
        
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
        
        Application__c channelApp = new Application__c();
        channelApp.recordtypeid = '0123h000000VHZCAA4';
        channelApp.name = 'appNametestData';
        channelApp.Account__c= accId.id;
        channelApp.University__c = accIdUni.id;
        channelApp.Applicant_Phone__c = 'phonetestnumber';
        channelApp.Applicant_First_Name__c = 'first';
        channelApp.Applicant_Last_Name__c = 'last';
        channelApp.Applicant_Email__c = 'email@gmail.com';
        channelApp.Application_Status__c = 'Deposit Received';
        channelApp.Street__c = 'street';
        channelApp.City__c = 'city';
        channelApp.State_Province__c = 'Virginia';
        channelApp.Country__c = 'United States';
        channelApp.Postal_Code__c = '112';

        insert channelApp;

        channelApp.Applicant_Phone__c = 'newPhone';
        update channelApp;
        
    }
}