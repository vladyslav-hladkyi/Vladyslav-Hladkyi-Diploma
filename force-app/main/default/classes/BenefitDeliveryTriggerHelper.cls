public with sharing class BenefitDeliveryTriggerHelper {
    private Set<Id> programAssignmentIds;

    public BenefitDeliveryTriggerHelper(Set<Id> programAssignmentIds){
        this.programAssignmentIds = programAssignmentIds;
    }

    public void recalculateBenefitDeliveries(){
        List<Program_Assignment__c> programAssignmentsForUpdate = new List<Program_Assignment__c>();
        List<Program_Assignment__c> programAssignments = [
            SELECT 
                Id, (SELECT Id, Price__c FROM Benefit_Deliveries__r)
            FROM 
                Program_Assignment__c
            WHERE 
                Id IN :programAssignmentIds
        ];

        for(Program_Assignment__c programAssignment : programAssignments){
            Decimal total = 0;
            
            for(Benefit_Delivery__c serviceDelivery : programAssignment.Benefit_Deliveries__r){
                total += serviceDelivery.Price__c;
            }

            programAssignmentsForUpdate.add(new Program_Assignment__c(Id = programAssignment.Id, Spent_Money__c = total));
        }

        update programAssignmentsForUpdate;
    }
}