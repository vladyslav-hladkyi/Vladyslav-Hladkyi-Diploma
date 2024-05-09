public with sharing class ProgramAssignmentTriggerHandler extends TriggerHandler  {
    public override void afterInsert(){
        List<Program_Assignment__c> programAssignments = (List<Program_Assignment__c>)Trigger.New;
        Set<Id> programIds = new Set<Id>();

        for(Program_Assignment__c programAssignment : programAssignments){
            if(programAssignment.Program__c != null){
                programIds.add(programAssignment.Program__c);
            }
        }

        ProgramAssignmentTriggerHelper helper = new ProgramAssignmentTriggerHelper(programIds);
        helper.recalculateProgramAssignments();
    }

    public override void afterUpdate(){
        List<Program_Assignment__c> newProgramAssignments = (List<Program_Assignment__c>)Trigger.New;
        List<Program_Assignment__c> oldProgramAssignments = (List<Program_Assignment__c>)Trigger.Old;
        Set<Id> programIds = new Set<Id>();

        for(Program_Assignment__c programAssignment : newProgramAssignments){
            if(programAssignment.Program__c != null){
                programIds.add(programAssignment.Program__c);
            }
        }

        for(Program_Assignment__c programAssignment : oldProgramAssignments){
            if(programAssignment.Program__c != null){
                programIds.add(programAssignment.Program__c);
            }
        }

        ProgramAssignmentTriggerHelper helper = new ProgramAssignmentTriggerHelper(programIds);
        helper.recalculateProgramAssignments();
    }

    public override void afterDelete(){
        List<Program_Assignment__c> programAssignments = (List<Program_Assignment__c>)Trigger.Old;
        Set<Id> programIds = new Set<Id>();

        for(Program_Assignment__c programAssignment : programAssignments){
            if(programAssignment.Program__c != null){
                programIds.add(programAssignment.Program__c);
            }
        }

        ProgramAssignmentTriggerHelper helper = new ProgramAssignmentTriggerHelper(programIds);
        helper.recalculateProgramAssignments();
    }
}