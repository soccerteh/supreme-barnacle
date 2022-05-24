@IsTest
public with sharing class CommunityUserServicesTests {

    @TestSetup
    static void makeData(){
        TriggerHandler.suppressHandler('AccountTriggerHandler');
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
        TriggerHandler.clearSuppressedHandlers();
    }

    @IsTest
    static void testCreateCommunityUsersWithNullContact() {
        Test.startTest();
        Id communityProfileId = getCommunityUserProfile();
        CommunityUserServices.createCommunityUsersFromContacts(
            communityProfileId, 
            new List<Contact>{new Contact()}
        );
        Test.stopTest();
        System.assertEquals(
            0,
            [SELECT Id FROM User WHERE ProfileId = :communityProfileId AND CreatedDate = TODAY].size(),
            'Expected no users to be created.'
        );
    }

    @IsTest
    static void testCreateCommunityUsersWithValidContact() {
        Test.startTest();
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Email, Persona__c, RecordTypeId 
            FROM Contact 
            LIMIT 1
        ];
        Id communityProfileId = getCommunityUserProfile();
        CommunityUserServices.createCommunityUsersFromContacts(
            communityProfileId, 
            contacts
        );
        Test.stopTest();
        System.assertEquals(
            contacts.size(),
            [SELECT Id FROM User WHERE ProfileId = :communityProfileId AND CreatedDate = TODAY].size(),
            'Expected the number of contacts to match the number of users created.'
        );
    }

    @IsTest
    static void testCreateCommunityUsersWithExistingUsername() {
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Email, Persona__c, 
            AccountId, RecordTypeId 
            FROM Contact 
            LIMIT 1
        ];
        Id communityProfileId = getCommunityUserProfile();
        //Create a user record already reserving the username.
        Contact secondContact = new Contact(
            FirstName = 'Second',
            LastName = 'Contact',
            AccountId = contacts[0].AccountId,
            Email = 'Test@Test.com',
            Persona__c = 'US High School Student'
        );
        insert secondContact;
        insert new User(
            FirstName = secondContact.FirstName,
            LastName = secondContact.LastName,
            Email = secondContact.Email,
            ContactId = secondContact.Id,
            ProfileId = communityProfileId,
            Username = contacts[0].Email,
            Alias = (secondContact.FirstName.left(1) + secondContact.LastName).left(8),
            CommunityNickname = (secondContact.FirstName + ' ' + secondContact.LastName).left(40),
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        String expectedUsername = contacts[0].email + '.verto';
        Test.startTest();
        CommunityUserServices.createCommunityUsersFromContacts(
            communityProfileId, 
            contacts
        );
        Test.stopTest();
        System.debug([SELECT Id, Name, ProfileId FROM User WHERE CreatedDate = TODAY]);
        System.assertEquals(
            1,
            [SELECT Id FROM User WHERE UserType != 'Standard' AND Username = :contacts[0].email].size(),
            'Expected one user to be created without \'.verto\' appended to the username.'
        );
        System.assertEquals(
            1,
            [SELECT Id FROM User WHERE UserType != 'Standard' AND Username = :expectedUsername].size(),
            'Expected one user to be created with \'.verto\' appended to the username.'
        );
    }

    @IsTest
    static void testCreateCommunityUserWithInvalidProfileId() {
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Email, Persona__c, RecordTypeId 
            FROM Contact 
            LIMIT 1
        ];
        //set the communityProfileId to a non-profile Id.
        Id communityProfileId = contacts[0].Id;
        Test.startTest();
        try {
            CommunityUserServices.createCommunityUsersFromContacts(
                communityProfileId, 
                contacts
            ); 
        } catch (CommunityUserServices.CommunityUserProvisionerException ex) {
            System.assert(
                ex.getMessage().contains('Id must be a valid profile Id'),
                'Expected exception message about invalid Id sObject Type.'    
            );
        }
        Test.stopTest();
        System.debug([SELECT Id, Name, UserName, UserType FROM User WHERE CreatedDate = TODAY]);
        System.assertEquals(
            0,
            [SELECT Id FROM User WHERE ProfileId = :communityProfileId AND CreatedDate = TODAY].size(),
            'Expected no users to be created.'
        );
    }

    private static Id getCommunityUserProfile() {
        return [
            SELECT Id
            FROM Profile
            WHERE Name = 'Student Portal User'
            LIMIT 1
        ].Id;
    }

}