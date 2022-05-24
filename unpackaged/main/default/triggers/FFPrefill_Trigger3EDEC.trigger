/**
 * Auto Generated and Deployed by Fast Prefill - Formstack
 **/
trigger FFPrefill_Trigger3EDEC on Opportunity
    (after insert)
{
 if  (trigger.isAfter  &&  trigger.isInsert) { 
List<Opportunity>  newlyInsertedItems =  [SELECT  Id ,  Opportunity_Grant_Application__c FROM  Opportunity WHERE  Id  IN :trigger.new] ; 
List<string> ids = new List<string>();
 for ( Opportunity e  : newlyInsertedItems) { 
ids.add(e.id); 
} 
 VisualAntidote.FastFormsUtilities.DoUpdateRecords( 'Opportunity' ,  'Opportunity_Grant_Application__c' ,  'a0w3h000000ZOv9AAG' ,  ids,null );  
 update newlyInsertedItems;}
}