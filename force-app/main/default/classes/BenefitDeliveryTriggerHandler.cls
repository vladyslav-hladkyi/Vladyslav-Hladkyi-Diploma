public with sharing class BenefitDeliveryTriggerHandler extends TriggerHandler  {
    public override void afterInsert(){
        List<Benefit_Delivery__c> benefitDeliveries = (List<Benefit_Delivery__c>)Trigger.New;
        Set<Id> programAssignmentIds = new Set<Id>();

        for(Benefit_Delivery__c benefitDelivery : benefitDeliveries){
            if(benefitDelivery.Program_Assignment__c != null){
                programAssignmentIds.add(benefitDelivery.Program_Assignment__c);
            }
        }

        BenefitDeliveryTriggerHelper helper = new BenefitDeliveryTriggerHelper(programAssignmentIds);
        helper.recalculateBenefitDeliveries();
    }

    public override void afterUpdate(){
        List<Benefit_Delivery__c> newBenefitDeliveries = (List<Benefit_Delivery__c>)Trigger.New;
        List<Benefit_Delivery__c> oldBenefitDeliveries = (List<Benefit_Delivery__c>)Trigger.Old;
        Set<Id> programAssignmentIds = new Set<Id>();

        for(Benefit_Delivery__c benefitDelivery : newBenefitDeliveries){
            if(benefitDelivery.Program_Assignment__c != null){
                programAssignmentIds.add(benefitDelivery.Program_Assignment__c);
            }
        }

        for(Benefit_Delivery__c benefitDelivery : oldBenefitDeliveries){
            if(benefitDelivery.Program_Assignment__c != null){
                programAssignmentIds.add(benefitDelivery.Program_Assignment__c);
            }
        }

        BenefitDeliveryTriggerHelper helper = new BenefitDeliveryTriggerHelper(programAssignmentIds);
        helper.recalculateBenefitDeliveries();
    }

    public override void afterDelete(){
        List<Benefit_Delivery__c> benefitDeliveries = (List<Benefit_Delivery__c>)Trigger.Old;
        Set<Id> programAssignmentIds = new Set<Id>();

        for(Benefit_Delivery__c benefitDelivery : benefitDeliveries){
            if(benefitDelivery.Program_Assignment__c != null){
                programAssignmentIds.add(benefitDelivery.Program_Assignment__c);
            }
        }

        BenefitDeliveryTriggerHelper helper = new BenefitDeliveryTriggerHelper(programAssignmentIds);
        helper.recalculateBenefitDeliveries();
    }
}