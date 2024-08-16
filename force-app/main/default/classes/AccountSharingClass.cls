public with sharing class AccountSharingClass {
    
    public static void shareAccountsWithRepCodeTeamMembers(Set<Id> repCodeIds){
        List<AccountShare> accountShares = new List<AccountShare>();
        Map<Id, Rep_Code__c> repCodeMap = new Map<Id, Rep_Code__c>([
            SELECT Id, Rep_Code__c, (SELECT UserId__c FROM Rep_Code_Team__r)
            FROM Rep_Code__c
            WHERE Id IN :repCodeIds
        ]);
        
        for(Account acc : [
            SELECT Id, Name, OwnerId, Owner.Name, Rep_Code__c
            FROM Account 
            WHERE Rep_Code__c IN :repCodeIds]
        ){
            Rep_Code__c repCode = repCodeMap.get(acc.Rep_Code__c);
            if (repCode != null && repCode.Rep_Code_Team__r != null) {
                for(Rep_Code_Team__c teamMember : repCode.Rep_Code_Team__r){
                    if(teamMember.UserId__c != null){
                        AccountShare accountShare = new AccountShare();
                        accountShare.AccountId = acc.Id;
                        accountShare.UserOrGroupId = teamMember.UserId__c;
                        accountShare.AccountAccessLevel = 'Edit';
                        accountShare.OpportunityAccessLevel = 'Read';
                        accountShares.add(accountShare);
                    }
                }
            }
        }
        if(!accountShares.isEmpty()){
            insert accountShares;
        }
    }
    
}