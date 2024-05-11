@isTest
private class DonateTriggerHandlerTest {
    @testSetup
    static void makeData(){
        Program_Budget__c budget = DataFactory.getProgramBudget(0);

        insert budget;
    }

    @isTest
    static void testInsertDonate() {
        Program_Budget__c budget = [SELECT Id FROM Program_Budget__c LIMIT 1];
        Donate__c donate = DataFactory.getDonate(800, budget.Id);

        Test.startTest();
        insert donate;
        Test.stopTest();

        budget = [SELECT Id, Fundraised_Money__c FROM Program_Budget__c LIMIT 1];

        Assert.areEqual(800, budget.Fundraised_Money__c);
    }

    @isTest
    static void testUpdateProgram() {
        Program_Budget__c budget = [SELECT Id FROM Program_Budget__c LIMIT 1];

        Donate__c donate = DataFactory.getDonate(800, budget.Id);
        insert donate;

        Test.startTest();
        update new Donate__c(Id=donate.Id, Amount__c=700);
        Test.stopTest();

        budget = [SELECT Id, Fundraised_Money__c FROM Program_Budget__c LIMIT 1];

        Assert.areEqual(700, budget.Fundraised_Money__c);
    }

    @isTest
    static void testDeleteProgram() {
        Program_Budget__c budget = [SELECT Id FROM Program_Budget__c LIMIT 1];
        Donate__c donate = DataFactory.getDonate(800, budget.Id);
        insert donate;

        Test.startTest();
        delete donate;
        Test.stopTest();

        budget = [SELECT Id, Fundraised_Money__c FROM Program_Budget__c LIMIT 1];

        Assert.areEqual(0, budget.Fundraised_Money__c);
    }
}