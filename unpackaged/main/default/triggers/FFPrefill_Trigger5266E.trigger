/**
 * Auto Generated and Deployed by Fast Prefill - Formstack
 **/
trigger FFPrefill_Trigger5266E on Opportunity
    (after insert)
{
 if  (trigger.isAfter  &&  trigger.isInsert) { 
List<Opportunity>  newlyInsertedItems =  [SELECT  Id ,  Submit_Documents_Form__c FROM  Opportunity WHERE  Id  IN :trigger.new] ; 
List<string> ids = new List<string>();
 for ( Opportunity e  : newlyInsertedItems) { 
ids.add(e.id); 
} 
 VisualAntidote.FastFormsUtilities.DoUpdateRecords( 'Opportunity' ,  'Submit_Documents_Form__c' ,  'a0w3h000000ZOt3AAG' ,  ids,null );  
 update newlyInsertedItems;}
}