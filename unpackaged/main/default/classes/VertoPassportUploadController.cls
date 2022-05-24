/**
 * @description       : The Apex Controller for the VertoPassportUpload page. Facilitates the form submission and owner notification processes.
 * @author            : NickHolly
 * @last modified on  : 02-18-2022
 * @last modified by  : NickHolly
**/
public with sharing class VertoPassportUploadController {
    
    public Verto_Form_Submission__c record {get;set;}
    /* private Id recordId {get;set;}
    private Id recordOwner {get;set;} */
    private Enrollment_Record__c enrollmentRecord {get;set;}
    public transient String fileName {get;set;}
    public transient Blob fileData {get;set;}
    public transient String fileContentType {get;set;}
    public transient String validPassport {get;set;}
    public transient String program {get;set;}
    public Boolean showThankYou {get;set;}
    public Boolean showError {get;set;}
    public String ref {get;set;}

    public VertoPassportUploadController(ApexPages.StandardController controller) {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        if(parameters.containsKey('aid') && parameters.containsKey('program')) {
            String aid = String.escapeSingleQuotes(parameters.get('aid')).escapeHtml4();
            String program = String.escapeSingleQuotes(parameters.get('program')).escapeHtml4();
            try {
                System.debug('aid: ' + aid + ' program: ' + program);
                this.enrollmentRecord =  VertoPassportUploadHelperWS.getEnrollmentRecord(
                    Id.valueOf(aid),
                    Id.valueOf(program)
                );
                System.debug(enrollmentRecord);
            } catch (Exception e) {
                showError = true;
            }
        }
        showThankYou = parameters.containsKey('ThankYou');
        if (parameters.get('status') == 'error' || parameters.containsKey('Error')) {
            showError = true;
        } else {
            showError = false;
        }
        if(parameters.containsKey('ref')) {
            ref = parameters.get('ref');
        }
        record = new Verto_Form_Submission__c(
            RecordTypeId = Schema.sObjectType.Verto_Form_Submission__c.getRecordTypeInfosByName().get('Passport').getRecordTypeId()
        );
    }


    public PageReference cancelSubmission() {
        return Page.VertoPassportUpload.setRedirect(true);
    }

    /**
    * @description Attempts to insert the Verto_Form_Submission__c record into the database. Returns a PageReference that will render either a Thank You or Error page after execution.
    * @author NickHolly | 10-15-2021 
    * @return PageReference A PageReference with parameters set to render the Thank You or Error component, depending on result of the actions.
    **/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public PageReference submitInformation() {
        PageReference sitePage = Page.VertoPassportUpload;
        try {
            //Fill in the information that won't be collected from the form, if available.
            if(enrollmentRecord?.Id != null & enrollmentRecord?.Owner__c != null) {
                record.Enrollment_Record__c = enrollmentRecord.Id;
                record.OwnerId = enrollmentRecord?.Owner__c;
            }
            record.Acknowledgement_Date__c = System.today();
            record.Acknowledgement_Type__c = (program == 'Hawaii') ? 'It is my responsibility to have a valid travel document to travel by air to Hawaii.' : 'It is my responsibility to obtain legal documentation required for travel.';
            if(validPassport == 'Yes') {
                record.Type__c = 'Passport';
                sitePage.getParameters().put('ref','Passport');
            } else {
                record.Type__c = 'Application';
                sitePage.getParameters().put('ref','PassportApplication');
            }
            if(Schema.SObjectType.Verto_Form_Submission__c.isCreateable()) {
                record = (Verto_Form_Submission__c)VertoPassportUploadHelperWS.insertRecord(record);
            }
            if(fileData != null) {
                ContentVersion file = new ContentVersion(
                    VersionData = fileData,
                    Title = validPassport == 'Yes' ? 'Student Passport' : 'Student Passport Application Proof',
                    Guest_Site_fileupload__c = record.Id,
                    PathOnClient = fileName
                );
                if(Schema.SObjectType.ContentVersion.isCreateable()){
                    insert file;
                }
            }
            sitePage.getParameters().put('ThankYou','');
            sitePage.getParameters().put('ref', validPassport == 'Yes' ? 'Passport' : 'PassportApplication');
        } catch (Exception e) {
            Unhandled_Exception__c unhandledException = new Unhandled_Exception__c(
                Stack_Trace__c = e.getStackTraceString(),
                Line_Number__c = e.getLineNumber(),
                Message__c = e.getMessage(),
                Exception_Type__c = e.getTypeName(),
                Object_Data__c = JSON.serialize(record)
            );
            insert unhandledException;
            sitePage.getParameters().put('status','error');
        }
        sitePage.setRedirect(true);
        return sitePage;
    }

    /**
    * @description Invokes a Flow running within a System context to notify the Owner of the Enrollment Record.
    * @author NickHolly | 10-15-2021 
    * @return PageReference A PageReference with parameters set to render the Thank You or Error component, depending on result of the actions.
    **/
    public PageReference notifyRecordOwner() {
        PageReference page = Page.VertoPassportUpload;
        try {
            Map<String, Id> recordIds = new Map<String, Id>{'RecordId' => enrollmentRecord.Id};
            Flow.Interview.Passport_Upload_Notify_SOA notificationFlow = new Flow.Interview.Passport_Upload_Notify_SOA(recordIds);
            notificationFlow.start();
            page.getParameters().put('ThankYou','');
            page.getParameters().put('ref','Notify');
        } catch (Exception e) {
            Unhandled_Exception__c unhandledException = new Unhandled_Exception__c(
                Stack_Trace__c = e.getStackTraceString(),
                Line_Number__c = e.getLineNumber(),
                Message__c = e.getMessage(),
                Exception_Type__c = e.getTypeName(),
                Object_Data__c = JSON.serialize(record) + '\n Record Id:' + enrollmentRecord?.Id
            );
            insert unhandledException;
            page.getParameters().put('status','error');
        }
        page.setRedirect(true);
        return page;
    }

    /**
    * @description Getter for the yesOrNo variable.
    * @author NickHolly | 10-15-2021 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getYesOrNo() {
        return new List<SelectOption>{
            new SelectOption('',''), 
            new SelectOption('Yes','Yes'), 
            new SelectOption('No','No')
        };
    }

    /**
    * @description Getter for the countries variable.
    * @author NickHolly | 10-15-2021 
    * @return List<SelectOption> List values of valid Countries. Populated from the global country picklist.
    **/
    public List<SelectOption> getCountries() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        options.add(new SelectOption('United States', 'United States'));
        for(Schema.PicklistEntry pickval :Verto_Form_Submission__c.Legal_Document_Issuing_Country__c.getDescribe().getPicklistValues()) {
            if(pickval.value != 'United States') {
                options.add(new SelectOption(pickval.getValue(), pickval.getLabel()));
            }
        }
        return options;
    }

    /**
    * @description Getter for the newOrRecurring variable.
    * @author NickHolly | 10-15-2021 
    * @return List<SelectOption> List values of Passport Application options. Populated from the Verto_Form_Submission__c.New_or_Renewing_Passport__c picklist field.
    **/
    public List<SelectOption> getNewOrRenewing() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        for(Schema.PicklistEntry pickval :Verto_Form_Submission__c.New_or_Renewing_Passport__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(pickval.getValue(), pickval.getLabel()));
        }
        return options;
    }

    /**
    * @description Getter for program variable.
    * @author NickHolly | 10-15-2021 
    * @return List<SelectOption> List values of valid Programs. Currently hardcoded.
    **/
    public List<SelectOption> getPrograms() {
        return new List<SelectOption>{
            new SelectOption('',''),
            new SelectOption('Buenos Aires','Buenos Aires'),
            new SelectOption('Costa Rica','Costa Rica'),
            new SelectOption('Dublin','Dublin'),
            new SelectOption('Florence','Florence'),
            /* new SelectOption('Hawaii','Hawaii'), */
            new SelectOption('London','London'),
            new SelectOption('Prague','Prague'),
            new SelectOption('Seville','Seville')
        };
    }
    
    /**
    * @description Getter for passportSex variable.
    * @author NickHolly | 10-15-2021 
    * @return List<SelectOption>  List values or Passport Sex options. Populated from the Verto_Form_Submission__c.Legal_Document_Sex__c picklist field.
    **/
    public List<SelectOption> getPassportSex() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        for(Schema.PicklistEntry pickval :Verto_Form_Submission__c.Legal_Document_Sex__c.getDescribe().getPicklistValues()) {
            if(pickval.getValue() != 'Other') {
                options.add(new SelectOption(pickval.getValue(), pickval.getLabel()));
            }
        }
        return options;
    }
}