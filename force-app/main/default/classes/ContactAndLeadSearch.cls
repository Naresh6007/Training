public class ContactAndLeadSearch {
	public static List<List<Sobject>> searchContactsAndLeads(String name){
        List<List<sObject>> searchResults = new List<List<sObject>>();
        List<List<sObject>> searchList = [FIND :name IN ALL FIELDS
                    RETURNING Contact(Id, FirstName, LastName), Lead(Id, FirstName, LastName)];
        List<sObject> contactList = new List<sObject>();
        List<sObject> leadList = new List<sObject>();
        for (List<sObject> searchResultsList : searchList) {
            for (sObject record : searchResultsList) {
                if (record instanceof Contact) {
                    contactList.add(record);
                } else if (record instanceof Lead) {
                    leadList.add(record);
                }
            }
        }

        searchResults.add(contactList);
        searchResults.add(leadList);
        
        return searchResults;        
    }
}