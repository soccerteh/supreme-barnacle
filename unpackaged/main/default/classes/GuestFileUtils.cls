public without sharing class GuestFileUtils {
    public GuestFileUtils() {

    }
    public static void setGuestFileRelatedRecord(List<ContentVersion> insertedFiles) {
        if(insertedFiles.isEmpty()) {
            return;
        }
        List<ContentDocumentLink> recordRelationships = new List<ContentDocumentLink>();        
        for(ContentVersion file : insertedFiles) {
            recordRelationships.add(
                new ContentDocumentLink(
                    ContentDocumentId = file.ContentDocumentId,
                    Visibility = 'AllUsers',
                    ShareType = 'I',
                    LinkedEntityId = file.Guest_Site_fileupload__c
                )
            );
        }
        insert recordRelationships;
    }
}