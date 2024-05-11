@isTest
private class ProgramAssignmentTriggerHandlerTest {
    @testSetup
    static void makeData(){
        Program_Budget__c budget = DataFactory.getProgramBudget(1000);
        insert budget;

        Program__c program = DataFactory.getProgram(800, budget.Id);
        insert program;
    }

    @isTest
    static void testInsertProgramAssignment() {
        Program__c program = [SELECT Id, Rest_Money__c FROM Program__c LIMIT 1];
        Program_Assignment__c programAssignemnt = DataFactory.getProgramAssignment(600, program.Id);

        Test.startTest();
        insert programAssignemnt;
        Test.stopTest();

        program = [SELECT Id, Rest_Money__c FROM Program__c LIMIT 1];

        Assert.areEqual(200, program.Rest_Money__c);
    }

    @isTest
    static void testUpdateProgramAssignment() {
        Program__c program = [SELECT Id, Rest_Money__c FROM Program__c LIMIT 1];
        Program_Assignment__c programAssignemnt = DataFactory.getProgramAssignment(600, program.Id);
        insert programAssignemnt;


        Test.startTest();
        update new Program_Assignment__c(Id=programAssignemnt.Id, Assignment_Money__c=500);
        Test.stopTest();

        program = [SELECT Id, Rest_Money__c FROM Program__c LIMIT 1];

        Assert.areEqual(300, program.Rest_Money__c);
    }

    @isTest
    static void testDeleteProgramAssignment() {
        Program__c program = [SELECT Id, Rest_Money__c FROM Program__c LIMIT 1];
        Program_Assignment__c programAssignemnt = DataFactory.getProgramAssignment(800, program.Id);
        insert programAssignemnt;

        Test.startTest();
        delete programAssignemnt;
        Test.stopTest();

        program = [SELECT Id, Rest_Money__c FROM Program__c LIMIT 1];

        Assert.areEqual(800, program.Rest_Money__c);
    }
}