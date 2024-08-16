public class RepCodeUserSoqlUtility {

    public static List<RepCodeUser__c>  getRepCodeUsers(Set<String> repCodes , Set<String> users){
        List<RepCodeUser__c> existingRecords = [
        SELECT Id, RepCode__c, User__c
        FROM RepCodeUser__c
        WHERE RepCode__c IN :repCodes AND User__c IN :users
    ];
        return existingRecords;
    }
    
    public static List<RepCodeUser__c>  getRepCodeUsers(Set<Id> repCodeUserId){
        List<RepCodeUser__c> existingRecords = [
        SELECT Id, RepCode__c,RepCode__r.name ,User__c
        FROM RepCodeUser__c
        WHERE id IN :repCodeUserId
    ];
        return existingRecords;
    }
    public static List<Repcode__c> repCodeList (Set<String> repCodeIds){
        List<Repcode__c> existingRepCodes = [SELECT Id, Name FROM Repcode__c WHERE Id IN :repCodeIds];
        return existingRepCodes;
    }
    
    public static List<Group> getGroupList (Set<String> groupNames){
        List<Group> existingGroupList = [SELECT Id, DeveloperName,name FROM Group WHERE name IN :groupNames];
        system.debug('existingGroupList ='+existingGroupList);
        return existingGroupList;
    }
    
    public static List<Account> getAccountList(Set<Id> accountRecId){
        List<Account> accRecList = [select id,RepCode__c,RepCode__r.name from Account where id in : accountRecId];
        
        return accRecList;
    }
    public static Map<id,Account> getAccountMap(Set<Id> accountRecId){
        Map<id,Account> accRecMap = new Map<id,Account> ([select id,RepCode__c,RepCode__r.name from Account where id in : accountRecId]);
        
        return accRecMap;
    }
    public Static List<AccountShare> getaccountShareList(Set<id> accountId,List<id> groupId){
        List<AccountShare> accountShareList = [select id,UserOrGroupId,AccountId from AccountShare where 
                                              AccountId in :accountId and UserOrGroupId in: groupId];
        return accountShareList;        
    }
    Public static List<GroupMember> getPublicGroupMember(Set<String> GroupNames){
        List<GroupMember> grpMember = [select GroupId,Group.name,UserOrGroupId from GroupMember where Group.name in: GroupNames ];
        return grpMember;
    }
}