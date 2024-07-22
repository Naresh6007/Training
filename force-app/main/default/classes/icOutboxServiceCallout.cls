/****************************************
* Author : Incloud - Sahil Goyal
* Date: 2024-07-15
****************************************/
public class icOutboxServiceCallout {
    public static Outbox_Callout_Setting__c config = Outbox_Callout_Setting__c.getInstance();
    
    //Callout to fetch the records from Outbox for the object 
    public static String getOutboxDataSync(icOutboxIntegrationContext context) {
        String responseData = '';
        Integer countCallouts = 0;
        Boolean stopCallout = false;
        List<sObject> recordsToUpsert = new List<sObject>();
        
        try {
            String sessionID = getOutboxAPISessionID();

            if(String.isNotBlank(sessionID)) {
                
                HttpRequest request = getStandardRequest();
                String body = 'LogicalObjectName=' + EncodingUtil.urlEncode(context.outboxObj.ObjectName__c, 'UTF-8') +
                    '&LogicalMethodName=' + EncodingUtil.urlEncode(context.outboxObj.Method_Name__c, 'UTF-8') +
                    '&ApplicationName=' + EncodingUtil.urlEncode(config.Application_Name__c, 'UTF-8') +
                    '&SessionID=' + sessionID + '&CustomDataXML=string HTTP/1.1';
                
                while(!stopCallout) {
                    
                    List<String> paramList = new List<String>{context.lastRunDate, String.valueOf(System.now()), context.lastKey, String.valueOf(context.recordLimit)};
                    
                    System.debug('paramList::::'+paramList);
                    System.debug('paramList::::'+context.outboxObj.Parameter__c);
                    String paramString = icOutboxHelper.updateParameter(context.outboxObj.Parameter__c, paramList);
                    
                    System.debug('Main Request Body: '+ body + '&ParamXML=' + paramString);
                    
                    request.setBody(body + '&ParamXML=' + paramString);
                    
                    Http http = new Http();
                    HTTPResponse response = http.send(request);
                    
                    System.debug('Main Status Code: '+response.getStatusCode());
                    //System.debug('Main Body: '+response.getBody());
                    
                    context.totalCalloutCount++;
                    countCallouts++;
                    
                    if(response.getStatusCode() == 200) {
                        OutboxWrapper owp = icOutboxParser.getObjectRecords( response.getBody().replace('&lt;','<').replace('&gt;','>') );		//Creating error log
                        //System.debug('owp: :::::'+ owp);
                        if(owp != null) {
                            
                            if(owp.rows.rowList?.size() > 0){
                                List<sObject> objectList = icOutboxHelper.addObject(owp, context.sfObjAPIName);			//Creating error log
                                recordsToUpsert.addAll(objectList);
                                
                                if(context.recordLimit > owp.rows.rowList?.size()){
                                    context.done = true;
                                }else{
                                    context.lastKey = (String) objectList[objectList.size()-1].get('AccountNumber');
                                }
                                
                                System.debug('Found Records: '+ objectList.size());
                                System.debug('Total Records: '+ recordsToUpsert.size());
                                System.debug('lastKey: '+ context.lastKey);
                            }else {
                                // No Data Found
                                context.done = true;
                            }
                            
                            System.debug('Apex CPU Limit Before Sleep: ' + Limits.getCpuTime() + ' / '+ Limits.getLimitCpuTime());
                            delayInExecution(1000);	//sleep for 1s
                            System.debug('Apex CPU Limit After Sleep: ' + Limits.getCpuTime() + ' / '+ Limits.getLimitCpuTime());
                            
                            if(context.done){
                                //Done fetching data
                                System.debug('Done fetching data');
                                stopCallout = true;
                                break;
                            }
                            else if((Limits.getLimitCpuTime() - Limits.getCpuTime()) < 500 || countCallouts == 100 || recordsToUpsert.size() >= 5000){
                                System.debug('Stop while due to limit');
                                stopCallout = true;
                                break;
                            }
                        }
                        else{		//Creating error log
                            OutboxUtility ou = new OutboxUtility();
                            ou.generateErrorLog('Encounter Error Status in Outbox API Response', String.valueOf(response.getStatusCode()), '', response.getBody(), 'icOutboxServiceCallout', context.outboxObjName);
                            context.done = true;
                        }
                        
                    }else{			//Creating error log
                        OutboxUtility ou = new OutboxUtility();
                        ou.generateErrorLog('Bad Response from Outbox API', String.valueOf(response.getStatusCode()), '', response.getBody(), 'icOutboxServiceCallout', context.outboxObjName);
                        context.done = true;
                    }
                }
                
                System.debug('UpsertObjectList Size: '+recordsToUpsert.size());
                if(!recordsToUpsert.isEmpty()) {
                    List<Database.UpsertResult> upsertResults = Database.upsert(recordsToUpsert, icOutboxHelper.extFld, false);
                    System.debug('upsertResults ' + upsertResults);
                    List<Error_Log__c> errors = new List<Error_Log__c>();
                     for(Integer i=0; i<upsertResults.size(); i++){
                        if (!upsertResults.get(i).isSuccess()){
                            // DML operation failed
                            Database.Error error = upsertResults.get(i).getErrors().get(0);
                            Error_Log__c errorLog = new Error_Log__c();
                            errorLog.Cause__c = String.valueOf(error.getStatusCode());
                            errorLog.Message__c = error.getMessage();
                            errorLog.Class__c = (String) recordsToUpsert[i].get('AccountNumber');
                            errorLog.Origin__c = 'DML Operation';
                            errorLog.Stack_Trace__c = 'Fields: ' + error.getFields();
                            errorLog.Object_Callout_Name__c = 'Account';
                            errors.add(errorLog);
                            
                            //failedRecordMsgs.add('Account ID: '+recordsToUpsert[i].Id+'  Customer ID: '+recordsToUpsert[i].ERP_Client_ID__c+ '<br/>'+' Error Message: '+failedDML+ '<br/>');
                        }
                    }
                    
                    if(!errors.isEmpty()) {
                        Database.insert(errors, false);
                    } 
                    //OutboxUtility ou = new OutboxUtility();
                    //ou.generateErrorLogLists(upsertResults, context.sfObjAPIName, 'icOutboxServiceCallout', 'DML Operation');
                }
                
            }else {
                OutboxUtility ou = new OutboxUtility();
            	ou.generateErrorLog('', 'Session ID is Blank...', '', '', 'icOutboxServiceCallout', context.outboxObjName);
            }
            
        } catch (Exception e) {
            System.debug('Error Message: '+e.getMessage());
            System.debug('Stack Trace: '+e.getStackTraceString());
            
            OutboxUtility ou = new OutboxUtility();
            ou.generateErrorLog( String.valueOf(e.getCause()), String.valueOf(e.getMessage()), String.valueOf(e.getLineNumber()),String.valueOf(e.getStackTraceString()), 'icOutboxServiceCallout', context.outboxObjName);
            context.done = true;
        }
        System.debug('context: ' + JSON.serialize(context));

        return responseData;
    }
    
    //API callout to get the secret code from outbox which is used as parameter for record fetching callout
    private static String getOutboxAPISessionID() {
		String returnToken = '';
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:OutboxApiUrl/OEASAuth_API/service.asmx/EstablishSession');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        // Use URLENCODE method to encode parameters
        String body = 'OnyxUserName=' + EncodingUtil.urlEncode(config.Username__c, 'UTF-8') +
            '&Password=' + EncodingUtil.urlEncode(config.Password__c, 'UTF-8') +
            '&ApplicationName=' + EncodingUtil.urlEncode(config.Application_Name__c, 'UTF-8') +
            '&SourceName=' + EncodingUtil.urlEncode(config.SourceName__c, 'UTF-8') +
            '&SiteID=' + EncodingUtil.urlEncode(config.SiteID__c, 'UTF-8');
        
        request.setBody(body);
        HttpResponse response = http.send(request);
        
        System.debug('Token Status Code: ' + response.getStatusCode());
        System.debug('Token Body: ' + response.getBody());
        
        if(response.getStatusCode() == 200){
            String responseData = response.getBody();
            returnToken = icOutboxParser.getAuthenResponse(responseData);
        }else{
            OutboxUtility ou = new OutboxUtility();
            ou.generateErrorLog('Error While Session ID API Callout', String.valueOf(response.getStatusCode()), '', response.getBody(), 'icOutboxServiceCallout', 'getOutboxAPISessionID()');
        }
        
        System.debug('returnToken: '+ returnToken);
        
        return returnToken;
    }
    
    private static HttpRequest getStandardRequest() {
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint('callout:OutboxApiUrl/OEAS_API/service.asmx/Execute');
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        return request;
    }
    
    private static void delayInExecution(Integer miliseconds){
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < miliseconds) {
            finishTime = DateTime.now().getTime();
        }
    }
}