@isTest
private class BenefitDeliveryTriggerHandlerTest {
    @testSetup
    static void makeData(){
        Program_Budget__c budget = DataFactory.getProgramBudget(1000);
        insert budget;

        Program__c program = DataFactory.getProgram(800, budget.Id);
        insert program;

        Program_Assignment__c programAssignemnt = DataFactory.getProgramAssignment(600, program.Id);
        insert programAssignemnt;
    }

    @isTest
    static void testInsertBenefitDelivery() {
        Program_Assignment__c programAssignemnt = [SELECT Id, Rest_Money__c FROM Program_Assignment__c LIMIT 1];
        Benefit_Delivery__c benefitDelivery = DataFactory.getBenefitDelivery(400, programAssignemnt.Id);

        Test.startTest();
        insert benefitDelivery;
        Test.stopTest();

        programAssignemnt = [SELECT Id, Rest_Money__c FROM Program_Assignment__c LIMIT 1];

        Assert.areEqual(200, programAssignemnt.Rest_Money__c);
    }

    @isTest
    static void testUpdateBenefitDelivery() {
        Program_Assignment__c programAssignemnt = [SELECT Id, Rest_Money__c FROM Program_Assignment__c LIMIT 1];
        Benefit_Delivery__c benefitDelivery = DataFactory.getBenefitDelivery(400, programAssignemnt.Id);
        insert benefitDelivery;


        Test.startTest();
        update new Benefit_Delivery__c(Id=benefitDelivery.Id, Price__c=300);
        Test.stopTest();

        programAssignemnt = [SELECT Id, Rest_Money__c FROM Program_Assignment__c LIMIT 1];

        Assert.areEqual(300, programAssignemnt.Rest_Money__c);
    }

    @isTest
    static void testDeleteBenefitDelivery() {
        Program_Assignment__c programAssignemnt = [SELECT Id, Rest_Money__c FROM Program_Assignment__c LIMIT 1];
        Benefit_Delivery__c benefitDelivery = DataFactory.getBenefitDelivery(400, programAssignemnt.Id);
        insert benefitDelivery;

        Test.startTest();
        delete benefitDelivery;
        Test.stopTest();

        programAssignemnt = [SELECT Id, Rest_Money__c FROM Program_Assignment__c LIMIT 1];

        Assert.areEqual(600, programAssignemnt.Rest_Money__c);
    }
}