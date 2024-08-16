trigger RepcodeTrigger on Repcode__c (after insert,before delete){
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
           // RepcodeTriggerHandler.insertRepcodeId(Trigger.newMap.keySet());
        }
        if (Trigger.isDelete) {
           // RepcodeTriggerHandler.preventRepcodeDelete(Trigger.oldMap.keySet());
        }
    }
}