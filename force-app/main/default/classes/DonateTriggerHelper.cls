public with sharing class DonateTriggerHelper {
    private Set<Id> budgetIds;

    public DonateTriggerHelper(Set<Id> budgetIds){
        this.budgetIds = budgetIds;
    }

    public void recalculateDonates(){
        List<Program_Budget__c> budgetsForUpdate = new List<Program_Budget__c>();
        List<Program_Budget__c> budgets = [
            SELECT 
                Id, (SELECT Id, Amount__c FROM Donates__r WHERE Status__c = 'Paid')
            FROM 
                Program_Budget__c
            WHERE 
                Id IN :budgetIds
        ];

        for(Program_Budget__c budget : budgets){
            Decimal total = 0;
            
            for(Donate__c donate : budget.Donates__r){
                total += donate.Amount__c;
            }

            budgetsForUpdate.add(new Program_Budget__c(Id = budget.Id, Fundraised_Money__c = total));
        }

        update budgetsForUpdate;
    }
}