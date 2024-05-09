trigger ProgramTrigger on Program__c (after insert, after update, after delete) {
    new ProgramTriggerHandler().run();
}