/****************************************
* Author : Incloud - Sahil Goyal
* Date: 2024-07-15
****************************************/
public class icOutboxSyncQueueable implements Queueable, Database.AllowsCallouts {
    private icOutboxIntegrationContext context;
    
    public icOutboxSyncQueueable(icOutboxIntegrationContext context){
        if(String.isBlank(context.lastRunDate)) {
            context.lastRunDate = String.valueOf(context.outboxObj.Last_Run_Time__c);
            //context.lastRunDate = '2024-06-16 05:00:00';
        }
        this.context = context;
    }
    
     //Async call to fetch the data for the respective object
    public void execute(QueueableContext context) {
        this.context.totalQueableCount++;
		System.debug(this.context.outboxObjName + ' execute method starts...');
        
        try {
            
            icOutboxServiceCallout.getOutboxDataSync(this.context);
            
            if(!this.context.done && !Test.isRunningTest()) {
                icOutboxSyncQueueable nexRun = new icOutboxSyncQueueable(this.context);
                System.enqueueJob(nexRun);
            }else{
                System.debug('All Information Synced Successfully...' + JSON.serialize(this.context));
                //updateCustomMetadata(this.context.outboxObjName, this.context.outboxObj.MasterLabel);
                //sendEmail();
            }

            System.debug('###Limits.getLimitHeapSize(): '+ Limits.getLimitHeapSize());
            System.debug('###Limits.getHeapSize(): '+ Limits.getHeapSize());
        } catch (Exception e) {
            OutboxUtility ou = new OutboxUtility();
            ou.generateErrorLog( String.valueOf(e.getCause()), String.valueOf(e.getMessage()), String.valueOf(e.getLineNumber()),String.valueOf(e.getStackTraceString()), 'icOutboxSyncQueueable','Fetching Records from Outbox ' + this.context.outboxObjName + ' API');
        }
    }
    
    @future 
    private static void updateCustomMetadata(String devName, String labelName) {
        Map<String, Object> metadataFieldValueMap = new Map<String, Object>();
        metadataFieldValueMap.put('Last_Run_Time__c', System.now());
        icCustomMetadataUtils.updateCustomMetadata('Outbox_Object_API__mdt', devName, labelName, metadataFieldValueMap); 
    }
    
    private static void sendEmail(String body) {
        List<String> toAddresses = new List<String>();
        toAddresses.addAll(Label.Error_Email_Addresses.split(','));
        
        Messaging.SingleEmailMessage mailTo = new Messaging.SingleEmailMessage();
        mailTo.setToAddresses(toAddresses);
        mailTo.setSenderDisplayName('Salesforce Automation');
        mailTo.setSubject('Outbox Sync Job Summary Report');
        mailTo.setSaveAsActivity(false);
        
        /*mailTo.HTMLBody = 'Total records fetch from '+context.lastRunDate+': ' + context.totalRecordCount + '<br/>'
            + 'Total Processed Records: ' + context.totalProcessCount + '<br/>'
            + 'Total Skipped Records: ' + context.totalSkipCount + '<br/>'
            + 'Total Successed Records: ' + context.totalSuccessCount + '<br/>'
            + 'Total Failed records: ' + context.totalFailCount + '<br/><br/>'
            + '<p>The following error(s) occurred: <br/>'+ JSON.serialize(context.totalFailedMsgs).replace('","', '') 
            + '<br/>Total Queueable calls: ' + context.totalQueableCount + ' Total API calls: ' + context.totalCalloutCount + '<br/><br/>'
            + '<p/>Best regards,<br/>Salesforce automation.<br/>';*/
        mailTo.HTMLBody = body;
        
        try{
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mailTo});
            
            if(results[0].success){
                System.debug('The email was sent successfully.');
            }else{
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }catch(Exception e){
            System.debug('Single email is not enabled for your organization or profile.');
            return;
        }
    }
}