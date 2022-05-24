/**
 * Auto Generated and Deployed by Fast Prefill - Formstack
 **/
trigger FFPrefill_Trigger2E55D on Lead
    (after insert)
{
 if  (trigger.isAfter  &&  trigger.isInsert) { 
List<Lead>  newlyInsertedItems =  [SELECT  Id ,  Student_Application_Form_Full__c FROM  Lead WHERE  Id  IN :trigger.new] ; 
List<string> ids = new List<string>();
 for ( Lead e  : newlyInsertedItems) { 
ids.add(e.id); 
} 
 VisualAntidote.FastFormsUtilities.DoUpdateRecords( 'Lead' ,  'Student_Application_Form_Full__c' ,  'a0w3h000000ZP29AAG' ,  ids,null );  
 update newlyInsertedItems;}
}