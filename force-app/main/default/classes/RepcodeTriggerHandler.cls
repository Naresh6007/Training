public class RepcodeTriggerHandler {

    public static void insertRepcodeId(List<Repcode__c> newListRepCodes ){
        
        
        List<Group> newgroupList = new List<Group>();
        List<String> groupNames = new List<String>();
        String groupName = '';
        for (Repcode__c repCode : newListRepCodes) {
            // Construct the group name based on repcodeID + '_' + Name
            newGroupList.add(RepcodeTriggerHelper.assignGroup(repCode));
        }
        // Insert all new groups in one DML operation
        if (!newGroupList.isEmpty()) {
            insert newGroupList;
        }
    }
    
    public static void preventRepcodeDelete(Set<Id> repcodeIds) {
        List<Repcode__c> existingRepCodes = [SELECT Id, Name FROM Repcode__c WHERE Id IN :repcodeIds];
        List<String> groupNamesToDelete = new List<String>();

        for (Repcode__c repCode : existingRepCodes) {
            String groupName = repCode.Id + '_' + repCode.Name;
            groupNamesToDelete.add(groupName);
            System.debug('Constructed Group Name: ' + groupName);
        }

        if (!groupNamesToDelete.isEmpty()) {
            deleteGroupsAsync(groupNamesToDelete);
        }
    }

    @future
    public static void deleteGroupsAsync(List<String> groupNamesToDelete) {
        List<Group> groupsToDelete = [SELECT Id, Name FROM Group WHERE Name IN :groupNamesToDelete];
        System.debug('Groups to Delete: ' + groupsToDelete);
        
        if (!groupsToDelete.isEmpty()) {
            delete groupsToDelete;
        }
    }

}