public with sharing class Accountsharecls {
        // Constants for Access Levels
        private static final String ACCOUNT_ACCESS_LEVEL = 'Edit';
        private static final String OPPORTUNITY_ACCESS_LEVEL = 'Read';
        
        public static void shareAccountsWithRepCodeTeamMembers(Set<Id> repCodeIds){
            if(repCodeIds == null || repCodeIds.isEmpty()){
                return;
            }
    
            try {
                List<AccountShare> accountShares = new List<AccountShare>();
                Map<Id, Rep_Code__c> repCodeMap = new Map<Id, Rep_Code__c>([
                    SELECT Id, Rep_Code__c, (SELECT UserId__c FROM Rep_Code_Team__r)
                    FROM Rep_Code__c
                    WHERE Id IN :repCodeIds
                ]);
    
                List<Account> accounts = [
                    SELECT Id, Rep_Code__c
                    FROM Account 
                    WHERE Rep_Code__c IN :repCodeIds
                ];
    
                for(Account acc : accounts) {
                    Rep_Code__c repCode = repCodeMap.get(acc.Rep_Code__c);
                    if (repCode != null && repCode.Rep_Code_Team__r != null) {
                        for(Rep_Code_Team__c teamMember : repCode.Rep_Code_Team__r){
                            if(teamMember.UserId__c != null){
                                AccountShare accountShare = new AccountShare();
                                accountShare.AccountId = acc.Id;
                                accountShare.UserOrGroupId = teamMember.UserId__c;
                                accountShare.AccountAccessLevel = ACCOUNT_ACCESS_LEVEL;
                                accountShare.OpportunityAccessLevel = OPPORTUNITY_ACCESS_LEVEL;
                                accountShares.add(accountShare);
                            }
                        }
                    }
                }
                if(!accountShares.isEmpty()){
                    insert accountShares;
                }
            } catch (Exception e) {
                // Add proper logging here
                System.debug('Error in shareAccountsWithRepCodeTeamMembers: ' + e.getMessage());
            }
        }
        
    }
    
