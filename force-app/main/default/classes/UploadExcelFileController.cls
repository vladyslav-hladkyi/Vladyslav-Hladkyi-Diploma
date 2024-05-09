/**
 * @description       : 
 * @author            : vladyslav.hladkyi
 * @group             : 
 * @last modified on  : 05-06-2024
 * @last modified by  : vladyslav.hladkyi
**/
public class UploadExcelFileController {
    @AuraEnabled
    public static List<String> getAllAvailableMappings(){
        List<Excel_File_Mapping__mdt> mappingRecords = [
            SELECT Id, DeveloperName
            FROM Excel_File_Mapping__mdt 
            WHERE Is_Active__c = TRUE ORDER BY DeveloperName
        ];

        List<String> metadataNames = new List<String>();

        for(Excel_File_Mapping__mdt mappingRecord : mappingRecords){
            metadataNames.add(mappingRecord.DeveloperName);
        }

        return metadataNames;
    }

    @AuraEnabled
    public static void handleUploadedRecords(String mappingDeveloperName, List<Object> uploadedRecords) {
        try {
            Excel_File_Mapping__mdt mapping = [
                SELECT Id, JSON_Mapping__c, Transformatinion_Method_Class__c, Object_API_Name__c 
                FROM Excel_File_Mapping__mdt
                WHERE DeveloperName =:mappingDeveloperName
            ];
            
            Map<String, ColumnWrapper> jsonMIFMapping = (Map<String, ColumnWrapper> )JSON.deserialize(mapping.JSON_Mapping__c, Map<String, ColumnWrapper>.class);  // keys are field's api names and values are ColumnWrapper
            Callable callableHelper = (Callable) Type.forName(mapping.Transformatinion_Method_Class__c).newInstance();   // class with transformation methods

            Type objectType = Type.forName(mapping.Object_API_Name__c); //Creating a type class instance
            List<SObject> newRecords = new List<SObject>();

            for(Object uplodedRecord : uploadedRecords){
                SObject newRecord = (SObject)objectType.newInstance();
                Map<String, Object> mapUplodedRecord = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(uplodedRecord));

                // map each field from Excel_File_Mapping__mdt
                for(String fieldName : jsonMIFMapping.keySet()){
                    String tranfrormationMethod = String.valueOf(jsonMIFMapping.get(fieldName).transformationMethod);
                    String columnName = String.valueOf(jsonMIFMapping.get(fieldName).columnName);
                    Object fieldValue;

                    // if tranfrormationMethod is blnak -> interpret as String without transformation
                    if(tranfrormationMethod == ''){
                        fieldValue = String.valueOf(mapUplodedRecord.get(columnName));
                    }
                    else {
                        fieldValue = callableHelper.call(tranfrormationMethod, new Map<String, Object> { 'columnName' => columnName, 'row' => mapUplodedRecord });
                    }

                    newRecord.put(fieldName, fieldValue);
                }

                newRecords.add(newRecord);
            }

            insert newRecords;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private class ColumnWrapper {
        String columnName;
        String transformationMethod;
    }
}