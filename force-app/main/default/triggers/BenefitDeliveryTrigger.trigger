trigger BenefitDeliveryTrigger on Benefit_Delivery__c (after insert, after update, after delete) {
    new BenefitDeliveryTriggerHandler().run();
}