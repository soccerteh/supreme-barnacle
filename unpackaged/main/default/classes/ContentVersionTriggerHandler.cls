/**
 * @description       : Trigger Handler built for Content Version standard object trigger.
 * @author            : Nick Holly
 * @group             : 
 * @last modified on  : 07-26-2021
 * @last modified by  : Nick Holly
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   07-26-2021   Nick Holly   Initial Version
**/
public with sharing class ContentVersionTriggerHandler {

    /**
    * @description 
    * @author Nick Holly | 07-26-2021 
    **/
    public static void updateFormSubmissions(Map<Id, ContentVersion> contentVersions) {
        //TODO: Change the order of execution, should determine if the file even matches one of the filetypes from settings before proceeding.
        Map<String, Student_File__mdt> studentFileMeta = getActiveStudentFileMetadata();
        List<ContentVersion> studentFormFiles = filterFiles(contentVersions.values(), studentFileMeta.keySet());
        Set<Id> accountFiles = new Set<Id>();
        Set<Id> oppFiles = new Set<Id>();
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        for(ContentVersion uploadedFile :studentFormFiles) {
            if(uploadedFile.FirstPublishLocationId.getSObjectType() == Account.sObjectType) {
                accountFiles.add(uploadedFile.FirstPublishLocationId);
            } else if (uploadedFile.FirstPublishLocationId.getSObjectType() == Opportunity.sObjectType) {
                oppFiles.add(uploadedFile.FirstPublishLocationId);
            }
        }
        if(!accountFiles.isEmpty() || !oppFiles.isEmpty()) {
            String queryFields = getQueryFields(studentFileMeta.values());
            Map<Id, Opportunity> opportunityMap = getOpportunityRecords(
                accountFiles,
                oppFiles,
                queryFields
            );
            for(Opportunity opp :opportunityMap.values()) {
                accountFiles.add(opp.AccountId);
            }
            Map<Id, Account> accountMap = getAccountRecords(
                accountFiles,
                queryFields
            );
            for(ContentVersion uploadedFile :studentFormFiles) {
                Id attachedRecord = uploadedFile.FirstPublishLocationId;
                String fileType = uploadedFile.Title.split('\\.')[0];
                Account tempAccount;
                if(accountsToUpdate.containsKey(attachedRecord)) {
                    tempAccount = accountsToUpdate.get(attachedRecord);
                } else {
                    if(attachedRecord.getSObjectType() == Account.sObjectType && accountMap.containsKey(attachedRecord)) {
                        tempAccount = accountMap.get(attachedRecord);
                    } else if (attachedRecord.getSObjectType() == Opportunity.sObjectType && opportunityMap.containsKey(attachedRecord)) {
                        tempAccount = accountMap.get(opportunityMap.get(attachedRecord).AccountId);
                    }
                }
                if(studentFileMeta.containsKey(fileType)) {
                    Date uploadDate = Date.newInstance(uploadedFile.lastModifiedDate.year(), uploadedFile.lastModifiedDate.month(), uploadedFile.lastModifiedDate.day());
                    Student_File__mdt fieldUpdates = studentFileMeta.get(fileType);
                    tempAccount.put(fieldUpdates.Field_API_Name__c, True);
                    tempAccount.put(fieldUpdates.Submission_Field_API_Name__c, uploadDate);
                    accountsToUpdate.put(tempAccount.Id, tempAccount);
                }
            }
        }
        if(!accountsToUpdate.isEmpty()) {
            update accountsToUpdate.values();
        }
    }

    private static Map<Id, Account> getAccountRecords(
        Set<Id> accountIds, 
        String fieldsToQuery
    ) {
        String query = 'SELECT ' + fieldsToQuery + ' FROM Account WHERE ID IN :accountIds'; 
        return new Map<Id, Account>((List<Account>)Database.query(query));
    }

    private static Map<Id, Opportunity> getOpportunityRecords(
        Set<Id> accountIds,
        Set<Id> opportunityIds,
        String fieldsToQuery
    ) {
        String query = 'SELECT ' + fieldsToQuery + ', AccountId FROM Opportunity WHERE ID IN :opportunityIds OR AccountID IN :accountIds';
        return new Map<Id, Opportunity>((List<Opportunity>)Database.query(query));
    }

    private static String getQueryFields(List<Student_File__mdt> activeStudentFiles) {
        Set<String> fields = new Set<String>();
        for(Student_File__mdt setting :activeStudentFiles) {
            fields.add(setting.Field_API_Name__c);
        }
        return String.join(new List<String>(fields), ',');
    }


    private static Map<String, Student_File__mdt> getActiveStudentFileMetadata() {
        Map<String, Student_File__mdt> studentFiles = new Map<String, Student_File__mdt>();
        for(Student_File__mdt setting :[SELECT MasterLabel, Field_API_Name__c, Submission_Field_API_Name__c 
                                        FROM Student_File__mdt 
                                        WHERE isActive__c = true
                                        ORDER BY MasterLabel]
        ){
            studentFiles.put(setting.MasterLabel, setting);
        }
        return studentFiles;
    }


    /**
    * @description 
    * @author Nick Holly | 07-26-2021 
    * @param currentFiles 
    **/
    public static void relocateFile(Map<Id, ContentVersion> currentFiles) {
        Map<Id, Id> filteredFiles = filterFiles(currentFiles);
        Map<Id, List<ContentDocumentLink>> oldFileLocations = getContentDocumentLink(filteredFiles.keySet());
        List<ContentDocumentLink> newFileLocations = new List<ContentDocumentLink>();
        if(!oldFileLocations.isEmpty()){
            for(Opportunity opp :[SELECT Id, AccountId FROM Opportunity WHERE ID IN :filteredFiles.values()]) {
                for(ContentDocumentLink cdl :oldFIleLocations.get(opp.Id)) {
                    ContentDocumentLink newDocLink = FilesUtils.copyFileAttachedToRecord(
                        cdl,
                        opp.AccountId
                    );
                    newFileLocations.add(newDocLink);
                }
            }
            Database.saveResult[] saveResults =  Database.insert(newFileLocations, false);
            for(Database.saveResult result :saveResults) {
                if(!result.isSuccess()) {
                    for(Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }


    /**
    * @description 
    * @author Nick Holly | 07-26-2021 
    * @param currentFiles 
    * @return Map<Id, Id> 
    **/
    private static Map<Id, Id> filterFiles(Map<Id, ContentVersion> currentFiles) {
        //TODO: Move the filter into a custom metadata type.
        Map<Id, Id> filteredDocuments = new Map<Id, Id>();
        for(ContentVersion file :currentFiles.values()) {
            if(file.FirstPublishLocationId != null && file.FirstPublishLocationId.getSObjectType() == Opportunity.sObjectType) {
                //return a map, with the contentDocumentId as the key. The key can be used for querying ContentDocumentLink records if necessary.
                filteredDocuments.put(file.ContentDocumentId, file.FirstPublishLocationId);
            }
        }
        return filteredDocuments;
    }

    private static List<ContentVersion> filterFiles(List<ContentVersion> currentFiles, Set<String> activeStudentForms) {
        List<ContentVersion> validContentVersions = new List<ContentVersion>();
        for(ContentVersion uploadedFile : currentFiles) {
            if(activeStudentForms.contains(uploadedFile.Title.split('\\.')[0]) && uploadedFile.FirstPublishLocationId != null) {
                validContentVersions.add(uploadedFile);
            }
        }
        return validContentVersions;
    }

    /**
    * @description 
    * @author Nick Holly | 07-26-2021 
    * @param contentVersions 
    * @return Map<Id, ContentDocumentLink> 
    **/
    private static Map<Id, List<ContentDocumentLink>> getContentDocumentLink(Set<Id> contentVersions){
        Map<Id, List<ContentDocumentLink>> contentDocLink = new Map<Id, List<ContentDocumentLink>>();
        List<ContentDocumentLink> oldContentDocLink = new List<ContentDocumentLink>();
        if(!contentVersions.isEmpty()) {
            oldContentDocLink = [SELECT Id, LinkedEntityId, ContentDocumentId, 
                                ShareType, Visibility, LinkedEntity.Type
                                FROM ContentDocumentLink 
                                WHERE ContentDocumentId IN :contentVersions];
            for(ContentDocumentLink attachedFile :oldContentDocLink){
                if(attachedFile.LinkedEntity.Type == String.valueOf(Opportunity.sObjectType)) {
                    if(contentDocLink.containsKey(attachedFile.LinkedEntityId)) {
                        contentDocLink.get(attachedFile.LinkedEntityId).add(attachedFile);
                    } else {
                        contentDocLink.put(attachedFile.LinkedEntityId, new List<ContentDocumentLink>{attachedFile});
                    }
                }
            }
        }
        
        return contentDocLink;
    }

    public static void handleGuestSiteUploads(Map<Id, ContentVersion> currentFiles) {
        if(currentFiles.isEmpty()) {
            return;
        }
        List<ContentVersion> guestSiteFiles = new List<ContentVersion>();
        for(ContentVersion file :currentFiles.values()) {
            if(file.Guest_Site_fileupload__c != null){
                guestSiteFiles.add(file);
            }
        }
        GuestFileUtils.setGuestFileRelatedRecord(guestSiteFiles);
    }
}