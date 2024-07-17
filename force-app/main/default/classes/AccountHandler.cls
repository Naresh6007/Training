public class AccountHandler {
    public static Account insertNewAccount(String accountName){
        try{
            if (string.isBlank(accountName)){
                return null;
            }
            Account newAccount = new Account(Name=accountName);
            insert newAccount;
            return newAccount;
            
        }
        catch (DmlException e) {
    		System.debug('A DML exception has occurred: ' +
                e.getMessage());
            return null;
		}
        
    }

}