public with sharing class ProgramTriggerHandler extends TriggerHandler {
    public override void afterInsert(){
        List<Program__c> programs = (List<Program__c>)Trigger.New;
        Set<Id> budgetIds = new Set<Id>();

        for(Program__c program : programs){
            if(program.Program_Budget__c != null){
                budgetIds.add(program.Program_Budget__c);
            }
        }

        ProgramTriggerHelper helper = new ProgramTriggerHelper(budgetIds);
        helper.recalculatePrograms();
    }

    public override void afterUpdate(){
        List<Program__c> newprograms = (List<Program__c>)Trigger.New;
        List<Program__c> oldprograms = (List<Program__c>)Trigger.Old;
        Set<Id> budgetIds = new Set<Id>();

        for(Program__c program : newprograms){
            if(program.Program_Budget__c != null){
                budgetIds.add(program.Program_Budget__c);
            }
        }

        for(Program__c program : oldprograms){
            if(program.Program_Budget__c != null){
                budgetIds.add(program.Program_Budget__c);
            }
        }

        ProgramTriggerHelper helper = new ProgramTriggerHelper(budgetIds);
        helper.recalculatePrograms();
    }

    public override void afterDelete(){
        List<Program__c> programs = (List<Program__c>)Trigger.Old;
        Set<Id> budgetIds = new Set<Id>();

        for(Program__c program : programs){
            if(program.Program_Budget__c != null){
                budgetIds.add(program.Program_Budget__c);
            }
        }

        ProgramTriggerHelper helper = new ProgramTriggerHelper(budgetIds);
        helper.recalculatePrograms();
    }
}