public with sharing class CommunityUserServices {

     public static void createCommunityUsersFromContacts(
        Id communityProfileId,
        List<Contact> contacts
    ) {
        if (communityProfileId.getSobjectType() == Schema.Profile.SObjectType) {
            System.enqueueJob(new CommunityUserProvisioner(
                communityProfileId,
                contacts
            ));
        } else {
            throw new CommunityUserProvisionerException('Id must be a valid profile Id.');
        }
    }

    private with sharing class CommunityUserProvisioner implements Queueable {
        private Id communityProfileId;
        private List<Contact> contacts;

        public CommunityUserProvisioner(
            Id communityProfileId,
            List<Contact> contacts
        ) {
            this.contacts = new List<Contact>();
            this.communityProfileId = communityProfileId;
            for (Contact contact :contacts) {
                if (contact.email == null) {
                    /* throw new CommunityUserProvisionerException('Email cannot be null when provisioning.'); */
                    continue;
                }
                if (contact.firstName == null || contact.lastName == null) {
                    /* throw new CommunityUserProvisionerException('Full name required when provisioning.'); */
                    continue;
                }
                this.contacts.add(contact);
            }
        }

        /**
        * @description 
        * @author Nick Holly | 05-17-2022 
        * @param QueueableContext context 
        **/
        public void execute(QueueableContext context) {
            List<User> communityUsers = new List<User>();
            for (Contact contact :this.contacts) {
                communityUsers.add(getDefaultUser(
                    contact.Id,
                    this.communityProfileId,
                    contact.firstName,
                    contact.lastName,
                    contact.email,
                    contact.email
                ));
            }
            if (!communityUsers.isEmpty()) {
                //Attempt to insert all users
                System.debug(communityUsers);
                Database.insert(communityUsers, false);
                //Query any contacts that didn't have a user created initially.
                List<Contact> contactsWithoutUsers = [
                    SELECT Id, FirstName, LastName, Email
                    FROM Contact
                    WHERE Id NOT IN (
                        SELECT ContactId 
                        FROM User 
                        WHERE ContactId IN :(new Map<Id, Contact>(this.contacts)).keySet()
                        AND ProfileId = :this.communityProfileId
                    )
                    AND Id IN :(new Map<Id, Contact>(this.contacts)).keySet()
                    LIMIT :this.contacts.size()
                ];
                //If there are any contacts without users then attempt to create users with .verto appended on their username.
                if (!contactsWithoutUsers.isEmpty()) {
                    communityUsers.clear();
                    for (Contact contact :contactsWithoutUsers) { 
                        communityUsers.add(getDefaultUser(
                            contact.Id,
                            this.communityProfileId,
                            contact.firstName,
                            contact.lastName,
                            contact.email,
                            contact.email + '.verto'
                        ));
                    }
                    if (!communityUsers.isEmpty()) {
                        List<Database.SaveResult> results = Database.insert(communityUsers, false);
                        System.debug(results);
                    }
                }
            }
        }

        /**
        * @description Creates an instance of an User sObject with some default values set for TimeZone, Locale, etc.
        * @author Nick Holly | 05-17-2022 
        * @param Id contactId Id of the contact, used to relate the user to the contact record.
        * @param Id profileId The community profile to assign to the user.
        * @param String firstName The first name of the user.
        * @param String lastName The last name of the user.
        * @param String email The email of the user.
        * @param String username The username of the user.
        * @return User A User sObject with specialized personal information and default additional information.
        **/
        private User getDefaultUser(
            Id contactId,
            Id profileId,
            String firstName,
            String lastName,
            String email,
            String username
        ) {
            return new User(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                ContactId = contactId,
                ProfileId = profileId,
                Username = username,
                Alias = (firstName.left(1) + lastName).left(8),
                CommunityNickname = (firstName + ' ' + lastName).left(40),
                TimeZoneSidKey = 'America/Chicago',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
            );
        }
    }

    public class CommunityUserProvisionerException extends Exception {

    }
}