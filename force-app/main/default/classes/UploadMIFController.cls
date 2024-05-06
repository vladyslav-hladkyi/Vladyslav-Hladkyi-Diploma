/**
 * @description       : 
 * @author            : sergiy.korolivskyi
 * @group             : 
 * @last modified on  : 04-25-2024
 * @last modified by  : vladyslav.hladkyi
**/
public class UploadMIFController {
    @AuraEnabled
    public static List<String> getAllAvailableHealthPlans(){
        List<MIF_Mapping__mdt> mappingRecords = [
            SELECT Id, Health_Plan__c 
            FROM MIF_Mapping__mdt 
            WHERE Is_Active__c = TRUE AND Type__c = 'MIF'
        ];

        List<String> healthPlans = new List<String>();

        for(MIF_Mapping__mdt mappingRecord : mappingRecords){
            healthPlans.add(mappingRecord.Health_Plan__c);
        }

        return healthPlans;
    }

    @AuraEnabled
    public static void handleMIFRecords(String healthPlan, List<Object> listMIFRecords) {
        try {
            MIF_Mapping__mdt mapping = [
                SELECT Id, JSON_Mapping__c, Health_Plan__c, Transformatinion_Method_Class__c 
                FROM MIF_Mapping__mdt 
                WHERE Health_Plan__c =:healthPlan AND Is_Active__c = TRUE AND Type__c = 'MIF'
            ];
            
            Map<String, ColumnWrapper> jsonMIFMapping = (Map<String, ColumnWrapper> )JSON.deserialize(mapping.JSON_Mapping__c, Map<String, ColumnWrapper>.class);  // keys are field's api names and values are ColumnWrapper
            Callable callableHelper = (Callable) Type.forName(mapping.Transformatinion_Method_Class__c).newInstance();   // class with transformation methods
            List<MIF_Temp__c> newMIFs = new List<MIF_Temp__c>();

            for(Object mIFRecord : listMIFRecords){
                MIF_Temp__c newMIF = new MIF_Temp__c();
                Map<String, Object> mapMIFRecord = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mIFRecord));

                // map each field from MIF_Mapping__mdt
                for(String fieldName : jsonMIFMapping.keySet()){
                    String tranfrormationMethod = String.valueOf(jsonMIFMapping.get(fieldName).transformationMethod);
                    String columnName = String.valueOf(jsonMIFMapping.get(fieldName).columnName);
                    Object fieldValue;

                    // if tranfrormationMethod is blnak -> interpret as String without transformation
                    if(tranfrormationMethod == ''){
                        fieldValue = String.valueOf(mapMIFRecord.get(columnName));
                    }
                    else {
                        fieldValue = callableHelper.call(tranfrormationMethod, new Map<String, Object> { 'columnName' => columnName, 'row' => mapMIFRecord });
                    }

                    newMIF.put(fieldName, fieldValue);
                }

                newMIF.put('Health_Plan__c', healthPlan);
                newMIFs.add(newMIF);
            }

            insert newMIFs;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private class ColumnWrapper {
        String columnName;
        String transformationMethod;
    }
}