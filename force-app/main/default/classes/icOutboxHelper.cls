/****************************************
* Author : Incloud - Sahil Goyal
* Date: 2024-07-15
****************************************/
public class icOutboxHelper {    
    public static final String ACCOUNT = 'Account';
    public static final String CONTACT = 'Contact';
    public static Schema.SObjectField extFld;
    
    // salesforce describe call 
    public static Map<String, SObjectType> globalDescribe {
        get { 
            if(globalDescribe == null) 
                globalDescribe = Schema.getGlobalDescribe();
            return globalDescribe;
        }set;
    }

    // update the parameter retrieved from the metadata with variable to actual value
    public static String updateParameter(String param,List<String> paramList){
        String paramSetting = param;
        Integer i =1;
        //Todo error handling for extra or  less paramlist
        for(String prm : paramList){
            String pVar = 'p'+i;
            
            paramSetting = String.isNotBlank(prm) ? paramSetting.replace(pVar, prm) : paramSetting.replace(pVar, '');
            i++;
        }
        return paramSetting;
    }
    
    // This method convert the infromation retreived in the the wrapper for the respective object to salesforce object and upsert the record based on external ids
    public static List<sObject> addObject(OutboxWrapper outWrap, String objectApiName){
        System.debug('outwrap ' + outwrap);   
        System.debug('objectApiName ' + objectApiName);

        Id paRecordTypeId;
        //Schema.SObjectField extFld;
        Boolean isCompanyMissingFromBA = false;        
        List<sObject> returnObjList = new List<sObject>();
        Schema.SObjectType sobjType = globalDescribe.get(objectApiName);
        
        OutboxWrapper.Rows rws = outWrap.rows;
        
        if(objectApiName == ACCOUNT) {
            paRecordTypeId = sobjType.getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        } else if(objectApiName == CONTACT) {
            paRecordTypeId = sobjType.getDescribe().getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
            sobjType =  globalDescribe.get(ACCOUNT);
        }
        
        
        try {
            Map<String,Outbox_Field_Mapping__mdt> fieldNodeAPIMap = OutboxHelper.getcolumnMapforObject(objectApiName, outWrap.columnDefList);
            //Map<String,String> fieldNameCardinalNumMap = OutboxHelper.getcolumnName(objectApiName,outWrap.columnDefList);
            for(OutboxWrapper.Row rw : rws.rowList) {
                sObject sObj = sobjType.newSObject();
                
                
                for(String columnNumber : fieldNodeAPIMap.keySet()){    
                    OutboxUtility ou = new OutboxUtility();
                    
                    Outbox_Field_Mapping__mdt ofd = new Outbox_Field_Mapping__mdt();
                    ofd = fieldNodeAPIMap.get(columnNumber);
                    String fieldValue = rw.column.get(columnNumber);
                    if(ofd.Outbox_Attribute_Name__c == 'ownerCompanyName' && objectApiName == CONTACT) {
                        isCompanyMissingFromBA = true;
                        continue;
                    }
                    
                    if(ofd.IsFormulaField__c){
                        List<String> columnList = ofd.Outbox_Attribute_Name__c.split(';');
                        fieldValue='';
                        for(String col : columnList){
                            fieldValue += rw.column.get(col);
                        } 
                        
                        system.debug(fieldValue);
                    }
                    if(ofd != null && fieldValue != null ){
                        
                        Object fv = ou.convertdatatype(ofd.Data_type__c, fieldValue);
                        sObj.put(ofd.Field_Api_Name__c,fv);
                        if(ofd.Data_type__c == 'ExternalId'){
                            extFld = ou.getExternalField( ofd.Field_Api_Name__c, sobjType);
                        }
                    }
                    
                }
                if(objectApiName == ACCOUNT) {
                    sObj.put('RecordTypeId',paRecordTypeId);
                }
                
                returnObjList.add(sObj);
            }
            
            /*List< Database.upsertResult> srList = Database.upsert(objectList, extFld, false);
            System.debug('srList ' + srList);
            OutboxUtility ou = new OutboxUtility();
            ou.generateErrorLogLists(srList, objectApiName, 'icOutboxHelper', 'DML Operation');
            if(isCompanyMissingFromBA) {
                String param='' ; //TODO get the param from  OutboxHelper.updateParameter
                ou.generateErrorLog( 'Insert Business Account', 'Outbox Response for Contact contains contact with no company Name. Param to retrieve BA'+param, '','','icOutboxHelper',objectApiName);
            }*/
            
        } 
        catch (Exception e) {
            OutboxUtility ou = new OutboxUtility();
            ou.generateErrorLog( String.valueOf(e.getCause()), String.valueOf(e.getMessage()), String.valueOf(e.getLineNumber()),String.valueOf(e.getStackTraceString()),'icOutboxHelper',objectApiName);
        }
        
        return returnObjList;
    }
}