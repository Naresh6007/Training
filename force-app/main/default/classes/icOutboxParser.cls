/****************************************
* Author : Incloud - Sahil Goyal
* Date: 2024-07-15
****************************************/
public class icOutboxParser {

    //Returning the client secret retrive from the authentication callout
    public static String getAuthenResponse(String response){
        // Parse the JSON response 
        DOM.Document doc=new DOM.Document();
        String clientSecret ;
        try{
            doc.load(response);
            DOM.XmlNode rootNode=doc.getRootElement();
            
            if (rootNode.getNodeType() == DOM.XMLNodeType.ELEMENT) {
                clientSecret = rootNode.getText().trim();
            }
        } catch (Exception e) {
            OutboxUtility ou = new OutboxUtility();
            ou.generateErrorLog( String.valueOf(e.getCause()), String.valueOf(e.getMessage()), String.valueOf(e.getLineNumber()),String.valueOf(e.getStackTraceString()),'icOutboxParser','Authentication Parsing');
        }
		return clientSecret;
    }

    public static OutboxWrapper getObjectRecords(String response) {
        OutboxWrapper outboxWrapper = new OutboxWrapper();
        DOM.Document doc = new DOM.Document();
        
        try {
            doc.load(response);
            DOM.XmlNode rootNode = doc.getRootElement();

            if (rootNode == null) {
                return null;
            }
            
            Dom.XmlNode returnXmlNode = getElement(rootNode, 'returnXml');
            if (returnXmlNode == null) {
                return null;
            }

            // Validate status
            if (!isValidStatus(returnXmlNode)) {
                return null;
            }
            
            // Navigate to rowSet node
            DOM.XmlNode parametersReturnNode = getElement(returnXmlNode, 'parametersReturn');
            if (parametersReturnNode == null) {
                return null;
            }

            // Parse column definitions and rows
            DOM.XmlNode rowSetNode = getElement(parametersReturnNode, 'rowSet');
            if (rowSetNode != null) {
                outboxWrapper = parseRowSet(rowSetNode);
            }
            
        } catch (Exception e) {
            logError(e, 'icOutboxParser', 'getObjectRecords');
            outboxWrapper = null;
        }
        
        return outboxWrapper;
    }
    
    private static Boolean isValidStatus(DOM.XmlNode rootNode) {
        DOM.XmlNode methodStatusNode = getElement(rootNode, 'methodStatus');
        if (methodStatusNode == null) {
            return false;
        }
        
        DOM.XmlNode statusTypeNode = getElement(methodStatusNode, 'statusType');
        return (statusTypeNode != null && statusTypeNode.getText() == 'success');
    }
    
    private static DOM.XmlNode getElement(DOM.XmlNode parent, String name) {
        if (parent == null) {
            return null;
        }
        for (DOM.XmlNode child : parent.getChildElements()) {
            if (child.getName() == name) {
                return child;
            }
        }
        return null;
    }
    
    private static OutboxWrapper parseRowSet(DOM.XmlNode rowSetNode) {
        OutboxWrapper outboxWrapper = new OutboxWrapper();
        outboxWrapper.columnDefList = new List<OutboxWrapper.ColumnDefinition>();
        outboxWrapper.rows = new OutboxWrapper.Rows();
        outboxWrapper.rows.rowList = new List<OutboxWrapper.Row>();
        
        for (DOM.XmlNode child : rowSetNode.getChildElements()) {
            if (child.getName() == 'columnDefinitions') {
                outboxWrapper.columnDefList = parseColumnDefinitions(child);
            } else if (child.getName() == 'rows') {
                outboxWrapper.rows.rowList = parseRows(child);
            }
        }
        
        return outboxWrapper;
    }
    
    private static List<OutboxWrapper.ColumnDefinition> parseColumnDefinitions(DOM.XmlNode columnDefinitionsNode) {
        List<OutboxWrapper.ColumnDefinition> columnDefList = new List<OutboxWrapper.ColumnDefinition>();
        for (DOM.XmlNode columnDefinitionNode : columnDefinitionsNode.getChildElements()) {
            OutboxWrapper.ColumnDefinition columnDef = new OutboxWrapper.ColumnDefinition();
            //columnDef.columnHeading = getChildElementText(columnDefinitionNode, 'columnHeading');
            columnDef.columnName = getChildElementText(columnDefinitionNode, 'columnName');
            columnDef.columnOrdinal = getChildElementText(columnDefinitionNode, 'columnOrdinal');
            //columnDef.columnFlags = getChildElementText(columnDefinitionNode, 'columnFlags');
            //columnDef.columnSize = getChildElementText(columnDefinitionNode, 'columnSize');
            //columnDef.columnType = getChildElementText(columnDefinitionNode, 'columnType');
            //columnDef.columnPrecision = getChildElementText(columnDefinitionNode, 'columnPrecision');
            //columnDef.columnScale = getChildElementText(columnDefinitionNode, 'columnScale');
            columnDefList.add(columnDef);
        }
        return columnDefList;
    }
    
    private static List<OutboxWrapper.Row> parseRows(DOM.XmlNode rowsNode) {
        List<OutboxWrapper.Row> rowList = new List<OutboxWrapper.Row>();
        for (DOM.XmlNode rowNode : rowsNode.getChildElements()) {
            OutboxWrapper.Row row = new OutboxWrapper.Row();
            row.column = new Map<String, String>();
            for (Integer i = 0; i < rowNode.getChildElements().size(); i++) {
                DOM.XmlNode columnNode = rowNode.getChildElements()[i];
                row.column.put('c' + i, columnNode.getText().trim());
            }
            rowList.add(row);
        }
        return rowList;
    }
    
    private static String getChildElementText(DOM.XmlNode parent, String childName) {
        DOM.XmlNode child = getElement(parent, childName);
        return (child != null) ? child.getText().trim() : null;
    }
    
    private static void logError(Exception e, String className, String methodName) {
        OutboxUtility ou = new OutboxUtility();
        ou.generateErrorLog(
            String.valueOf(e.getCause()),
            String.valueOf(e.getMessage()),
            String.valueOf(e.getLineNumber()),
            String.valueOf(e.getStackTraceString()),
            className,
            methodName
        );
    }
}