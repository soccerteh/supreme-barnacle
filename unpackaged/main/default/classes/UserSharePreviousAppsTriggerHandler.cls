public class UserSharePreviousAppsTriggerHandler {

    public static void doAfterInsert(List<User> users) {
        shareWithPartner(users);
    }
    
    public static void shareWithPartner(List<User> users) {
        Id partnerPortalProfile = [SELECT Id FROM Profile WHERE Name = 'Partner Community User - Verto' LIMIT 1].Id;
        List<ID> userIdList = new List<ID>();
        for (User myUser : users) {
            if (myUser.ProfileId == partnerPortalProfile && myUser.isActive) { 
                userIdList.add(myUser.Id);
            }
        }
        shareRecords(userIdList);
    }
    @future
    public static void shareRecords(List<ID> recordIds) {
        for (ID myUser : recordIds) {
            User triggerUser = [SELECT Id, UserRoleId FROM User WHERE Id = :myUser LIMIT 1];
            User relatedUser = new User();
            List<User> relatedUsers = [SELECT Id, UserRoleId, isActive FROM User WHERE Id != :myUser AND UserRoleId = :triggerUser.UserRoleId AND isActive = true ORDER BY CreatedDate DESC];
            if (relatedUsers.isEmpty()) {
                continue;
            } else {
                relatedUser = relatedUsers[0];
            }
            /* User relatedUser = [SELECT Id, UserRoleId, isActive FROM User WHERE Id != :myUser AND UserRoleId = :triggerUser.UserRoleId AND isActive = true LIMIT 1];
            
            if (relatedUser == null) {
                continue;
            }
             */
            List<Counseling__Share> counselingShares = [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId FROM Counseling__Share WHERE UserOrGroupId = :relatedUser.Id];
            List<AccountShare> accountShares = [SELECT AccountAccessLevel, AccountId, CaseAccessLevel, ContactAccessLevel, OpportunityAccessLevel, RowCause, UserOrGroupId FROM AccountShare WHERE UserOrGroupId = :relatedUser.Id];
            List<Application__Share> applicationShares = [SELECT Id, AccessLevel, ParentId, UserOrGroupId FROM Application__Share WHERE UserOrGroupId = :relatedUser.Id];

            
            List<Counseling__Share> counselingSharesToInsert = new List<Counseling__Share>();
            List<AccountShare> accountSharesToInsert = new List<AccountShare>();
            List<Application__Share> applicationSharesToInsert = new List<Application__Share>();
            
            for (Counseling__Share newCounselingShares : counselingShares) {
                counselingSharesToInsert.add(new Counseling__Share(
                    ParentId = newCounselingShares.ParentId, 
                    AccessLevel = 'Edit', 
                    UserOrGroupId = myUser
                ));
            }
            
            for (AccountShare newAccountShares : accountShares) {
                accountSharesToInsert.add(new AccountShare(
                    AccountId = newAccountShares.AccountId,
                    AccountAccessLevel = 'Edit',
                    OpportunityAccessLevel = 'Edit',
                    UserOrGroupId = myUser
                ));
            }

            for (Application__Share newApplicationShares : applicationShares) {
                applicationSharesToInsert.add(new Application__Share(
                    ParentId = newApplicationShares.ParentId,
                    AccessLevel = newApplicationShares.AccessLevel,
                    UserOrGroupId = myUser
                ));
            }
            
            if (!counselingSharesToInsert.isEmpty()) {
                Database.insert(counselingSharesToInsert, false);
            }
            if (!accountSharesToInsert.isEmpty()) {
                Database.insert(accountSharesToInsert, false);
            }

            if (!applicationSharesToInsert.isEmpty()) {
                Database.insert(applicationSharesToInsert, false);
            }
        }
    }
}