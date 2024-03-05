@RestResource(urlMapping='/Accounts/*/contacts') // This annotation defines a REST resource with the specified URL mapping
global class AccountManager {
    @HttpGet // This annotation indicates that the method can be invoked using an HTTP GET request
    global static Account getAccount() {
        // Get the account ID from the request URI
        RestRequest req = RestContext.request;
        String accId = req.requestURI.substringBetween('Accounts/', '/contacts');
        
        // Query for the account and its related contacts
        Account acc = [SELECT Id, Name, (SELECT Id, Name FROM Contacts) 
                       FROM Account WHERE Id = :accId];
        
        // Return the account
        return acc;
    }
}