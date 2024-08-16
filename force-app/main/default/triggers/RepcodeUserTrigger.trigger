/**
* @name: RepcodeUserTrigger 
* Developed by: Naresh Kumar
* @After insert- Create a public Group Member
* @Before Update - Duplicate check repcode id or user name
* @After update- Add member to public Groups
* @Before delete- Rep code user once deleted, remove the public Group member
*/
trigger RepcodeUserTrigger on RepCodeUser__c (before insert, after insert, before update, after update, before delete) {
   if((Trigger.isInsert  || Trigger.isUpdate) && Trigger.isBefore) {
        // Calls the handler class method with Trigger.newMap condition
        RepcodeUserTriggerHandler.duplicateCheckRepUser(Trigger.new);
    }
    if(Trigger.isInsert  && Trigger.isAfter) {
        // Calls the handler class method with Trigger.newMap condition
        RepcodeUserTriggerHandler.createPublicGroupMember(Trigger.newMap.keyset());
    }
    if(Trigger.isUpdate  && Trigger.isAfter ) {
        // Calls the handler class method with Trigger.newMap condition
        RepcodeUserTriggerHandler.AddMemberToPublicGroup(Trigger.oldMap,Trigger.new);
    }
    if(Trigger.isUpdate  && Trigger.isbefore ) {
        RepcodeUserTriggerHandler.removeMemberFromPublicGroup(Trigger.oldMap,Trigger.newMap,Trigger.newMap.keyset());
     }
    if(Trigger.isDelete  && Trigger.isBefore) {
        // Calls the handler class method with Trigger.oldMap condition
        RepcodeUserTriggerHandler.removeGroupMemberForDelete(Trigger.oldMap.keyset());
    }
}