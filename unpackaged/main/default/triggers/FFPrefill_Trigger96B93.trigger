/**
 * Auto Generated and Deployed by Fast Prefill - Formstack
 **/
trigger FFPrefill_Trigger96B93 on Opportunity
    (after insert)
{
 if  (trigger.isAfter  &&  trigger.isInsert) { 
List<Opportunity>  newlyInsertedItems =  [SELECT  Id ,  Student_Application_Form_Full__c FROM  Opportunity WHERE  Id  IN :trigger.new] ; 
List<string> ids = new List<string>();
 for ( Opportunity e  : newlyInsertedItems) { 
ids.add(e.id); 
} 
 VisualAntidote.FastFormsUtilities.DoUpdateRecords( 'Opportunity' ,  'Student_Application_Form_Full__c' ,  'a0w3h000000ZOlmAAG' ,  ids,null );  
 update newlyInsertedItems;}
}