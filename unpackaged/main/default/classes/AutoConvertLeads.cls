/*
* @author          Dhatrinath Kodali
* @version         1
* @date            14-08-2020
* @description     This class is called in ProcessBuilder to convert the Leads whenever Application__c is TRUE.
*/
public class AutoConvertLeads {
@InvocableMethod
    public static void LeadAssign(List<Id> LeadIds)
    {
        LeadStatus CLeadStatus= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true Limit 1];
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
        for(id currentlead: LeadIds){
                Database.LeadConvert Leadconvert = new Database.LeadConvert();
                Leadconvert.setLeadId(currentlead);                
                Leadconvert.setConvertedStatus(CLeadStatus.MasterLabel);
                MassLeadconvert.add(Leadconvert);
        }
        
        if (!MassLeadconvert.isEmpty()) {
            List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);
        }
    }
}