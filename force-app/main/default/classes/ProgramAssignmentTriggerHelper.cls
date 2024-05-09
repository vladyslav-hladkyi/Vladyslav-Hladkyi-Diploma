public with sharing class ProgramAssignmentTriggerHelper {
    private Set<Id> programIds;

    public ProgramAssignmentTriggerHelper(Set<Id> programIds){
        this.programIds = programIds;
    }

    public void recalculateProgramAssignments(){
        List<Program__c> programsForUpdate = new List<Program__c>();
        List<Program__c> programs = [
            SELECT 
                Id, (SELECT Id, Assignment_Money__c FROM Program_Assignment__r)
            FROM 
                Program__c
            WHERE 
                Id IN :programIds
        ];

        for(Program__c program : programs){
            Decimal total = 0;
            
            for(Program_Assignment__c programAssignment : program.Program_Assignment__r){
                total += programAssignment.Assignment_Money__c;
            }

            programsForUpdate.add(new Program__c(Id = program.Id, Assignment_Money__c = total));
        }

        update programsForUpdate;
    }
}