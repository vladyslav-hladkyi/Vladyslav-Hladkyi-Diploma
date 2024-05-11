@IsTest
public with sharing class UploadExcelFileControllerTest {
    @IsTest
    public static void getAllAvailableMappings(){
        List<Excel_File_Mapping__mdt> mappingRecords = [
            SELECT Id, DeveloperName
            FROM Excel_File_Mapping__mdt 
            WHERE Is_Active__c = TRUE ORDER BY DeveloperName
        ];

        Test.startTest();
        List<String> options = UploadExcelFileController.getAllAvailableMappings();
        Test.stopTest();

        Assert.areEqual(mappingRecords.size(), options.size());
    }

    @IsTest
    public static void handleUploadedRecordsTest(){
        String jsonString = '[{"Member First Name":"Test", "Member Last Name":"Testenko", "Member Birthdate":"02/04/2003", "Do Not Call":"1"}]';
        
        List<Object> deserializeJson = (List<Object>)JSON.deserializeUntyped(jsonString);

        Test.startTest();
        UploadExcelFileController.handleUploadedRecords('Contacts_Donatia', deserializeJson);
        Test.stopTest();

        List<Contact> newRecords = [SELECT Id FROM Contact];

        Assert.areEqual(1, newRecords.size());
    }
}