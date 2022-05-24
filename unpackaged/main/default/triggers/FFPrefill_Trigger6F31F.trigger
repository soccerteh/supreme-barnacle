/**
 * Auto Generated and Deployed by Fast Prefill - Formstack
 **/
trigger FFPrefill_Trigger6F31F on Opportunity
    (after insert)
{
 if  (trigger.isAfter  &&  trigger.isInsert) { 
List<Opportunity>  newlyInsertedItems =  [SELECT  Id ,  Change_the_World_Application__c FROM  Opportunity WHERE  Id  IN :trigger.new] ; 
List<string> ids = new List<string>();
 for ( Opportunity e  : newlyInsertedItems) { 
ids.add(e.id); 
} 
 VisualAntidote.FastFormsUtilities.DoUpdateRecords( 'Opportunity' ,  'Change_the_World_Application__c' ,  'a0w3h000000ZOuzAAG' ,  ids,null );  
 update newlyInsertedItems;}
}