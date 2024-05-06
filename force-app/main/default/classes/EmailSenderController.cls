public with sharing class EmailSenderController {
    @AuraEnabled
    public static List<RecipientWrapper> getRelatedRecipients(Id recordId, String jsonNames, Boolean isJunctionUsed, String contactFilter, String junctionFilter,  String fieldToDisplay){
        try {
            List<Contact> contacts = new List<Contact>();
            List<RecipientWrapper> recipients = new List<RecipientWrapper>();

            if(isJunctionUsed){
                JSONJunctionWrapper jsonWrapper = (JSONJunctionWrapper)JSON.deserialize(jsonNames.replace('\u00A0',' '), JSONJunctionWrapper.class);
    
                if(jsonWrapper.areContactsChildren){
                    contacts = EmailSenderControllerService.queryJunctionContactsFromChildren(recordId, contactFilter, junctionFilter, fieldToDisplay, jsonWrapper);
                }
                else {
                    contacts = EmailSenderControllerService.queryJunctionContactsFromParent(recordId, contactFilter, junctionFilter, fieldToDisplay, jsonWrapper);
                }
            }
            else{
                JSONDirectWrapper jsonWrapper = (JSONDirectWrapper)JSON.deserialize(jsonNames.replace('\u00A0',' '), JSONDirectWrapper.class);

                if(jsonWrapper.areContactsChildren){
                    contacts = EmailSenderControllerService.queryDirectContactsFromChildren(recordId, contactFilter, fieldToDisplay, jsonWrapper);
                }
                else {
                    contacts = EmailSenderControllerService.queryDirectContactsFromParent(recordId, contactFilter, fieldToDisplay, jsonWrapper);
                }
            }
    
            for(Contact recipient : contacts){
                recipients.add(new RecipientWrapper(recipient, fieldToDisplay));
            }
    
            return recipients;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<RecipientWrapper> getSearchedRecipients(Id recordId, String searchText, String contactFilter, String fieldToDisplay){
        try {
            List<RecipientWrapper> recipients = new List<RecipientWrapper>();

            String queryString = 
                'FIND \'' +  searchText + '\' ' + 
                'IN ALL FIELDS RETURNING Contact(Id, Name, Email ' 
                + (fieldToDisplay == '' || fieldToDisplay == 'Email' ? '' : (', ' + fieldToDisplay) ) + ' ' +
                + (contactFilter == '' ? '' : (' WHERE ' + contactFilter) ) + ' LIMIT 100)';
            
            for(Contact recipient : (List<Contact>)Search.query(queryString)[0]){
                recipients.add(new RecipientWrapper(recipient, fieldToDisplay));
            }

            return recipients;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void sendEmailsToRecipients(Id recordId, String emailBody, String emailSubject, List<String> emailsToCopy, List<Id> recipientsIds, String typeOfEmailCopy, String orgWideAddressId){
        try {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>(); 

            for(Id recipientId : recipientsIds){
                Messaging.SingleEmailMessage email = new messaging.SingleEmailMessage(); 
                email.setSubject(emailSubject); 
                email.setHtmlBody(emailBody); 
                email.setTargetObjectId(recipientId);
                email.setWhatId(recordId);

                if(typeOfEmailCopy == 'cc'){
                    email.setCcAddresses(emailsToCopy);
                }
                if(typeOfEmailCopy == 'bcc'){
                    email.setBccAddresses(emailsToCopy);
                }

                if(orgWideAddressId != 'none'){
                    email.setOrgWideEmailAddressId((Id)orgWideAddressId);
                }

                emails.add(email);
            }

            Messaging.sendEmail(emails); 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class JSONDirectWrapper{
        public Boolean areContactsChildren;
        public String fromCurrentToParent;
        public String fromContactToParent;
    }

    public class JSONJunctionWrapper{
        public Boolean areContactsChildren;
        public String fromCurrentToParent;
        public String junctionName;
        public String fromJunctionToParent;
        public String fromJunctionToContact;
    }

    public with sharing class RecipientWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String email;

        RecipientWrapper(Contact c, String fieldToDisplay){
            this.id = c.Id;
            this.name = c.Name;
            this.email = c.Email;
            this.label = fieldToDisplay == '' ? c.Name : c.Name + ' (' + c.get(fieldToDisplay) + ')';
        }
    }
}