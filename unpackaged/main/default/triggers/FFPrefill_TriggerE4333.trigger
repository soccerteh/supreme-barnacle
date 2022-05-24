/**
 * Auto Generated and Deployed by Fast Prefill - Formstack
 **/
trigger FFPrefill_TriggerE4333 on Lead
    (after insert)
{
 if  (trigger.isAfter  &&  trigger.isInsert) { 
List<Lead>  newlyInsertedItems =  [SELECT  Id ,  Request_Information_Form__c FROM  Lead WHERE  Id  IN :trigger.new] ; 
List<string> ids = new List<string>();
 for ( Lead e  : newlyInsertedItems) { 
ids.add(e.id); 
} 
 VisualAntidote.FastFormsUtilities.DoUpdateRecords( 'Lead' ,  'Request_Information_Form__c' ,  'a0w3h000000ZOhvAAG' ,  ids,null );  
 update newlyInsertedItems;}
}