global class Ostrij_DeleteContentDocumentLink {
   
    @InvocableMethod

    public static void delete_contentDocumentLink(List<string> values) {
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
            
            List<ContentDocumentLink> contentDocumentLinkCheck = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:id_linkedEntity and ContentDocumentId=:id_contentDocument];
            Boolean cdlExists = False;
            
            if(!(contentDocumentLinkCheck.isEmpty())){
                cdlExists = True;
                system.debug('file link to application exists');
            }
            
            if(cdlExists == True){
                delete contentDocumentLinkCheck;
                system.debug('file link to application deleted');
            }

            
        }
      
   }

}