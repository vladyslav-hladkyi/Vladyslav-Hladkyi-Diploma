@IsTest
public with sharing class UploadMIFControllerTest {
    @IsTest
    public static void getAllAvailableHealthPlansTest(){
        List<MIF_Mapping__mdt> mappingRecords = [
            SELECT Id 
            FROM MIF_Mapping__mdt 
            WHERE Is_Active__c = TRUE AND Type__c = 'MIF'
        ];

        Test.startTest();
        List<String> options = UploadMIFController.getAllAvailableHealthPlans();
        Test.stopTest();

        Assert.areEqual(mappingRecords.size(), options.size());
    }

    @IsTest
    public static void handleMIFRecordsTest(){
        String jsonString = '[{"Member Client Index Number (CIN)":"11111119F","Medical Record Number (MRN)":"R11111112","Member Last Name":"John","Member First Name":"TEST","Member Homelessness Indicator":0,"Member Residential Address Line 1":"Main 12",' + 
            '"Member Residential Address Line 2":"test 1.1","Member Residential City":"LANCASTER","Member Residential State":"CA","Member Residential Zip":93535,"Member Mailing Address Line 1":"Main 12","Member Mailing Address Line 2":"line 1","Member Mailing City":"LANCASTER",' +
            '"Member Mailing State":"CA","Member Mailing Zip":93535,"Member County":"Los Angeles","Member Phone Number":123456789,"Member Email Address":"vlad@gmail.com","Member Dually Enrolled in Medicare":1,"Emergency/Alternate Contact Relation":2,' +
            '"Emergency/Alternate Contact Phone Number":123345667,"Member Date of Birth":"4/3/2004","Member Gender Code":"M","Member Preferred Language (Spoken)":"ENGLISH","Member Preferred Language (Written)":"English","Member Preferred Alternate Format":"TBD",'+ 
            '"Member Race or Ethnicity":"White","Medi-Cal Renewal Date":"1/1/2025","ECM Service Authorization Date by MCP":"4/1/2024","ECM Authorization End Date":"12/1/2024","Member ECM Authorization Number":12345,'+
            '"Adult - Individual Experiencing Homelessness: Adults without Dependent Children/Youth Living with Them Experiencing Homelessness":1,"Adult - Individual Experiencing Homelessness: Homeless Family":0,"Adult - Individuals at Risk for Avoidable Hospital or ED Utilization":0}]';
        
        List<Object> deserializeJson = (List<Object>)JSON.deserializeUntyped(jsonString);

        Test.startTest();
        UploadMIFController.handleMIFRecords('HealthNet', deserializeJson);
        Test.stopTest();

        List<MIF_Temp__c> mifRecords = [SELECT Id FROM MIF_Temp__c];

        Assert.areEqual(1, mifRecords.size());
    }
}