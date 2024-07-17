public class ContactSearch {
    public static List<contact> searchForContacts(String LName, String MPostalCode){
        
        List<Contact> matchingContacts = new List<Contact>();
        
        matchingcontacts = [Select id, Name From Contact Where LastName = :LName And MailingPostalCode = :MPostalCode];
        
        return matchingcontacts;
        
    }

}