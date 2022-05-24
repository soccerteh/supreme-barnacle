/**
 * @description       : 
 * @author            : Nick Holly
 * @group             : 
 * @last modified on  : 11-30-2021
 * @last modified by  : Nick Holly
**/
public without sharing class FlowRecordSharingUtils {
    
    /**
    * @description Invocable Method exposed for REST API and Flows to create and delete any existing share records under certain conditions.
    * @author Nick Holly | 11-30-2021 
    * @param List<ShareRecordProfile> recordShareProfiles Collection of FlowRecordSharingUtils.ShareRecordProfile objects.
    **/
    @InvocableMethod
    public static void getShareRecords(
        List<ShareRecordProfile> recordShareProfiles
    ) {
        if (recordShareProfiles.isEmpty())  {
            throw new IllegalArgumentException('Null arguments not accepted');
        } else {
            if (recordShareProfiles[0].recordId == null) {
                throw new IllegalArgumentException('Non-null recordId is required.');
            }
        }
        List<SObject> shareRecordsToInsert = new List<SObject>();
        List<SObject> existingShareRecords = new List<SObject>();
        Map<Id, Id> recordIdsToQueryShareRecordsAgainst = new Map<Id, Id>();
        for(ShareRecordProfile recordShareProfile :recordShareProfiles) {
            if(recordShareProfile.deleteExistingSharingRecords) {
                recordIdsToQueryShareRecordsAgainst.put(recordShareProfile.recordId, recordShareProfile.previousUserOrGroupId);
            }
            SObject shareRecord = createShareRecords(
                recordShareProfile.recordId,
                recordShareProfile.userOrGroupId,
                recordShareProfile.shareSObjectName,
                recordShareProfile.lookupField,
                recordShareProfile.accessFieldName,
                recordShareProfile.accessLevel
            );
            shareRecordsToInsert.add(shareRecord);
        }
        if (!recordIdsToQueryShareRecordsAgainst.isEmpty()) {
            existingShareRecords = queryExistingSharingRecords(
                recordIdsToQueryShareRecordsAgainst.keySet(), 
                new Set<Id>(recordIdsToQueryShareRecordsAgainst.values()), 
                recordShareProfiles[0].shareSObjectName, 
                recordShareProfiles[0].lookupField
            );
            if (!existingShareRecords.isEmpty()) {
                deleteShareRecords(existingShareRecords);
            }
        }

        Database.insert(shareRecordsToInsert, false);
    }

    /**
    * @description Creates a sharing record, using the given inputs.
    * @author Nick Holly | 11-30-2021
    * @param Id recordId The ID of the Record that will be shared.
    * @param Id userOrGroupId The ID of the User or Group to share the record with.
    * @param String shareSObjectName DeveloperName of the Share object.
    * @param String lookupField The API name of the field that is used for the share record to link to the object.
    * @param String accessLevelFieldName The API name of the field that is used for setting the access level for the share record.
    * @param String accessLevel The level of share access.
    * @return SObject Returns a single instance of a Share record of the appropriate SObject type. 
    **/
    private static SObject createShareRecords(
        Id recordId,
        Id userOrGroupId,
        String shareSObjectName,
        String lookupField,
        String accessLevelFieldName,
        String accessLevel
    ) {
        List<SObject> shareRecords = new List<SObject>();
        sObject shareRecord;
        try {
            shareRecord = Schema.getGlobalDescribe().get(shareSObjectName).newSObject();
            shareRecord.put(
                lookupField,
                recordId
            );
            shareRecord.put(
                'UserOrGroupId',
                userOrGroupId
            );
            shareRecord.put(
                accessLevelFieldName,
                accessLevel
            );
            if (String.valueOf(recordId.getSobjectType()) == 'Account') {
                shareRecord.put('OpportunityAccessLevel', 'None');
            }
        } catch (NullPointerException npe) {
            
        }
        return shareRecord; 
    }

    /**
    * @description 
    * @author Nick Holly | 12-02-2021 
    * @param List<SObject> shareRecordsToDelete 
    **/
    private static void deleteShareRecords(
        List<SObject> shareRecordsToDelete
    ) {
        Database.delete(shareRecordsToDelete, false);
    }

    /**
    * @description Queries any existing Share Records for the ID provided.
    * @author Nick Holly | 11-30-2021
    * @param Set<Id> recordIds A collection of Record Ids to search for sharing records against.
    * @param List<Id> previousUserOrGroupIds A collection of User or Group Ids to be used in conjunction with the recordIds to search for sharing records against.
    * @param String shareSObjectName shareSObjectName DeveloperName of the Share object.
    * @param String lookupField The API name of the field that is used for the share record to link to the object.
    * @return List<SObject> A list of existing Sharing records where the ParentId/ObjectId is in the recordIds collection and the UserOrGroupId is in the previousUserOrGroupIds collection.
    **/
    private static List<SObject> queryExistingSharingRecords(
        Set<Id> recordIds,
        Set<Id> previousUserOrGroupIds,
        String shareSObjectName,
        String lookupField
    ) {
        if (previousUserOrGroupIds.isEmpty() || previousUserOrGroupIds.contains(null)) {
            throw new IllegalArgumentException('Non-null previousUserOrGroupId is required.');
        }
        String rowCause = 'Manual';
        return Database.query('SELECT Id FROM ' + shareSObjectName + ' WHERE RowCause = :rowCause AND ' + lookupField + ' IN :recordIds AND UserOrGroupId IN :previousUserOrGroupIds');
    }
    
    public class ShareRecordProfile {
        @InvocableVariable(label='The ID of the Record of being shared.' required=true)
        public Id recordId;

        @InvocableVariable(label='The User or Group to share the Record with.' required=true)
        public Id userOrGroupId;
        
        @InvocableVariable(label='The User or Group the record is curently shared with. Will be used to remove sharing access.' required=false)
        public Id previousUserOrGroupId;

        @InvocableVariable(label='The API name of the lookup field on the Sharing Object that points to the record.' required=true)
        public String lookupField;

        @InvocableVariable(label='The API name of the SObject to be shared.' required=true)
        public String sObjectName;

        @InvocableVariable(label='The API name of the Sharing Object.' required=true)
        public String shareSObjectName;

        @InvocableVariable(label='The level of sharing access given to the record.' required=true)
        public String accessLevel;

        @InvocableVariable(label='The API name of the access field on the Sharing Object.' required=true)
        public String accessFieldName;

        @InvocableVariable(label='Delete Existing Share Records?' required=true)
        public Boolean deleteExistingSharingRecords;
    }
}