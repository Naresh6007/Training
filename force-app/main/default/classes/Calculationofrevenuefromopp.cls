public class Calculationofrevenuefromopp {
	//Method to calculate generated revenues from the closed-won opportunites.
    public static void calculatetotalrevenue(List<opportunity> opportunities){
      	Decimal totalRevenue = 0;
		
        //iterate through each opportunity
        for(Opportunity opp: opportunities){
            if (opp.StageName == 'Closed won'){
              totalRevenue =+ opp.Amount != null ? opp.amount:0;
                
            }
        }
       
       
    }
}