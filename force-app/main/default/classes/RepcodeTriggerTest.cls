@isTest
public class RepcodeTriggerTest {

    @isTest
    static void testInsertRepcode() {
        // Create test Repcode__c records
        List<Repcode__c> repcodes = new List<Repcode__c>{
            new Repcode__c(Name = 'Test1'),
            new Repcode__c(Name = 'Test2')
        };
        insert repcodes;
        
        // Retrieve the expected group names
        List<String> expectedGroupNames = new List<String>{
            repcodes[0].Id + '_' + repcodes[0].Name,
            repcodes[1].Id + '_' + repcodes[1].Name
        };

        // Verify that the groups are created
        List<Group> groups = [SELECT Id, Name FROM Group WHERE Name IN :expectedGroupNames];
        System.debug('Groups Created: ' + groups);
        System.assertEquals(2, groups.size(), 'Groups should be created for the inserted Repcode__c records.');
        
        // Verify the group names
        for (String groupName : expectedGroupNames) {
            Boolean found = false;
            for (Group grp : groups) {
                if (grp.Name == groupName) {
                    found = true;
                    break;
                }
            }
            System.assert(found, 'Group with name ' + groupName + ' should be created.');
        }
    }

    @isTest
    static void testDeleteRepcode() {
        // Create test Repcode__c records
        List<Repcode__c> repcodes = new List<Repcode__c>{
            new Repcode__c(Name = 'TestToDelete1'),
            new Repcode__c(Name = 'TestToDelete2')
        };
        insert repcodes;
        
        // Create corresponding groups
        List<Group> groupsToCreate = new List<Group>();
        for (Repcode__c repcode : repcodes) {
            String groupName = repcode.Id + '_' + repcode.Name;
            groupsToCreate.add(new Group(Name = groupName, Type = 'Regular'));
        }
        insert groupsToCreate;
        
        // Retrieve the group names to verify creation
        List<String> groupNames = new List<String>{
            repcodes[0].Id + '_' + repcodes[0].Name,
            repcodes[1].Id + '_' + repcodes[1].Name
        };
        List<Group> existingGroups = [SELECT Id, Name FROM Group WHERE Name IN :groupNames];
        System.debug('Groups Before Deletion: ' + existingGroups);
        System.assertEquals(4, existingGroups.size(), 'Groups should be created before deletion.');

        // Delete Repcode__c records
        delete repcodes;
        
        // Verify that the groups are deleted
        List<Group> deletedGroups = [SELECT Id, Name FROM Group WHERE Name IN :groupNames];
        System.debug('Groups After Deletion: ' + deletedGroups);
        System.assertEquals(0, deletedGroups.size(), 'Groups should be deleted when Repcode__c records are deleted.');
    }
}