/****************************************
* Author : Incloud - Sahil Goyal
* Date: 2024-07-15
****************************************/
public class icOutboxIntegrationContext {
    public Outbox_Object_API__mdt outboxObj;
    public String lastRunDate {get;set;}
    public String outboxObjName {get;set;}
    public String sfObjAPIName {get;set;}
    public String lastKey {get;set;}
    public Integer recordLimit {get;set;}
    
    public Integer totalQueableCount {get;set;}
    public Integer totalCalloutCount {get;set;}
    public Boolean done {get;set;}
    
    public icOutboxIntegrationContext(Outbox_Object_API__mdt outboxObj){
        this.lastKey = '';
        this.outboxObj = outboxObj;
        this.outboxObjName = outboxObj.DeveloperName;
        this.sfObjAPIName = outboxObj.SF_Object_API_Name__c;
        this.recordLimit = Integer.valueOf(outboxObj.Retrieve_Limit__c);
        
        this.totalQueableCount = 0;
        this.totalCalloutCount = 0;
        this.done = false;
    }
}