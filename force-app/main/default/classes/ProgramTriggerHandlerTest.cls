@isTest
private class ProgramTriggerHandlerTest {
    @testSetup
    static void makeData(){
        Program_Budget__c budget = DataFactory.getProgramBudget(1000);

        insert budget;
    }

    @isTest
    static void testInsertProgram() {
        Program_Budget__c budget = [SELECT Id FROM Program_Budget__c LIMIT 1];
        Program__c program = DataFactory.getProgram(800, budget.Id);

        Test.startTest();
        insert program;
        Test.stopTest();

        budget = [SELECT Id, Rest_Money__c FROM Program_Budget__c LIMIT 1];

        Assert.areEqual(200, budget.Rest_Money__c);
    }

    @isTest
    static void testUpdateProgram() {
        Program_Budget__c budget = [SELECT Id FROM Program_Budget__c LIMIT 1];

        Program__c program = DataFactory.getProgram(800, budget.Id);
        insert program;

        Test.startTest();
        update new Program__c(Id=program.Id, Available_Money__c=700);
        Test.stopTest();

        budget = [SELECT Id, Rest_Money__c FROM Program_Budget__c LIMIT 1];

        Assert.areEqual(300, budget.Rest_Money__c);
    }

    @isTest
    static void testDeleteProgram() {
        Program_Budget__c budget = [SELECT Id FROM Program_Budget__c LIMIT 1];
        Program__c program = DataFactory.getProgram(800, budget.Id);
        insert program;

        Test.startTest();
        delete program;
        Test.stopTest();

        budget = [SELECT Id, Rest_Money__c FROM Program_Budget__c LIMIT 1];

        Assert.areEqual(1000, budget.Rest_Money__c);
    }
}