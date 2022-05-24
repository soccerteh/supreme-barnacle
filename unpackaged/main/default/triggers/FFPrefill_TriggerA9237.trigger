/**
 * Auto Generated and Deployed by Fast Prefill - Formstack
 **/
trigger FFPrefill_TriggerA9237 on Opportunity
    (after insert)
{
 if  (trigger.isAfter  &&  trigger.isInsert) { 
List<Opportunity>  newlyInsertedItems =  [SELECT  Id ,  College_Planning_Form__c FROM  Opportunity WHERE  Id  IN :trigger.new] ; 
List<string> ids = new List<string>();
 for ( Opportunity e  : newlyInsertedItems) { 
ids.add(e.id); 
} 
 VisualAntidote.FastFormsUtilities.DoUpdateRecords( 'Opportunity' ,  'College_Planning_Form__c' ,  'a0w3h000000ZOq4AAG' ,  ids,null );  
 update newlyInsertedItems;}
}