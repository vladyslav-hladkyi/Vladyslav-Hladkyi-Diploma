public with sharing class ProgramTriggerHelper {
    private Set<Id> budgetIds;

    public ProgramTriggerHelper(Set<Id> budgetIds){
        this.budgetIds = budgetIds;
    }

    public void recalculatePrograms(){
        List<Program_Budget__c> budgetsForUpdate = new List<Program_Budget__c>();
        List<Program_Budget__c> budgets = [
            SELECT 
                Id, (SELECT Id, Available_Money__c FROM Programs__r)
            FROM 
                Program_Budget__c
            WHERE 
                Id IN :budgetIds
        ];

        for(Program_Budget__c budget : budgets){
            Decimal total = 0;
            
            for(Program__c program : budget.Programs__r){
                total += program.Available_Money__c;
            }

            budgetsForUpdate.add(new Program_Budget__c(Id = budget.Id, Distributed_Money__c = total));
        }

        update budgetsForUpdate;
    }
}