@isTest
public class TestVerifyDate {
    static testmethod void testmethod1(){
        Date d = VerifyDate.CheckDates(System.today(), System.Today()+1);
        Date d1 = VerifyDate.CheckDates(System.today(), System.Today()+60);
    }

}