global class CBS_CommunityRegistrationHandler implements Auth.RegistrationHandler {

    private static final String DEFAULT_COMMUNITY_USER_ACCOUNT = CBS_Util.getCustomSettingValue('DefaultCommunityAccount');
    private static final String DEFAULT_TZSID = [SELECT TimeZoneSidKey FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1].TimeZoneSidKey;
    private static final String DEFAULT_COMMUNITY_USER_PROFILE = CBS_Util.getCustomSettingValue('DefaultCommunityProfile');
    private static final String DEFAULT_EMAIL_ENCODING_KEY = CBS_Util.getCustomSettingValue('DefaultEncoding');

    global Boolean canCreateUser(Auth.UserData data) {
        return data != null && data.email != null && data.lastName != null && data.firstName != null;
    }

    global User createUser(Id portalId, Auth.UserData data) {
        if (!canCreateUser(data) || !data.attributeMap.containsKey('sfdc_networkid')) {
            return null;
        }

        String contactId;

        List<Contact> existingContacts = [SELECT Id, Email FROM Contact WHERE Email = :data.email];

        if (!existingContacts.isEmpty()) {
            Contact existingContact = existingContacts[0];
            contactId = existingContact.Id;
            List<User> existingUsers = [SELECT Id FROM User WHERE ContactId = :contactId];
            if (existingUsers.size() == 1) {
                return existingUsers[0];
            }
        } else {
            contactId = createContact(data);
        }

        Profile communityProfile = [SELECT Id FROM profile WHERE name = :DEFAULT_COMMUNITY_USER_PROFILE];
        User communityUser = createUser(data, communityProfile);
        communityUser.ContactId = contactId;

        return communityUser;
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        User communityUser = new User(Id = userId);
        communityUser.Email = data.email;
        communityUser.FirstName = data.firstName;
        communityUser.LastName = data.lastName;
        update(communityUser);
    }

    private String createContact(Auth.UserData data) {
        Contact communityContact = new Contact();
        communityContact.Email = data.email;
        communityContact.FirstName = data.firstName;
        communityContact.LastName = data.lastName;
        communityContact.AccountId = getCommunityUserAccountId(data.email);

        insert communityContact;

        return communityContact.Id;
    }

    private String getCommunityUserAccountId(String dataEmail) {
        String afterAtString = dataEmail.substring(dataEmail.indexOf('@') + 1);
        afterAtString = '%' + afterAtString;

        List<Account> accountsFromWebsite = [SELECT Id, Name, IsPartner FROM Account WHERE Website LIKE :afterAtString];
        List<Account> accountsFromContacts = [SELECT Id, Name, IsPartner FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Email LIKE :afterAtString)];

        Account acc;

        if (!accountsFromWebsite.isEmpty() && accountsFromWebsite[0].IsPartner) {
            acc = accountsFromWebsite[0];
        } else if (!accountsFromContacts.isEmpty() && accountsFromContacts[0].IsPartner) {
            acc = accountsFromContacts[0];
        } else {
            acc = [SELECT Id FROM Account WHERE Name = :DEFAULT_COMMUNITY_USER_ACCOUNT];
        }

        return acc.Id;
    }

    private User createUser(Auth.UserData data, Profile communityProfile) {
        User communityUser = new User();
        communityUser.Username = data.email;
        communityUser.Email = data.email;
        communityUser.FirstName = data.firstName;
        communityUser.LastName = data.lastName;
        String firstNameChar = String.fromCharArray(new List<Integer> {data.firstName.charAt(0)});
        String alias = firstNameChar + data.lastName;
        if (alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        communityUser.Alias = alias;

        communityUser.LanguageLocaleKey = UserInfo.getLanguage();
        communityUser.LocaleSidKey = UserInfo.getLocale();
        communityUser.EmailEncodingKey = DEFAULT_EMAIL_ENCODING_KEY;
        communityUser.TimeZoneSidKey = DEFAULT_TZSID;
        communityUser.ProfileId = communityProfile.Id;

        return communityUser;
    }
}