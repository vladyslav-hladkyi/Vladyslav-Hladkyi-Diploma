@IsTest
public with sharing class EmailSenderControllerTest {
    @TestSetup
    static void makeData(){
        Account acc = new Account(Name='Test Account');
        insert acc;

        List<Contact> contacts = new List<Contact>{
            new Contact(LastName='Test Contact 1', Email='test@example.com', AccountId=acc.Id),
            new Contact(LastName='Test Contact 2', Email='test@example.com', AccountId=acc.Id),
            new Contact(LastName='Test Contact 3', AccountId=acc.Id)
        };
        insert contacts;

        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(Name='Test opportunity 1', AccountId=acc.Id, ContactId=contacts[0].Id, StageName='Prospecting', CloseDate=Date.newInstance(2023, 9, 23)),
            new Opportunity(Name='Test opportunity 2', AccountId=acc.Id, ContactId=contacts[1].Id, StageName='Closed Won', CloseDate=Date.newInstance(2023, 9, 22))
        };
        insert opportunities;

        List<Case> cases = new List<Case>{
            new Case(AccountId=acc.Id, ContactId=contacts[0].Id, Origin='Phone'),
            new Case(AccountId=acc.Id, ContactId=contacts[1].Id, Origin='Phone')
        };
        insert cases;
    }

    @IsTest
    static void getRelatedRecipientsAsDirectChildren(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        EmailSenderController.JSONDirectWrapper jsonNames = new EmailSenderController.JSONDirectWrapper();
        jsonNames.areContactsChildren = true;
        jsonNames.fromContactToParent = 'AccountId';
        jsonNames.fromCurrentToParent = '';

        Test.startTest();
        List<EmailSenderController.RecipientWrapper> recipitient =  EmailSenderController.getRelatedRecipients(acc.Id, JSON.serialize(jsonNames), false,  'Email != \'\'', '', 'Email');
        Test.stopTest();

        Assert.areEqual(2, recipitient.size());
        Assert.areEqual('test@example.com', recipitient[0].email);
    }

    @IsTest
    static void getRelatedRecipientsAsJunctionChildren(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        EmailSenderController.JSONJunctionWrapper jsonNames = new EmailSenderController.JSONJunctionWrapper();
        jsonNames.areContactsChildren = true;
        jsonNames.fromCurrentToParent = '';
        jsonNames.junctionName = 'Case';
        jsonNames.fromJunctionToParent = 'AccountId';
        jsonNames.fromJunctionToContact = 'ContactId';

        Test.startTest();
        List<EmailSenderController.RecipientWrapper> recipitient =  EmailSenderController.getRelatedRecipients(acc.Id, JSON.serialize(jsonNames), true,  'Email != \'\'', 'Origin=\'Phone\'', 'Email');
        Test.stopTest();

        Assert.areEqual(2, recipitient.size());
    }

    @IsTest
    static void getRelatedRecipientsAsDirectParentsChildren(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE StageName='Prospecting' LIMIT 1];
        EmailSenderController.JSONDirectWrapper jsonNames = new EmailSenderController.JSONDirectWrapper();
        jsonNames.areContactsChildren = false;
        jsonNames.fromContactToParent = 'AccountId';
        jsonNames.fromCurrentToParent = 'AccountId';

        Test.startTest();
        List<EmailSenderController.RecipientWrapper> recipitient =  EmailSenderController.getRelatedRecipients(opp.Id, JSON.serialize(jsonNames), false,  'Email != \'\'', '', 'Email');
        Test.stopTest();

        Assert.areEqual(2, recipitient.size());
    }

    @IsTest
    static void getRelatedRecipientsAsJunctionParentsChildren(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE StageName='Prospecting' LIMIT 1];
        EmailSenderController.JSONJunctionWrapper jsonNames = new EmailSenderController.JSONJunctionWrapper();
        jsonNames.areContactsChildren = false;
        jsonNames.fromCurrentToParent = 'AccountId';
        jsonNames.junctionName = 'Case';
        jsonNames.fromJunctionToParent = 'AccountId';
        jsonNames.fromJunctionToContact = 'ContactId';

        Test.startTest();
        List<EmailSenderController.RecipientWrapper> recipitient =  EmailSenderController.getRelatedRecipients(opp.Id, JSON.serialize(jsonNames), true,  'Email != \'\'', 'Origin=\'Phone\'', 'Email');
        Test.stopTest();

        Assert.areEqual(2, recipitient.size());
    }

    @IsTest
    static void getSearchedRecipientsTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<Id,Contact> contacts = new Map<Id,Contact>([SELECT Id FROM Contact]);

        Test.setFixedSearchResults(new List<Id>(contacts.keySet()));
        Test.startTest();
        List<EmailSenderController.RecipientWrapper> recipitient =  EmailSenderController.getSearchedRecipients(acc.Id, 'Tes', '', 'Email');
        Test.stopTest();

        Assert.areEqual(3, recipitient.size());
    }

    @IsTest
    static void sendEmailsToRecipientsTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<Id,Contact> contacts = new Map<Id,Contact>([SELECT Id FROM Contact LIMIT 1]);

        Test.startTest();
        EmailSenderController.sendEmailsToRecipients(acc.Id, 'Email Body', 'Email Subject', new List<String>{'test@gmail.com'}, new List<Id>(contacts.keySet()), 'cc', 'none');
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        Assert.areEqual(1, invocations);
    }

}