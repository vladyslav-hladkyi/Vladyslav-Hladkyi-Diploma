@isTest
private class ConvertApplicationControllerTest {
    @testSetup
    static void makeData(){
        Application__c application = new Application__c(
            Email__c = 't@t.c', 
            First_Name__c='tes', 
            Last_Name__c='testen', 
            Phone__c='06654321', 
            Requested_Support__c='test text'
        );

        insert application;
    }

    @isTest
    static void testConvertApplication() {
        Application__c application = [SELECT Id FROM Application__c LIMIT 1];

        Test.startTest();
        ConvertApplicationController.createContact(application.Id);
        Test.stopTest();

        application = [SELECT Id, Contact__c FROM Application__c LIMIT 1];

        Assert.isNotNull(application.Contact__c);
    }
}