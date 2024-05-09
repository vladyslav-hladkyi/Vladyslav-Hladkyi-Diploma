public with sharing class DonateTriggerHandler extends TriggerHandler {
    public override void afterInsert(){
        List<Donate__c> donates = (List<Donate__c>)Trigger.New;
        Set<Id> budgetIds = new Set<Id>();

        for(Donate__c donate : donates){
            if(donate.Program_Budget__c != null){
                budgetIds.add(donate.Program_Budget__c);
            }
        }

        DonateTriggerHelper helper = new DonateTriggerHelper(budgetIds);
        helper.recalculateDonates();
    }

    public override void afterUpdate(){
        List<Donate__c> newDonates = (List<Donate__c>)Trigger.New;
        List<Donate__c> oldDonates = (List<Donate__c>)Trigger.Old;
        Set<Id> budgetIds = new Set<Id>();

        for(Donate__c donate : newDonates){
            if(donate.Program_Budget__c != null){
                budgetIds.add(donate.Program_Budget__c);
            }
        }

        for(Donate__c donate : oldDonates){
            if(donate.Program_Budget__c != null){
                budgetIds.add(donate.Program_Budget__c);
            }
        }

        DonateTriggerHelper helper = new DonateTriggerHelper(budgetIds);
        helper.recalculateDonates();
    }

    public override void afterDelete(){
        List<Donate__c> donates = (List<Donate__c>)Trigger.Old;
        Set<Id> budgetIds = new Set<Id>();

        for(Donate__c donate : donates){
            if(donate.Program_Budget__c != null){
                budgetIds.add(donate.Program_Budget__c);
            }
        }

        DonateTriggerHelper helper = new DonateTriggerHelper(budgetIds);
        helper.recalculateDonates();
    }
}