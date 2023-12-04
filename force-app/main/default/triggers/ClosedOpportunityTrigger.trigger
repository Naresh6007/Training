trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {
    List <Task> taskList = new List <Task>();
    for(Opportunity opp : [Select Id, StageName FROM Opportunity WHERE StageName='Closed Won' And Id IN:Trigger.New] ){
        taskList.add(new Task(Subject='Follow Up Test Task', WhatId = Opp.Id));
    }
    if(taskList.size()>0){
        insert taskList;
    }
}