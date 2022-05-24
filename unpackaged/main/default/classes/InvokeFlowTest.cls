@isTest
private class InvokeFlowTest {
    
    @isTest static void insertContentVersion() {
        
        // Insert a content version
        ContentVersion doc = new ContentVersion(); 

        doc.Title        =  '1st Letter of Recommendation';
        doc.PathOnClient = 'test';
        doc.VersionData  = EncodingUtil.base64Decode('1st Letter of Recommendation');

        insert doc;
    }    
}