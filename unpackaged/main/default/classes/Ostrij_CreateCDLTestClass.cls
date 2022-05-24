@isTest(SeeAllData=false)
public class Ostrij_CreateCDLTestClass{

    @isTest
    static void Ostrij_CreateContentDocumentLinkTest(){
        Test.startTest();
        Account evalEntity = new Account();
        evalEntity.Name = 'name here';
        evalEntity.First_Name__c = 'firstname';
        evalEntity.Last_Name__c = 'lastname';

        insert evalEntity;

        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = evalEntity.Id;
        cdl.ContentDocumentId = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers'; 

        
        List<string> tempList = new list<string>();
    
        tempList.add('['+cdl.ContentDocumentId+','+cdl.LinkedEntityId+']');
        
        Ostrij_CreateContentDocumentLink.create_contentDocumentLink(tempList);
        
        //insert cdl;

        
        Ostrij_CreateContentDocumentLink.create_contentDocumentLink(tempList);
        Test.stopTest();
    }

}