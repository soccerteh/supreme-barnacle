@isTest
private inherited sharing class FilesUtils_Tests {
    @TestSetup
    static void makeData() {
        Account acct = new Account(
            Name = 'Test Account',
            First_Name__c = 'Test',
            Last_Name__c = 'Account'
        );
        insert acct;

        StaticResource[] testData = [
            SELECT Id, Body, Name
            FROM StaticResource
            WHERE Name IN ('helloaudio', 'helloworld', 'logo')
        ];

        for (StaticResource resource : testData) {
            String fileName = '';
            if (resource.Name.equalsIgnoreCase('logo')) {
                fileName = resource.Name + '.png';
            } else if (resource.Name.equalsIgnoreCase('helloworld')) {
                fileName = resource.Name + '.docx';
            } else {
                filename = resource.Name + '.m4a';
            }
            FilesUtils.createFileAttachedToRecord(
                resource.Body,
                acct.Id,
                fileName
            );
        }
    }

    @isTest
    static void testPublishContent() {
        Account acct = [SELECT Id FROM Account LIMIT 1];
        String text = 'Hello Good Friends, enjoy the stream!';
        FilesUtils.createFileFromStringAttachedToRecord(text, acct.Id);
        ContentDocumentLink cdl = [
            SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :acct.Id
            LIMIT 1
        ];

        Test.startTest();
        FilesUtils.publishContent(cdl);
        Test.stopTest();

        ContentDistribution dist = [
            SELECT Id, ContentDownloadUrl
            FROM ContentDistribution
            WHERE RelatedRecordId = :acct.Id
            LIMIT 1
        ];
        System.assert(
            String.isNotBlank(dist.ContentDownloadUrl),
            'Expected to find a download url'
        );
    }

    @isTest
    static void testUploadFileFromText() {
        Account acct = [SELECT Id FROM Account LIMIT 1];
        String text = 'Hello World';

        Test.startTest();
        FilesUtils.createFileFromStringAttachedToRecord(text, acct.Id);
        Test.stopTest();

        ContentVersion[] results = [
            SELECT Id, FirstPublishLocationId, Title, PathOnClient
            FROM ContentVersion
            WHERE FirstPublishLocationId = :acct.Id AND title = 'Hello World.pdf'
        ];

        System.assert(results.size() == 1, 'Expected to find one file');
    }

    @isTest
    static void testGetFilteredAttachmentsForRecords() {
        Id attachedRecordId = [SELECT Id FROM Account LIMIT 1].Id;

        Test.startTest();
        List<ContentVersion> audioFiles = FilesUtils.getFilteredAttachmentsForRecord(
            FilesUtils.genericFileType.AUDIO,
            attachedRecordId
        );
        List<ContentVersion> imageFiles = FilesUtils.getFilteredAttachmentsForRecord(
            FilesUtils.genericFileType.IMAGE,
            attachedRecordId
        );
        List<ContentVersion> docFiles = FilesUtils.getFilteredAttachmentsForRecord(
            FilesUtils.genericFileType.DOCUMENT,
            attachedRecordId
        );
        List<ContentVersion> all = FilesUtils.getFilteredAttachmentsForRecord(
            FilesUtils.genericFileType.ALL,
            attachedRecordId
        );
        Test.stopTest();

        System.assertEquals(
            1,
            audioFiles.size(),
            'Expected to find 1 audio file'
        );
        System.assertEquals(
            1,
            imageFiles.size(),
            'Expected to find 1 image file'
        );
        System.assertEquals(
            1,
            docFiles.size(),
            'Expected to find 1 document file'
        );

        System.assertEquals(
            3, 
            all.size(), 
            'Expected to find 3 total files'
        );
    }

    @isTest
    static void testCopyFileAttachedToRecord() {
        Id accountRecord = [SELECT Id FROM Account LIMIT 1].Id;
        Opportunity opportunityRecord = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = accountRecord,
            StageName = 'Qualification',
            CloseDate = System.today().addDays(7)
        );
        insert opportunityRecord;
        Test.startTest();
        List<ContentDocumentLink> newFileAttachments = new List<ContentDocumentLink>();
        List<ContentDocumentLink> accountFiles = [SELECT Id, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :accountRecord];
        for(ContentDocumentLink file :accountFiles){
            newFileAttachments.add(
                FilesUtils.copyFileAttachedToRecord(
                    file,
                    opportunityRecord.Id
                )
            );
        }
        insert newFileAttachments;
        List<ContentDocumentLink> opportunityFiles = [SELECT Id, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :opportunityRecord.Id];
        Test.stopTest();

        System.assertEquals(
            3, 
            accountFiles.size(), 
            'Expected to find 3 files attached to the account'
        );
        System.assertEquals(
            3, 
            opportunityFiles.size(), 
            'Expected to find 3 files attached to the opportunity'
        );
    }
}