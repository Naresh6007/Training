/****************************************
* Author : Incloud - Sahil Goyal
* Date: 2024-07-15
****************************************/
global class icOutboxSyncScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        List<Outbox_Object_API__mdt> outboxObjects = [SELECT MasterLabel, DeveloperName, SF_Object_API_Name__c, ObjectName__c, Method_Name__c, Retrieve_Limit__c, 
                                                      Last_Run_Time__c, Parameter__c FROM Outbox_Object_API__mdt WHERE Is_Active__c = TRUE];
        
        for(Outbox_Object_API__mdt outObj : outboxObjects) {
            icOutboxIntegrationContext outboxContext = new icOutboxIntegrationContext(outObj);
            
            System.enqueueJob( new icOutboxSyncQueueable(outboxContext) );
        }
        
    }
}