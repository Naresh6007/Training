@isTest
public class icTestOutboxServiceCallout {

    // Set up method will be called at the beginning of every Test method
    @TestSetup
	static void makeTestData() {

        //Testing Person Acct Insert
        Account persAcct = new Account();
        Schema.SObjectType sobjType = OutboxDML.globalDescribe.get('Account');
        persAcct.RecordTypeId = sobjType.getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        // Person accounts uses First and Last Name together as the Account Name
        persAcct.FirstName = 'Person';
        persAcct.LastName = 'Account';
        persAcct.Phone = '1234567890';
        persAcct.Billing_Address_Primary_id__c = '4DA58B55-512A-462F-959F-1E318D2311BD';
        insert persAcct;
        System.debug('Person Account record inserted successfully');

        //Inserting test record for Outbox Retreive custom setting
		outbox_retreive__c testRetreive = new outbox_retreive__c();
		testRetreive.Retreive_Date__c = Date.newInstance(2022, 07, 24);
		testRetreive.Use_date__c = False;
		insert testRetreive;
		System.debug('testRetreive record inserted successfully');
	}


    @isTest
    static void testOrderCallout(){
        Test.setMock(HTTPCalloutMock.class, new OutboxCalloutServiceMock());
       
        Test.startTest();
        String response = OutboxCalloutService.getObjectData('Order');
        OutboxWrapper owp = OutboxParser.getObjectRecords(response);
        OutboxDML.addObject (owp, 'Order__c');
        Test.stopTest();
        System.assertEquals(3, [SELECT count() FROM Order__c]);

    }

    @isTest
    static void testAccountCallout(){
        Test.setMock(HTTPCalloutMock.class, new OutboxCalloutAccountMock());
        Test.startTest();
        String response = OutboxCalloutService.getObjectData('Customer');
        OutboxWrapper owp = OutboxParser.getObjectRecords(response);
        OutboxDML.addObject (owp, 'Account');
        Test.stopTest();
        // List<Account> acctList = [SELECT Id, Name, Billing_Address_Primary_id__c, RecordTypeId FROM Account];
        // System.debug(acctList);
        System.debug('Count of Account:');
        System.debug([SELECT count() FROM Account]);
        System.assertEquals(2, [SELECT count() FROM Account]);
    }

    @isTest
    static void testExceptionCallout(){
        Test.setMock(HTTPCalloutMock.class, new OutboxCalloutAccountMock());
        Test.startTest();
        String response = OutboxCalloutService.getObjectData('Order');
        OutboxWrapper owp = OutboxParser.getObjectRecords(response);
        OutboxDML.addObject (owp, 'Account');
        Test.stopTest();
       
    }

    @isTest
    static void testGenerateLogCallout(){

        OutboxUtility ou = new OutboxUtility();
        String stringMoreThan255 = 'This is dummy error message to covert the scenaionario where text is more than 255 character.This is dummy error message to covert the scenaionario where text is more than 255 character.This is dummy error message to covert the scenaionario where text is more than 255 character.';
        Test.startTest();
        ou.generateErrorLog( 'Test Clause', stringMoreThan255, '2','StackTrace','OutboxDML','Order');
        ou.generateErrorLog( stringMoreThan255, 'Test Message', '2','StackTrace','OutboxDML','Order');
		ou.generateErrorLog( 'Test Clause', 'Test Message', '2',stringMoreThan255,'OutboxDML','Order');
        ou.generateErrorLog( stringMoreThan255, stringMoreThan255, stringMoreThan255,stringMoreThan255,'OutboxDML','Order');
        
        
        Test.stopTest();
        
    }

    @isTest
    static void testGenerateLogListCallout(){
        String stringMoreThan255 = 'This is dummy error message to covert the scenaionario where text is more than 255 character.This is dummy error message to covert the scenaionario where text is more than 255 character.This is dummy error message to covert the scenaionario where text is more than 255 character.';
        List<Account> accList = new List<Account>();
        Account acct = new Account();
        
        acct.FirstName = 'Test';
        acct.LastName = 'Account';
        accList.add(acct);

        Account acct2 = new Account();
        acct2.FirstName = stringMoreThan255;
        acct2.LastName = stringMoreThan255;
        accList.add(acct2);

        List<Database.upsertResult> srList = Database.upsert(accList,false);
        OutboxUtility ou = new OutboxUtility();

        Test.startTest();
        ou.generateErrorLogLists(srList,'OutboxDML','Test', 'DML Operation');

        Test.stopTest();

    }

    @isTest
    static void testSchedule(){
        Test.setMock(HTTPCalloutMock.class, new OutboxCalloutAccountMock());
        Test.startTest();
        icOutboxSyncScheduler sh1 = new icOutboxSyncScheduler();
        string sch = '0 0 23 * * ?';
        system.schedule ('Test check', sch, sh1);
        Test.stopTest();
    }

    @istest
    static void testschedulewithException() {
        
        Test.StartTest();
        icOutboxSyncScheduler sh1 = new icOutboxSyncScheduler();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    
    }

}