public class Hello_World {    
 public void printmessage(string msg){
     System.debug(msg);  
    }
    Public String getDay(Integer dayNumber){
        String dayString='';
        switch on dayNumber {
            when 0{
                dayString = 'Sunday';
            }
            when 1{
                dayString = 'Monday';
            }
            when 2{
                dayString = 'Tuesday';
            }
            when 3{
                dayString = 'Wednesday';
            }
            when 4{
                dayString = 'Thursday';
            }
            when 5{
                dayString = 'Friday';
            }
            when 6{
                dayString = 'Saturday';
            }
            when else{
                dayString = 'Invalid day number';
            }
            
        }
        return dayString;
    }
}