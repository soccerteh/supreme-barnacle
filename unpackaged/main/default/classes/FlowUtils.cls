/**
 * @description       : Utility class that can be called from a flow. The first util in this class
 *                          checks the validity of a Salesforce Id passed to it.
 * @author            : Thomas E. Hamilton
 * @group             : 
 * @last modified on  : 01-20-2022
 * @last modified by  : Thomas E. Hamilton
**/
public without sharing class FlowUtils {

    /**
    * @description Invocable Method exposed for REST API and Flows to confirm if the passed Id is a valid SF ID.
    * @author Thomas E. Hamilton | 01-20-2022
    * @param List<FlowUtilsVars> flowUtilsVars Collection of FlowUtils.FlowUtilsVars objects. A List is required here, even though it is designed for one.
    * @return lstBooleans returns a List of booleans confirming if an Id is valid or not. List is required when returning primitives to a flow.
    **/
    @InvocableMethod
    public static List<Boolean> checkId(List<FlowUtilsVars> flowUtilsVars){
        List<Boolean> lstBooleans = new List<Boolean>();
        for(FlowUtilsVars flowUtilVar : flowUtilsVars){
            try{
                if(Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher( flowUtilVar.inputId ).matches() ){
                    // Attempt to assign it to an Id to confirm it is a valid Id
                    Id id = flowUtilVar.inputId;
    
                    // Initialize the sObject
                    sObject sObj = Schema.getGlobalDescribe().get(flowUtilVar.inputObject).newSObject();
    
                    //Set Id to the expected sObject
                    sObj.Id = Id;
    
                    // If there are no errors, return true
                    lstBooleans.add(true);
                }
                else{
                    lstBooleans.add(false);
                } 
            }catch(Exception e){
                //Handle Exception
                system.debug('FlowUtils.checkId caught the following exception when validating an Id: ' + e);
                // ID is not valid
                lstBooleans.add(false);
            }
        }
        return lstBooleans;
    }

    /**
    * @description Inner class that is called from a flow in order to pass values since invocable methods are limited to 1 parameter.
    * @author Thomas E. Hamilton | 01-20-2022
    * @param String inputObject DeveloperName of the the sObject.
    * @param String inputId A string containing an Id that a user wants to check the validity of.
    **/
    public class FlowUtilsVars{
        @InvocableVariable(label='The sObject name you are expecting' required=true)
        public String inputObject;

        @InvocableVariable(label='The ID you need to confirm is a real ID')
        public String inputId;

    }
}