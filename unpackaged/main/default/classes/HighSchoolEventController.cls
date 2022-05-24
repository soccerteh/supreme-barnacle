/**
 * @description       : Controller class for High School Event Page
 * @author            : NickHolly
 * @last modified on  : 08-31-2021
 * @last modified by  : NickHolly
**/
public with sharing class HighSchoolEventController {

    public Inquiry__c studentInquiry {get; set;}
    public Boolean consent {get; set;}
    public Id highSchool {get; set;}
    @TestVisible
    private Id eventId {get; set;}
    @TestVisible
    private Id counselorId {get; set;}
    
    public HighSchoolEventController(ApexPages.StandardController controller) {
        resetVariables();
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        eventId = parameters.get('eid');
        counselorId = parameters.get('cid');
    }
     
    public PageReference submitInformation() {
        try {

            studentInquiry.Event__c = eventId;
            studentInquiry.Counselor__c = counselorId;
            studentInquiry.High_School__c = highSchool;
            //TODO: Add in support for setting the Counselor ID if only an Event ID is passed through, but also look into URL encoding the URL sent to the QR Api
            insert studentInquiry;
        } catch (Exception e) {
            Unhandled_Exception__c unhandledException = new Unhandled_Exception__c(
                Stack_Trace__c = e.getStackTraceString(),
                Line_Number__c = e.getLineNumber(),
                Message__c = e.getMessage(),
                Exception_Type__c = e.getTypeName(),
                Object_Data__c = JSON.serialize(studentInquiry)
            );
            insert unhandledException;
        }
        resetVariables();
        PageReference target = new PageReference('https://vertoeducation.org/apply/');
        target.setRedirect(true);
        return target;
    }

    public void cancelSubmission() {
        resetVariables();
    }
    
    private void resetVariables() {
        studentInquiry = new Inquiry__c(
            RecordTypeId = Schema.sObjectType.Inquiry__c.getRecordTypeInfosByName().get('Request for Information').getRecordTypeId()
        );
        consent = false;
        eventId = null;
        counselorId = null;
    }

    public List<SelectOption> getCountries() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('United States', 'United States'));
        for(Schema.PicklistEntry pickval :Inquiry__c.Country__c.getDescribe().getPicklistValues()) {
            if(pickval.value != 'United States') {
                options.add(new SelectOption(pickval.getValue(), pickval.getLabel()));
            }
        }
        return options;
    }

	public List<SelectOption> getYears() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', ''));
		Integer startYear = System.today().addYears(-3).year();
		Integer endYear = System.today().addYears(5).year();
		for(Integer i = startYear; i < endYear; i++) {
			options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
		}
		return options;
	}

    /* public List<SelectOption> getHighSchools() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        List<Account> highSchools = [SELECT Id, Name FROM Account WHERE RecordTypeId = :Schema.sObjectType.Account.getRecordTypeInfosByName().get('High School Account').getRecordTypeId() ORDER BY Name asc LIMIT 999];
        for(Account each :highSchools) {
            options.add(new SelectOption(each.Id, each.Name));
        }
        return options;
    } */
}