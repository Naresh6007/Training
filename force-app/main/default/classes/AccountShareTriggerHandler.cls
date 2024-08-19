public class AccountShareTriggerHandler {
    public static void handleAfterInsert(Set<Id> newRecordIds){
        
        // Collect unique group names from new records
        List<Account> newRecords = RepCodeUserSoqlUtility.getAccountList(newRecordIds);
        insertAccountShareRecords(newRecords);
    }
    public Static void insertAccountShareRecords(List<Account> newRecords){
        Set<String> groupNames = new Set<String>();
        Map<String, Id> groupNameToIdMap = new Map<String, Id>();
        Set<String> repcodeIds = new Set<String>();
        try{
        for (Account newRecord : newRecords) {
            if (newRecord.RepCode__c != null  && newRecord.RepCode__r.name != null) {
                groupNames.add(newRecord.RepCode__c + '_' + newRecord.RepCode__r.name);
            }
        }
        system.debug('groupNames ='+groupNames);
        // Query to get Group IDs for the collected group names
        if (!groupNames.isEmpty()) {
            for (Group grp : RepCodeUserSoqlUtility.getGroupList(groupNames)) {
                groupNameToIdMap.put(grp.name, grp.Id);
            }
        }
            system.debug('groupNameToIdMap =='+groupNameToIdMap);
        List<AccountShare> accountShareList = new List<AccountShare> ();
        for (Account newRecord : newRecords) {
            if (newRecord.RepCode__c != null && newRecord.RepCode__r.Name != null) {
                String groupName = newRecord.RepCode__c + '_' + newRecord.RepCode__r.Name;
                system.debug('groupName ---'+groupName);
                Id groupId = groupNameToIdMap.get(groupName);
                AccountShare accShare = new AccountShare();
                accShare.AccountId =newRecord.id;
                accShare.UserOrGroupId=groupId;
                accShare.AccountAccessLevel = 'Edit';
                accShare.OpportunityAccessLevel = 'Edit';
                accShare.CaseAccessLevel = 'Read';
                accountShareList.add(accShare);
            }
        }
        if(accountShareList != null && accountShareList.size()>0){
            system.debug('accountShareList == '+accountShareList);
            insert accountShareList;
        }
        }
        catch(Exception e){
            
        }
    }
    
    public static void handleAfterUpdate(Set<Id> newRecordIds,List<Account> newRecords , Map<id,Account> oldMap ){
        Set<Id> accountIdForDeleteShare = new Set<Id>();
        Set<Id> accountIdForCreateShare = new Set<Id>();
        Set<Id> accountIdToQuery = new Set<Id>();
        List<Account> accountListToCreateShare = new List<Account>();
        for(Account accRec :newRecords){
            
            if(accRec.RepCode__c != oldMap.get(accRec.id).RepCode__c && accRec.RepCode__c != null){
                accountIdForCreateShare.add(accRec.id);
                accountIdToQuery.add(accRec.id);
            }
        }
        Map<Id,Account> accRecMap  = RepCodeUserSoqlUtility.getAccountMap(accountIdToQuery);
        system.debug('accountIdForCreateShare == '+accountIdForCreateShare);
        for( Id accid :accountIdForCreateShare){
         accountListToCreateShare.add(accRecMap.get(accid));
            if(accountListToCreateShare != null && accountListToCreateShare.size() >0)
            {
                insertAccountShareRecords(accountListToCreateShare);
            }
        }
    }
    
    public static void handleBeforeUpdate(Set<Id> newRecordIds,List<Account> newRecords , Map<id,Account> oldMap ){
        Set<Id> accountIdForDeleteShare = new Set<Id>();
       
        Set<Id> accountIdToQuery = new Set<Id>();
        List<Account> accountListToCreateShare = new List<Account>();
        for(Account accRec :newRecords){
            if(accRec.RepCode__c != oldMap.get(accRec.id).RepCode__c && oldMap.get(accRec.id).RepCode__c != null){
                accountIdForDeleteShare.add(accRec.id);
                accountIdToQuery.add(accRec.id);
            }
            
        }
        Map<Id,Account> accRecMap  = RepCodeUserSoqlUtility.getAccountMap(accountIdToQuery);
        if(accountIdForDeleteShare != null)
        {
            AccountShareTriggerHandler.deleteOldShareRec(accRecMap,accountIdForDeleteShare);
        }
        
    }
    
    public static void deleteOldShareRec(Map<Id,Account> accRecMap , Set<Id> accountIdForDeleteShare){
        Set<String> groupNameList = new Set<String>();
        Map<String, Id> groupNameToIdMap = new Map<String, Id>();
        Map<Id, String> accIdWithGroupName= new Map<Id, String>();
        Map<String,AccountShare> accShareMapWithCombKey = new Map<String,AccountShare>();
        for( Id accRecId : accountIdForDeleteShare){
            Account accRec =accRecMap.get(accRecId);
            String groupName = accRec.RepCode__c + '_' + accRec.RepCode__r.name ;
            system.debug('accRec.RepCode__r.name'+accRec.RepCode__r.name);
            groupNameList.add(groupName);
            accIdWithGroupName.put(accRec.id,groupName);
        }
        system.debug('groupNameList =='+groupNameList);
        if (!groupNameList.isEmpty()) {
            for (Group grp : RepCodeUserSoqlUtility.getGroupList(groupNameList)) {
                groupNameToIdMap.put(grp.name, grp.Id);
            }
        }
        system.debug('groupNameToIdMap ='+groupNameToIdMap);
        List<AccountShare> accountShareList = RepCodeUserSoqlUtility.getaccountShareList(accIdWithGroupName.keySet(),groupNameToIdMap.values());
        
        for(AccountShare accShare :accountShareList){
            accShareMapWithCombKey.put(accShare.AccountId + '_'+accShare.UserOrGroupId,accShare);
        }
        List<AccountShare> accountShareToDelete = new List<AccountShare>();
        for( Id accRecId : accountIdForDeleteShare){
            if(groupNameToIdMap != null){
                Id groupId =  groupNameToIdMap.get(accIdWithGroupName.get(accRecId));
                if(accShareMapWithCombKey != null && accShareMapWithCombKey.containsKey(accRecId +'_' +groupId)){
                    accountShareToDelete.add(accShareMapWithCombKey.get(accRecId +'_' +groupId));
                }
            }
        }
        system.debug('accountShareToDelete =='+accountShareToDelete);
        if(accountShareToDelete != null && accountShareToDelete.size()>0){
            delete accountShareToDelete ;
        }
    }
}