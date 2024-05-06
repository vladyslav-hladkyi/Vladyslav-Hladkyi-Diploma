public with sharing class EmailSenderControllerService {

    public static List<Contact> queryJunctionContactsFromChildren(Id recordId, String contactFilter, String junctionFilter, String fieldToDisplay, EmailSenderController.JSONJunctionWrapper jsonWrapper) {
        String queryString = 
            'SELECT Id, ' + jsonWrapper.fromJunctionToContact + ' ' + 
            'FROM ' + jsonWrapper.junctionName + ' ' + 
            'WHERE ' + jsonWrapper.fromJunctionToParent + ' = \'' + recordId + '\'' + (junctionFilter == '' ? '' : (' AND ' + junctionFilter) )
        ;
        List<SObject> junctions = Database.query(queryString, AccessLevel.USER_MODE);

        Set<Id> contactsIds = new Set<Id>();
        Map<String, Object> bindMap = new Map<String, Object>{'contactsIds' => contactsIds};

        for(SObject junction : junctions) {
            contactsIds.add((Id)junction.get(jsonWrapper.fromJunctionToContact));
        }

        queryString = 
            'SELECT Id, Name, Email ' + (fieldToDisplay == '' || fieldToDisplay == 'Email' ? '' : (', ' + fieldToDisplay) ) + ' ' +
            'FROM Contact ' +
            'WHERE Id IN :contactsIds ' + (contactFilter == '' ? '' : (' AND ' + contactFilter) )
        ;
         
        return (List<Contact>)Database.queryWithBinds(queryString, bindMap, AccessLevel.USER_MODE);
    }

    public static List<Contact> queryJunctionContactsFromParent(Id recordId, String contactFilter, String junctionFilter, String fieldToDisplay, EmailSenderController.JSONJunctionWrapper jsonWrapper) {
        String queryString = 
            'SELECT Id, ' + jsonWrapper.fromCurrentToParent + ' ' + 
            'FROM ' + recordId.getSObjectType().getDescribe().getName() + ' ' + 
            'WHERE Id = \'' + recordId + '\''
        ;
        SObject parent = Database.query(queryString, AccessLevel.USER_MODE);
        
        return queryJunctionContactsFromChildren((Id)parent.get(jsonWrapper.fromCurrentToParent), contactFilter, junctionFilter, fieldToDisplay, jsonWrapper);
    }

    public static List<Contact> queryDirectContactsFromChildren(Id recordId, String contactFilter, String fieldToDisplay, EmailSenderController.JSONDirectWrapper jsonWrapper) {
        String queryString = 
            'SELECT Id, Name, Email ' + (fieldToDisplay == '' || fieldToDisplay == 'Email' ? '' : (', ' + fieldToDisplay) ) + ' ' +
            'FROM Contact ' +
            'WHERE ' + jsonWrapper.fromContactToParent + ' = \'' + recordId + '\' '  + (contactFilter == '' ? '' : (' AND ' + contactFilter) )
        ;
         
        return (List<Contact>)Database.query(queryString, AccessLevel.USER_MODE);
    }

    public static List<Contact> queryDirectContactsFromParent(Id recordId, String contactFilter, String fieldToDisplay, EmailSenderController.JSONDirectWrapper jsonWrapper) {
        String queryString = 
            'SELECT Id, ' + jsonWrapper.fromCurrentToParent + ' ' + 
            'FROM ' + recordId.getSObjectType().getDescribe().getName() + ' ' + 
            'WHERE Id = \'' + recordId + '\''
        ;
        SObject parent = Database.query(queryString, AccessLevel.USER_MODE);
         
        return queryDirectContactsFromChildren((Id)parent.get(jsonWrapper.fromCurrentToParent), contactFilter, fieldToDisplay, jsonWrapper);
    }
}