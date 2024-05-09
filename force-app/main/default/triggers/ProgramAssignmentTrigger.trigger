trigger ProgramAssignmentTrigger on Program_Assignment__c (after insert, after update, after delete) {
    new ProgramAssignmentTriggerHandler().run();
}