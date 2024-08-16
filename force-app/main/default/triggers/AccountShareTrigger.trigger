trigger AccountShareTrigger on Account (before update ,after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        AccountShareTriggerHandler.handleAfterInsert(Trigger.newMap.keyset());
    } 
     if (Trigger.isAfter && Trigger.isUpdate) {
        AccountShareTriggerHandler.handleAfterUpdate(Trigger.newMap.keyset(),Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
        AccountShareTriggerHandler.handleBeforeUpdate(Trigger.newMap.keyset(),Trigger.new, Trigger.oldMap);
    }
}