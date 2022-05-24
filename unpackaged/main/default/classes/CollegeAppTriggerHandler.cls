public without sharing class CollegeAppTriggerHandler {

    public static void doAfterInsert(List<College_Application__c> collegeApps) {
        shareWithPartner(collegeApps);
    }

    public static void doAfterUpdate(List<College_Application__c> collegeApps, Map<Id, College_Application__c> oldcollegeApps) {
        List<College_Application__c> recordsToShare = new List<College_Application__c>();
        for (College_Application__c application :collegeApps) {
            if (application.Application_Status__c == 'Sent To University' && application.Application_Status__c != oldcollegeApps.get(application.Id).Application_Status__c) {
                recordsToShare.add(application);
            }
        }
        shareWithPartner(recordsToShare);
    }
    
    public static void shareWithPartner(List<College_Application__c> collegeApps) {
        
        List<Counseling__Share> counselingShares = new List<Counseling__Share>();
        List<AccountShare> accountShares = new List<AccountShare>();
        Set<Id> universityIds = new Set<Id>();
        Map<Id, List<User>> universityUsers = new Map<Id, List<User>>();
        
        for (College_Application__c foundCollegeApps : collegeApps) {
            universityIds.add(foundCollegeApps.University__c);     
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

        for(College_Application__c collegeApp : collegeApps){
            
            // College Application has to be submit to university
            if(collegeApp.Application_Status__c != 'Sent To University'){
                continue;
            }
            String counselingToShare = collegeApp.Counseling__c;
            String universityToShareTo = collegeApp.University__c;
            
            
            // check if account has users
            if(!universityUsers.containsKey(collegeApp.University__c)){
                continue;
            }
            
            for (User foundUniversityUser : universityUsers.get(collegeApp.University__c)) {

                counselingShares.add(new Counseling__Share(
                    ParentId = counselingToShare, 
                    AccessLevel = 'Edit',
                    UserOrGroupId = foundUniversityUser.Id
                ));
                    
                accountShares.add(new AccountShare(
                    AccountId = universityToShareTo,
                    AccountAccessLevel = 'Edit',
                    OpportunityAccessLevel = 'Edit',
                    UserOrGroupId = foundUniversityUser.Id
                ));

            }
        }
              

        if (!counselingShares.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(counselingShares, false);
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