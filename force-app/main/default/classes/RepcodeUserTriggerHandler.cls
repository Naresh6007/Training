public class RepcodeUserTriggerHandler {
	public static List<GroupMember> grpMemberListToDelete = new List<GroupMember>();
    // Method to check for duplicate RepCodeUser__c records based on RepCodeId and UserId
    public static void duplicateCheckRepUser(List<RepCodeUser__c> newRecords) {
    // Map to store the combination of RepCode and User as keys
    Map<String, RepCodeUser__c> repCodeUserMap = new Map<String, RepCodeUser__c>();

    // Set to store the combination of RepCode and User from new records
    Set<String> repCodeUserSet = new Set<String>();
    Set<String> repCodeNameSet = new Set<String>();
    
    for (RepCodeUser__c newRecord : newRecords) {
        if (newRecord.RepCode__c != null && newRecord.User__c != null) {
           // String repCodeUserKey = newRecord.RepCode__c + ':' + newRecord.User__c;
            repCodeUserSet.add(newRecord.User__c);
            repCodeNameSet.add(newRecord.RepCode__c);
            repCodeUserMap.put(newRecord.RepCode__c + ':' + newRecord.User__c, newRecord);
            
        }
    }

    // Query to find existing records with the same RepCode and User combination
    List<RepCodeUser__c> existingRecords = RepCodeUserSoqlUtility.getRepCodeUsers(repCodeNameSet,repCodeUserSet);

    // Check for duplicates in the new records
    for (RepCodeUser__c existingRecord : existingRecords) {
        String repCodeUserKey = existingRecord.RepCode__c + ':' + existingRecord.User__c;
        if (repCodeUserMap.containsKey(repCodeUserKey)) {
            RepCodeUser__c newRecord = repCodeUserMap.get(repCodeUserKey);
            if (newRecord.Id == null  || (newRecord.Id != null && existingRecord.Id != newRecord.Id) ){
                newRecord.addError('Duplicate Rep Code and User combination found.');
            }
        }
    }
}

    public static void createPublicGroupMember(Set<Id> newRecordIds) {
    // Set to collect unique group names
    RepcodeUserTriggerHandler.insertPublicGroupMembers(newRecordIds);
}
	
    public static void addMemberToPublicGroup(Map<Id, RepCodeUser__c> oldMap,List<RepCodeUser__c> newList){
        Set<Id> repCodeUserIds = new Set<Id> () ;
        for(RepCodeUser__c repCode : newList){
            if (repCode.RepCode__c != null && repCode.User__c != null &&
               (repCode.RepCode__c != oldMap.get(repCode.id).RepCode__c || repCode.User__c != oldMap.get(repCode.id).User__c)){
                   repCodeUserIds.add(repCode.id);
               }
        }
        if(repCodeUserIds != null && repCodeUserIds.size()>0)
        {
            insertPublicGroupMembers(repCodeUserIds);
         }
    }
    public static void removeMemberFromPublicGroup(Map<Id, RepCodeUser__c> oldMap,Map<Id, RepCodeUser__c> newMap ,Set<Id> repCodeUserIds ) {
        List<RepCodeUser__c> oldRecords = RepCodeUserSoqlUtility.getRepCodeUsers(repCodeUserIds);
        Set<String> groupNames = new Set<String>();
        Map<Id,String> oldGroupNameWithUser = new Map<Id,String>();
        
        for(RepCodeUser__c oldRecord :oldRecords){
            if (oldRecord.RepCode__c != null && oldRecord.User__c != null &&
               (oldRecord.RepCode__c != newMap.get(oldRecord.id).RepCode__c || oldRecord.User__c != newMap.get(oldRecord.id).User__c)){
                String oldGroupName = oldRecord.RepCode__c + '_' + oldRecord.RepCode__r.Name;
                oldGroupNameWithUser.put(oldRecord.User__c,oldGroupName)  ; 
                groupNames.add(oldGroupName);
            }
        }
        if(groupNames != null && groupNames.size()>0 && oldGroupNameWithUser != null && oldGroupNameWithUser.size()>0){
            createListPublicGrpMemberToRemove(groupNames,oldGroupNameWithUser);
            if(grpMemberListToDelete != null && grpMemberListToDelete.size()>0 )
            deletePublicGroupMembers(JSON.serialize(grpMemberListToDelete));
        }
        system.debug('grpMemberListToDelete =='+grpMemberListToDelete);
    }

    public static void createListPublicGrpMemberToRemove(Set<String> groupNames,Map<Id,String> oldGroupNameWithUser){
         Map<String,GroupMember> olduserIdWithGroupMember = new Map<String,GroupMember>();
        if(groupNames != null && groupNames.size()>0){
            List<GroupMember> grpMemberList = RepCodeUserSoqlUtility.getPublicGroupMember(groupNames);
            for(GroupMember grpMember :grpMemberList){
                olduserIdWithGroupMember.put(grpMember.UserOrGroupId + '_'+grpMember.Group.name , grpMember);
            }
            if(olduserIdWithGroupMember != null && !olduserIdWithGroupMember.isEmpty()){
                for(Id userId :oldGroupNameWithUser.keySet()){
                    if(olduserIdWithGroupMember.containsKey(userId + '_' + oldGroupNameWithUser.get(userId))){
                        grpMemberListToDelete.add(olduserIdWithGroupMember.get(userId + '_' + oldGroupNameWithUser.get(userId)));
                    }
                }
            }
        }
    }
	
    public static void removeGroupMemberForDelete(Set<Id>repCodeUserIds) {
        List<RepCodeUser__c> oldRecords = RepCodeUserSoqlUtility.getRepCodeUsers(repCodeUserIds);
        Set<String> groupNames = new Set<String>();
        Map<Id,String> oldGroupNameWithUser = new Map<Id,String>();
        
        for(RepCodeUser__c oldRecord :oldRecords){
            String oldGroupName = oldRecord.RepCode__c + '_' + oldRecord.RepCode__r.Name;
            oldGroupNameWithUser.put(oldRecord.User__c,oldGroupName)  ; 
            groupNames.add(oldGroupName);
        }
        if(groupNames != null && groupNames.size()>0 && oldGroupNameWithUser != null && oldGroupNameWithUser.size()>0){
            createListPublicGrpMemberToRemove(groupNames,oldGroupNameWithUser);
            if(grpMemberListToDelete != null && grpMemberListToDelete.size()>0 )
            deletePublicGroupMembers(JSON.serialize(grpMemberListToDelete));
        }
    }
    
    @future
    public static void insertPublicGroupMembers(Set<Id> newRecordIds){
        Set<String> groupNames = new Set<String>();
        Map<String, Id> groupNameToIdMap = new Map<String, Id>();
        Set<String> repcodeIds = new Set<String>();
        // Collect unique group names from new records
        List<RepCodeUser__c> newRecords = RepCodeUserSoqlUtility.getRepCodeUsers(newRecordIds);
        for (RepCodeUser__c newRecord : newRecords) {
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
        // Create GroupMember records
        List<GroupMember> groupMembers = new List<GroupMember>();
        for (RepCodeUser__c newRecord : newRecords) {
            if (newRecord.RepCode__c != null && newRecord.RepCode__r.Name != null) {
                String groupName = newRecord.RepCode__c + '_' + newRecord.RepCode__r.Name;
                Id groupId = groupNameToIdMap.get(groupName);
                
                // Ensure the group exists before creating the GroupMember
                if (groupId != null) {
                    GroupMember gm = new GroupMember();
                    gm.GroupId = groupId;
                    gm.UserOrGroupId = newRecord.User__c;
                    groupMembers.add(gm);
                } else {
                    // Handle cases where the group is not found
                    newRecord.addError('Group not found for ' + groupName);
                }
            }
        }
        
        // Insert the GroupMember records if there are any
        if (!groupMembers.isEmpty()) {
           insert groupMembers;
        }
    }
    @future
    public static void deletePublicGroupMembers(String groupMemberList){
        List<GroupMember> recordsToUpdate = (List<GroupMember>) JSON.deserialize(groupMemberList, List<GroupMember>.class);
    	if(recordsToUpdate != null && recordsToUpdate.size()>0)
        delete recordsToUpdate;
    }
    
}