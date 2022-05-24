global class Ostrij_CreateContentDocumentLink {
   
    @InvocableMethod

    public static void create_contentDocumentLink(List<string> values) {
        if(!(values.isEmpty())){
            
            system.debug('Parameter values ' + values);
            
            List<String> splitList = new List<String>();
            
            for(String x: values){
                splitList = x.split(',');
            }
            
            system.debug('splitList ' + splitList);
            
            String id_contentDocument = splitList[0].substring(1, splitList[0].length());
            String id_linkedEntity = splitList[1].substring(0, splitList[1].length() - 1);
            system.debug('contentDocument ' + id_contentDocument);
            system.debug('linkedEntity ' + id_linkedEntity);
            
            List<ContentDocumentLink> contentDocumentLinkCheck = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:id_linkedEntity];
            Boolean cdlExists = False;
            
            if(!(contentDocumentLinkCheck.isEmpty())){
                for(ContentDocumentLink cdlCheck: contentDocumentLinkCheck){
                    if(cdlCheck.ContentDocumentId == id_contentDocument){
                        cdlExists = True;
                        system.debug('file link to application already exists');
                    }
                }
            }
            
            if(cdlExists == False){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = id_contentDocument;
                cdl.LinkedEntityId = id_linkedEntity;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                insert cdl;
                system.debug('file link to application created');
            }

            
        }
      
   }

}