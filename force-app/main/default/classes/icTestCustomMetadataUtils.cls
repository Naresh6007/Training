/****************************************
 * Author : Incloud - Sahil Goyal
 * Date: 2024-07-16
 * Description: Test class for Custom Metadata Create and Update methods
****************************************/
@isTest
public class icTestCustomMetadataUtils {
    
    @isTest
    public static void configSetupTest () {
        icCustomMetadataUtils metadata = new icCustomMetadataUtils ();
        
        Test.startTest();
        	metadata.handleResult(new Metadata.DeployResult(), new Metadata.DeployCallbackContext());
        Test.stopTest();
    }
    
    @isTest
    public static void CreateUpdateMetadataUtilsTest(){
        String fullName   = 'Outbox_Object_API__mdt.Test';
        String devName    = 'Test_Data';
        String label      = 'Test Data';
        String values = '{"Last_Run_Time__c": "2022-10-10"}';
        
        Map<String, Object> deployedValue = (Map<String, Object>)JSON.deserializeUntyped(values);
        
        Test.startTest();
	        icCustomMetadataUtils.createCustomMetadata(fullName, label, deployedValue);
	        icCustomMetadataUtils.updateCustomMetadata(fullName, devName, label, deployedValue);
        Test.stopTest();
        
    }
}