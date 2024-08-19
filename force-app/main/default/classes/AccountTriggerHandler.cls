public class AccountTriggerHandler {
  /*  public static void handleAfterInsert(List<Account> newAccounts) {
        List<AccountShare> shareRecords = new List<AccountShare>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        
        for (Account acc : newAccounts) {
            if (acc.Rep_Code__c != null) {
                accountMap.put(acc.Id, acc);
            }
        }
        
        if (!accountMap.isEmpty()) {
            List<GroupMember> groupMembers = [
                SELECT GroupId
                FROM GroupMember
                WHERE UserOrGroupId IN (SELECT Id FROM {AUTHOR_PLACEHOLDER}
                AND Group.Name LIKE 'Rep_Code%'
            ];
            
            for (GroupMember grpMember : groupMembers) {
                for (Id accountId : accountMap.keySet()) {
                    if (accountMap.get(accountId).Rep_Code__c == grpMember.GroupId) {
                        AccountShare accShare = new AccountShare();
                        accShare.AccountId = accountId;
                        accShare.UserOrGroupId = grpMember.GroupId;
                        accShare.AccountAccessLevel = 'Edit';
                        accShare.OpportunityAccessLevel = 'Read';
                        shareRecords.add(accShare);
                    }
                }
            }
            
            if (!shareRecords.isEmpty()) {
                insert shareRecords;
            }
        }
    }
    
    public static void handleAfterUpdate(List<Account> accounts, Map<Id, Account> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        
        for (Account acc : accounts) {
            if (acc.Rep_Code__c != null && acc.Rep_Code__c != oldMap.get(acc.Id).Rep_Code__c) {
                accountIds.add(acc.Id);
            }
        }
        
        if (!accountIds.isEmpty()) {
            List<AccountShare> sharesToDelete = [
                SELECT Id
                FROM AccountShare
                WHERE AccountId IN :accountIds
                AND UserOrGroupId LIKE 'Rep_Code%'
            ];
            
            if (!sharesToDelete.isEmpty()) {
                delete sharesToDelete;
            }
            
            List<AccountShare> shareRecords = new List<AccountShare>();
            Map<Id, Account> accountMap = new Map<Id, Account>([
                SELECT Rep_Code__c
                FROM Account
                WHERE Id IN :accountIds
            ]);
            
            List<GroupMember> groupMembers = [
                SELECT GroupId
                FROM GroupMember
                WHERE UserOrGroupId IN (SELECT Id FROM {AUTHOR_PLACEHOLDER}
                AND Group.Name LIKE 'Rep_Code%'
            ];
            
            for (GroupMember grpMember : groupMembers) {
                for (Id accountId : accountMap.keySet()) {
                    if (accountMap.get(accountId).Rep_Code__c == grpMember.GroupId) {
                        AccountShare accShare = new AccountShare();
                        accShare.AccountId = accountId;
                        accShare.UserOrGroupId = grpMember.GroupId;
                        accShare.AccountAccessLevel = 'Edit';
                        accShare.OpportunityAccessLevel = 'Read';
                        shareRecords.add(accShare);
                    }
                }
            }
            
            if (!shareRecords.isEmpty()) {
                insert shareRecords;
            }
        }
    }*/
}