global class CBS_CommunityRegistrationHandler implements Auth.RegistrationHandler {
    global User createUser(Id portalId, Auth.UserData data) {
        if (data.attributeMap.containsKey('sfdc_networkid')) {
            Integer atPosition = data.email.indexOf('@');
            Integer dotPosition = data.email.indexOf('.', atPosition);
            String betweenAtAndDot = data.email.substring(atPosition + 1, dotPosition);

            String afterAtString = data.email.substring(atPosition + 1);
            afterAtString = '%' + afterAtString;

            System.debug('afterAtString' + afterAtString);

            List<Account> accountsFromWebsite = [SELECT Id, Name, IsPartner FROM Account WHERE Website LIKE :afterAtString];
            List<Account> accountsFromContacts = [SELECT Id, Name, IsPartner FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Email LIKE :afterAtString)];
            Account acc;
            if (!accountsFromWebsite.isEmpty() && accountsFromWebsite[0].IsPartner) {
                acc = accountsFromWebsite[0];
            } else if (!accountsFromContacts.isEmpty() && accountsFromContacts[0].IsCustomerPortal) {
                System.debug('Is from contacts');
                acc = accountsFromContacts[0];
                System.debug('Acc name = ' + acc.Name);
            } else {
                acc = [SELECT Id FROM Account WHERE Name = 'Community User Account'];
            }

            System.debug('ACCOUNT NAME AFTER CHECKS: ' + acc.Name);

            Contact communityContact = new Contact();
            communityContact.accountId = acc.Id;
            communityContact.email = data.email;
            communityContact.firstName = data.firstName;
            communityContact.lastName = data.lastName;
            insert(communityContact);

            //TODO: Customize the username and profile. Also check that the username doesn't already exist and
            //possibly ensure there are enough org licenses to create a user. Must be 80 characters or less.
            User communityUser = new User();
            Profile clientProfile = [SELECT Id FROM profile WHERE name = 'CBS_Client'];
            communityUser.username = data.email;
            communityUser.email = data.email;
            communityUser.lastName = data.lastName;
            communityUser.firstName = data.firstName;
            String alias = data.email;
            //Alias must be 8 characters or less
            if (alias.length() > 8) {
                alias = alias.substring(0, 8);
            }
            communityUser.alias = alias;
            communityUser.email = data.email;
            communityUser.lastName = data.lastName;
            communityUser.firstName = data.firstName;
            communityUser.languagelocalekey = 'en_US';
            communityUser.localesidkey = 'en_GB';
            communityUser.emailEncodingKey = 'UTF-8';
            communityUser.timeZoneSidKey = 'America/Los_Angeles';
            communityUser.profileId = clientProfile.Id;
            communityUser.contactId = communityContact.Id;
            return communityUser;
        }

        return null;
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        User communityUser = new User(id = userId);
        //TODO: Customize the username. Must be 80 characters or less.
        //u.username = data.username + '@myorg.com';
        communityUser.email = data.email;
        communityUser.lastName = data.lastName;
        communityUser.firstName = data.firstName;
        update(communityUser);
    }
}