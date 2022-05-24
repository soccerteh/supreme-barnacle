/**
 * Auto Generated and Deployed by Fast Prefill - Formstack
 **/
trigger FFPrefill_TriggerDA951 on Account
    (after insert)
{
 if  (trigger.isAfter  &&  trigger.isInsert) { 
List<Account>  newlyInsertedItems =  [SELECT  Id ,  Submit_Documents_Form__c FROM  Account WHERE  Id  IN :trigger.new] ; 
List<string> ids = new List<string>();
 for ( Account e  : newlyInsertedItems) { 
ids.add(e.id); 
} 
 VisualAntidote.FastFormsUtilities.DoUpdateRecords( 'Account' ,  'Submit_Documents_Form__c' ,  'a0w3h000000VbOmAAK' ,  ids,null );  
 update newlyInsertedItems;}
}