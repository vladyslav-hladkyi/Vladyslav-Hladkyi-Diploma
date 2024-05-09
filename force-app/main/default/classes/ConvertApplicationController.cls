public with sharing class ConvertApplicationController {
    @AuraEnabled
    public static Id createContact(Id recordId){
        Application__c application = [
            SELECT Id, Birthdate__c, Email__c, First_Name__c, Last_Name__c, Phone__c, Requested_Support__c
            FROM Application__c 
            WHERE Id =: recordId
        ];

        Contact newContact = new Contact(
            LastName = application.Last_Name__c,
            FirstName = application.First_Name__c,
            Email = application.Email__c,
            Birthdate = application.Birthdate__c,
            Phone = application.Phone__c,
            Requested_Support__c = application.Requested_Support__c,
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Client').getRecordTypeId()
        );

        insert newContact;
        update new Application__c(Id = application.Id, Contact__c = newContact.Id);

        return newContact.Id;
    }
}