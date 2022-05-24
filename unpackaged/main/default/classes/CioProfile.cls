public with sharing class CioProfile {

    private Address address;
    private String associatedApplication;
    private String collegeCounselor;
    private String collegeCounselorCalendly;
    private String collegeCounselorEmail;
    private String collegeCounselorPhone;
    private String country;
    private DateTime createdDate;
    private String currentProgram;
    private String currentSemester;
    private String email;
    private String enrollmentOwner;
    private String familyInterviewBookedDate;
    private String familyAdmissionsCallCalendly;
    private String familyAdmissionsCallDateTime;
    private String familyAdmissionsCallStatus;
    private String firstGenerationCollegeStudent;
    private String firstName;
    private Decimal gpa;
    private String gpaScale;
    private Date highSchoolTranscriptSubmittedOn;
    private String lastName;
    private String leadOwnerCalendly;
    private String leadOwnerEmail;
    private String leadOwnerName;
    private String leadOwnerPhone;
    private String leadRecordType;
    private String leadSource;
    private String leadStatus;
    private String opportunityOwnerCalendly;
    private String opportunityOwnerEmail;
    private String opportunityOwnerName;
    private String opportunityOwnerPhone;
    private String parentGuardianEmail;
    private String parentGuardianName;
    private String parentGuardian2Email;
    private String parentGuardian2Name;
    private String persona;
    private String phone;
    private String postVertoPlans;
    private String schoolOfRecord;
    private String stage;
    private String state;
    private Date writingSampleSubmittedOn;
    private String yearOfGraduation;
    private String zipCode;

    public CioProfile build(SObject record) {
        String sObjectType = String.valueOf(((Id)record.get('Id')).getSObjectType());
        switch on sObjectType {
            when 'Lead' {
                buildLeadProfile((Lead) record);
            }
            when 'Inquiry__c' {
                buildInquiryProfile((Inquiry__c) record);
            }
        }
        return this;
    }

    private void buildInquiryProfile(Inquiry__c inquiry) {
        this.createdDate = inquiry.CreatedDate;
        this.email = inquiry.Email__c;
        this.firstName = inquiry.First_Name__c;
        this.lastName = inquiry.Last_Name__c;
        this.persona = inquiry.Persona__c;
    }

    private void buildLeadProfile(Lead lead) {
        User leadOwner = lead.Owner;
        this.address = lead.address;
        this.associatedApplication = lead.Associated_Application__c;
        this.country = lead.Country;
        this.createdDate = lead.createdDate;
        this.email = lead.Email;
        this.firstName = lead.FirstName;
        this.lastName = lead.LastName;
        this.leadOwnerCalendly = leadOwner?.Calendly_Link__c;
        this.leadOwnerEmail = leadOwner?.Email;
        this.leadOwnerName = leadOwner?.Name;
        this.leadOwnerPhone = leadOwner?.Phone;
        this.leadRecordType = lead.RecordType.Name;
        this.leadSource = lead.LeadSource;
        this.leadStatus = lead.Status;
        this.parentGuardianEmail = lead.Parent_email__c;
        this.parentGuardianName = lead.Parent_First_Name__c + ' ' + lead.Parent_Last_Name__c;
        this.parentGuardian2Email = lead.Parent_Guardian_2_Email__c;
        this.parentGuardian2Name = lead.Parent_Guardian_2_First_Name__c + ' ' + lead.Parent_Guardian_2_Last_Name__c;
        this.persona = lead.Persona__c;
        this.state = lead.State;
        this.yearOfGraduation = lead.Year_of_Graduation__c;
    }


    private class CioProfileException extends Exception {

    }
}