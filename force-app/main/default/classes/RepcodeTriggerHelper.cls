public class RepcodeTriggerHelper {

    Public static Group assignGroup(Repcode__c repCode){
        	String groupName = '';
            groupName = repCode.Id + '_' + repCode.Name;
            Group newGroup = new Group(Name = groupName, Type = 'Regular');
        	return newGroup;

    }
}