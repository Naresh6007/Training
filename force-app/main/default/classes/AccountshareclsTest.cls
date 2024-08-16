@isTest
private class AccountshareclsTest {

@isTest
    static void testShareAccountsWithRepCodeTeamMembers() {
        User testUser1 = [Select Id, Email From User Where Email = {EMAIL_PLACEHOLDER}' WITH USER_MODE LIMIT 1];
        User testUser2 = [Select Id, Email From User Where Email = {EMAIL_PLACEHOLDER}' WITH USER_MODE LIMIT 1];
        Rep_Code__c testRepCode = [Select Id from Rep_Code__c WITH USER_MODE LIMIT 1];
        
        // Create Rep_Code_Team__c records
        Rep_Code_Team__c testTeamMember1 = new Rep_Code_Team__c(
            Rep_Code__c = testRepCode.Id,
            UserId__c = testUser1.Id
        );
        
        Rep_Code_Team__c testTeamMember2 = new Rep_Code_Team__c(
            Rep_Code__c = testRepCode.Id,
            UserId__c = testUser2.Id
        );
        Database.insert(new List<Rep_Code_Team__c>{testTeamMember1, testTeamMember2}, false, accesslevel.USER_MODE);

        // Create test accounts
        Account testAccount = new Account(
            Name = 'Test Account',
            Rep_Code__c = testRepCode.Id
        );
        Database.insert(testAccount, false, accesslevel.USER_MODE);

        // Call the method to be tested
        Test.startTest();
        System.runAs(testUser1) {
            AccountSharecls.shareAccountsWithRepCodeTeamMembers(new Set<Id>{testRepCode.Id});
        }
        Test.stopTest();

        // Verify the sharing rules
        List<AccountShare> accountShares = [SELECT Id FROM AccountShare WHERE AccountId = :testAccount.Id and UserOrGroupId IN :new List<Id>{testUser1.Id, testUser2.Id} WITH USER_MODE];
        System.assertEquals(2, accountShares.size(), 'Expected both users to be shared on the account');
    }}