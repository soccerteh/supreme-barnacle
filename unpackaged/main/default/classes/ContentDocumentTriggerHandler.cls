public with sharing class ContentDocumentTriggerHandler {
    public ContentDocumentTriggerHandler() {

    }

    public static void updateFormSubmissions(List<ContentDocument> contentDocumentList, Map<Id, ContentDocument> oldValues) {
        Set<Id> fileSubmissions = new Set<Id>();
        Map<String, Student_File__mdt> activeStudentFileSubmissions = MetadataUtils.getActiveStudentFileMetadata();
        for(ContentDocument file :contentDocumentList) {
            String fileName = file.Title.contains('.') ? file.Title.split('\\.')[0] : file.Title;
            if(activeStudentFileSubmissions.containsKey(fileName) && oldValues.get(file.Id).Title != file.Title) {
                fileSubmissions.add(file.Id);
            }
        }
        if(!fileSubmissions.isEmpty()) {
            Map<Id, Account> accountsToUpdate = getAccountRecords(fileSubmissions);
            for(ContentDocument file :contentDocumentList) {
                if(accountsToUpdate.containsKey(file.Id)) {
                    String fileName = file.Title.contains('.') ? file.Title.split('\\.')[0] : file.Title;
                    Student_File__mdt setting = activeStudentFileSubmissions.get(fileName);
                    accountsToUpdate.get(file.Id).put(setting.Field_API_Name__c, true);
                    accountsToUpdate.get(file.Id).put(setting.Submission_Field_API_Name__c, System.today());
                }
            }
            update accountsToUpdate.values();
        }
    }

    public static Map<Id, Account> getAccountRecords(Set<Id> fileIds) {
        Map<Id, Id> cdToAccountMap = getContentDocumentLinks(fileIds);
        Set<Id> accountIds = new Set<Id>(cdToAccountMap.values());
        String query = 'SELECT Id,' + MetadataUtils.getActiveStudentFileQueryFields() + ' FROM Account WHERE ID IN :accountIds';
        Map<Id, Account> accountMap = new Map<Id, Account>((List<Account>)Database.query(query));
        Map<Id, Account> contentDocumentToAccountMap = new Map<Id, Account>();
        for(Id contentDoc :fileIds) {
            contentDocumentToAccountMap.put(contentDoc, accountMap.get(cdToAccountMap.get(contentDoc)));
        }
        return contentDocumentToAccountMap;
    }

    private static Map<Id, Id> getContentDocumentLinks(Set<Id> fileIds) {
        Map<Id, Id> documentToAccountMap = new Map<Id, Id>();
        for(ContentDocumentLink link :[SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :fileIds]) {
            if(link.LinkedEntityId.getSObjectType() == Schema.Account.getSObjectType()) {
                documentToAccountMap.put(link.ContentDocumentId, link.LinkedEntityId);
            }
        }
        return documentToAccountMap;
    }

}