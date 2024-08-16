public class RepcodeTriggerHandler {

    public static void insertRepcodeId(Set<Id> repcodeIds){

        List<Repcode__c> repCodes = [Select Id, Name, RepcodeId__c from Repcode__c where Id in :repcodeIds];
        
        Group groupRec;
        List<Group> groupList = [SELECT Id, Name FROM Group WHERE Name = 'Support Team' LIMIT 1];
        
        if (groupList.size() > 0) {
            groupRec = groupList[0];
        } else {
            List<Group> newGroupList = new List<Group>();
            Integer groupCount = [Select count() from Group where Name LIKE 'Support Team%'];
            String newGroupName = 'Support Team';
            
            if(groupCount > 0){
                newGroupName += '-' + groupCount; 
            }
            
            newGroupList.add(new Group(Name = newGroupName, Type = 'Regular'));
            
            insert newGroupList;
            groupRec = newGroupList[0];
        }
        
        for(Repcode__c repCodeRec : repCodes){
            repCodeRec.RepcodeId__c = groupRec.Id;
            System.debug('repCodeRec.RepcodeId__c = ' + repCodeRec.RepcodeId__c);
        }
    }
    
    public static void preventRepcodeDelete(Set<Id> repcodeIds){
        
        List<Repcode__c> existingRepCodes = [Select Id, Name, RepcodeId__c from Repcode__c where Id in :repcodeIds];
        List<Group> groupRec = [SELECT Id, Name FROM Group WHERE Name = 'Support Team' LIMIT 1];
        
        if (groupRec.size() > 0) {
            List<Repcode__Share> repShareToRemove = [Select Id, UserOrGroupId from Repcode__Share where UserOrGroupId = :groupRec[0].Id];
            
            if(repShareToRemove.size() > 0){
                delete repShareToRemove;
            }
            
            delete groupRec[0];
        }
    }
}
