
public with sharing class DataFactory {
    public static Program_Budget__c getProgramBudget(Decimal fundraisedMoney){
        return new Program_Budget__c(Name='Test Program Budget', Expected_Amount__c = 10000, Fundraised_Money__c=fundraisedMoney);
    }

    public static Program__c getProgram(Decimal assignmentMoney, Id budgetId){
        return new Program__c(Name='Test Program', StartDate__c = Date.today(), Available_Money__c=assignmentMoney, Program_Budget__c=budgetId, Status__c='Active');
    }

    public static Donate__c getDonate(Decimal amount, Id budgetId){
        return new Donate__c(Name = 'Test Amount', Amount__c=amount, Status__c='Paid', Program_Budget__c=budgetId);
    }

    public static Program_Assignment__c getProgramAssignment(Decimal assignmentMoney, Id programId){
        return new Program_Assignment__c(Name='Test Program Assignment', StartDate__c = Date.today(), Assignment_Money__c=assignmentMoney, Program__c=programId, Stage__c='Active');
    }

    public static Benefit_Delivery__c getBenefitDelivery(Decimal price, Id programAssignmentId){
        return new Benefit_Delivery__c(Name='Test Benefit Delivery', Price__c=price, Program_Assignment__c=programAssignmentId);
    }
}