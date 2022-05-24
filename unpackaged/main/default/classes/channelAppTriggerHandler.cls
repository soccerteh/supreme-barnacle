public without sharing class channelAppTriggerHandler{

    public static void doAfterInsert(List<Application__c> channelApps) {
        shareWithPartner(channelApps);
    }
    public static void doAfterUpdate(List<Application__c> channelApps, Map<Id, Application__c> oldchannelApps) {
        List<Application__c> recordsToShare = new List<Application__c>();
        for (Application__c application :channelApps) {
            //recommended to add a business logic gate to this next statement. 
            recordsToShare.add(application);
        }
        shareWithPartner(recordsToShare);
    }
    
    public static void shareWithPartner(List<Application__c> channelApps) {
        
        List<Application__Share> applicationShares = new List<Application__Share>();
        List<AccountShare> accountShares = new List<AccountShare>();
        Set<Id> universityIds = new Set<Id>();
        Map<Id, List<User>> universityUsers = new Map<Id, List<User>>();
        
        for (Application__c foundchannelApps : channelApps) {
            universityIds.add(foundchannelApps.University__c);     
        }

        Map<Id, Contact> universityContacts = new Map<Id, Contact>([
            SELECT Id, AccountId
            FROM Contact
            WHERE AccountId IN :universityIds
            AND Account.isPartner = true
        ]);

        for (User contactUser :[SELECT Id, ContactId FROM User WHERE ContactId IN :universityContacts.keySet() AND IsActive = true]) {
            if (universityUsers.containsKey(universityContacts.get(contactUser.ContactId).AccountId)) {
                universityUsers.get(universityContacts.get(contactUser.ContactId).AccountId).add(contactUser);
            } else {
                universityUsers.put(universityContacts.get(contactUser.ContactId).AccountId, new List<User>{contactUser});
            }
        }

        for(Application__c channelApp : channelApps){
            
            // channel Application has to be submit to university
            if(channelApp.RecordTypeId != Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Channel Enrollment').getRecordTypeId()){
                continue;
            }
            String applicationToShare = channelApp.Id;
            String universityToShareTo = channelApp.University__c;
            String applicantAccountToShareTo = channelApp.Account__c;
            
            
            // check if account has users
            if(!universityUsers.containsKey(channelApp.University__c)){
                continue;
            }
            
            for (User foundUniversityUser : universityUsers.get(channelApp.University__c)) {

                applicationShares.add(new Application__Share(
                    ParentId = applicationToShare, 
                    AccessLevel = 'Edit',
                    UserOrGroupId = foundUniversityUser.Id
                ));
                    
                accountShares.add(new AccountShare(
                    AccountId = universityToShareTo,
                    AccountAccessLevel = 'Edit',
                    OpportunityAccessLevel = 'Edit',
                    UserOrGroupId = foundUniversityUser.Id
                ));
                
                accountShares.add(new AccountShare(
                    AccountId = applicantAccountToShareTo,
                    AccountAccessLevel = 'Edit',
                    OpportunityAccessLevel = 'Edit',
                    UserOrGroupId = foundUniversityUser.Id
                ));

            }
        }
              

        if (!applicationShares.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(applicationShares, false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    System.debug(result.getErrors());
                }
            }
        }
        if (!accountShares.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(accountShares, false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    System.debug(result.getErrors());
                }
            }
        }
        
    }
}