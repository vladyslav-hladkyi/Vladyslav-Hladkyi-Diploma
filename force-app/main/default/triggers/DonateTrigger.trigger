trigger DonateTrigger on Donate__c (after insert, after update, after delete) {
    new DonateTriggerHandler().run();
}