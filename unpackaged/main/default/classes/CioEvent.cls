public with sharing class CioEvent{
    private String name;
    private Data data;
    
    public CioEvent() {
        //default constructor
    }

    public CioEvent setName(String name) {
        this.name = name;
        return this;
    }

    public CioEvent build(SObject record) {
        //get the SObject Type by evaluating the ID.
        String sObjectType = String.valueOf(((Id)record.get('Id')).getSObjectType());
        switch on sObjectType {
            when 'Application__c' {
                createApplicationEvent((Application__c) record);
            }
            when 'Enrollment_Record__c' {
                createEnrollmentEvent((Enrollment_Record__c) record);
            }
            when 'Inquiry__c' {
                createInquiryEvent((Inquiry__c) record);
            }
            when 'Lead' {
                createLeadEvent((Lead) record);
            }
            when 'Opportunity' {
                createOpportunityEvent((Opportunity) record);
            }
        }
        return this;
    }

    //A method per each derived class of Data is needed to build the properties.
    public CioEvent createInquiryEvent(Inquiry__c inquiry) {
        this.data = new InquiryData().build(inquiry);
        return this;
    }

    public CioEvent createApplicationEvent(Application__c application) {
        this.data = new ApplicationData().build(application);
        return this;
    }

    public CioEvent createOpportunityEvent(Opportunity opportunity) {
        this.data = new OpportunityData().build(opportunity);
        return this;
    }

    public CioEvent createEnrollmentEvent(Enrollment_Record__c enrollment) {
        this.data = new EnrollmentData().build(enrollment);
        return this;
    }

    public CioEvent createLeadEvent(Lead lead) {
        this.data = new LeadData().build(lead);
        return this;
    }
    /**
     * A derived class of Data loosely follows the factory builder
     * design pattern. This allows each type of event to be defined
     * neatly and separately from other types of events, while still
     * allowing the necessary property structure needed for sending
     * requests to CIO. Derived classes should be defined to meet
     * business requirements.
     */
    private abstract class Data {
        private abstract Data build(SObject record);
    }

    @SuppressWarnings('PMD.TooManyFields')
    //Data object which is a template for JSON event properties to CIO.
    private class ApplicationData extends Data {
        private String account;
        private String citizenStatus;
        private String city;
        private String collegePreviouslyAttended;
        private String country;
        private String criminalConviction;
        private Date dateOfBirth;
        private String disciplinaryViolation;
        private String dualCitizenshipCountry;
        private String email;
        private String enrollmentStatus;
        private String firstGenerationCollegeStudent;
        private String firstName;
        private Decimal gpa;
        private String gpaScale;
        private String highSchool;
        private String highSchoolCounselorEmail;
        private String highSchoolCounselorFirstName;
        private String highSchoolCounselorLastName;
        private String highSchoolCounselorPhone;
        private String highSchoolName;
        private String hispanicOrLatino;
        private String interestedInOpportunityGrant;
        private String internationalStudent;
        private String lastName;
        private String lead;
        private String leadSource;
        private String locationInterest;
        private String mobilePhone;
        private String optedIntoMarketing;
        private String parentGuardianEmail;
        private String parentGuardianFirstName;
        private String parentGuardianLastName;
        private String parentGuardianPhone;
        private String parentGuardian2Email;
        private String parentGuardian2FirstName;
        private String parentGuardian2LastName;
        private String parentGuardian2Phone;
        private String parentsGuardiansMaritalStatus;
        private String partner;
        private String postVertoPlans;
        private String postalCode;
        private String raceEthnicity;
        private String recordType;
        private String referralSource;
        private String semesterInterest;
        private String sex;
        private String source;
        private String stateProvince;
        private String studentsPermanentHome;
        private String usingFafsaTowardTuition;
        private String university;
        private String utmCampaignLastTouch;
        private String utmContentLastTouch;
        private String utmMediumLastTouch;
        private String utmSourceLastTouch;
        private String utmTermLastTouch;
        private String visaStatus;
        private String yearOfGraduation;

        private override Data build(SObject record) {
            Application__c application = (Application__c) record;
            this.account = application.Account__c;
            this.citizenStatus = application.Citizen_Status__c;
            this.city = application.City__c;
            this.collegePreviouslyAttended = application.College_Previously_Attended__c;
            this.country = application.Country__c;
            this.criminalConviction = application.Criminal_Conviction__c;
            this.dateOfBirth = application.Date_Of_Birth__c;
            this.disciplinaryViolation = application.Disciplinary_Violation__c;
            this.dualCitizenshipCountry = application.Dual_Citizenship_Country__c;
            this.email = application.Applicant_Email__c;
            this.enrollmentStatus = application.Enrollment_Status__c;
            this.firstGenerationCollegeStudent = application.First_Generation_College_Student__c;
            this.firstName = application.Applicant_First_Name__c;
            this.gpa = application.GPA__c;
            this.gpaScale = application.GPA_Scale__c;
            this.highSchool = application.High_School__c;
            this.highSchoolCounselorEmail = application.High_School_Counselor_Email__c;
            this.highSchoolCounselorFirstName = application.High_School_Counselor_First_Name__c;
            this.highSchoolCounselorLastName = application.High_School_Counselor_Last_Name__c;
            this.highSchoolCounselorPhone = application.High_School_Counselor_Phone__c;
            this.highSchoolName = application.High_School_Name__c;
            this.hispanicOrLatino = application.Hispanic_or_Latino_a_x__c;
            this.interestedInOpportunityGrant = application.Interested_In_Opportunity_Grant__c;
            this.internationalStudent = application.International_Student__c;
            this.lastName = application.Applicant_Last_Name__c;
            this.lead = application.Lead__c;
            this.leadSource = application.Lead_Source__c;
            this.locationInterest = application.Location_Interest__c;
            this.mobilePhone = application.Applicant_Mobile_Phone__c;
            this.optedIntoMarketing = application.Opted_Into_Marketing__c;
            this.parentGuardianEmail = application.Parent_Email__c;
            this.parentGuardianFirstName = application.Parent_First_Name__c;
            this.parentGuardianLastName = application.Parent_Last_Name__c;
            this.parentGuardianPhone = application.Parent_Phone_Number__c;
            this.parentGuardian2Email = application.Parent_Guardian_2_Email__c;
            this.parentGuardian2FirstName = application.Parent_Guardian_2_First_Name__c;
            this.parentGuardian2LastName = application.Parent_Guardian_2_Last_Name__c;
            this.parentGuardian2Phone = application.Parent_Guardian_2_Phone__c;
            this.parentsGuardiansMaritalStatus = application.Parents_Guardians_Marital_Status__c;
            this.partner = application.Partner__c;
            this.postVertoPlans = application.Post_Verto_Plans__c;
            this.postalCode = application.Postal_Code__c;
            this.raceEthnicity = application.Race_Ethnicity__c;
            this.recordType = application.RecordType.Name;
            this.referralSource = application.Referral_Source__c;
            this.semesterInterest = application.Semester_Interest__c;
            this.sex = application.Sex__c;
            this.source = application.Source__c;
            this.stateProvince = application.State_Province__c;
            this.studentsPermanentHome = application.Student_s_Permanent_Home__c;
            this.university = application.University__r.Name;
            this.usingFafsaTowardTuition = application.Using_FAFSA_Toward_Tuition__c;
            this.utmCampaignLastTouch = application.UTM_Campaign_Last_Touch__c;
            this.utmContentLastTouch = application.UTM_Content_Last_Touch__c;
            this.utmMediumLastTouch = application.UTM_Medium_Last_Touch__c;
            this.utmSourceLastTouch = application.UTM_Source_Last_Touch__c;
            this.utmTermLastTouch = application.UTM_Term_Last_Touch__c;
            this.visaStatus = application.Visa_Status__c;
            this.yearOfGraduation = application.Year_of_High_School_Graduation__c;
            return this;
        }
    }

    @SuppressWarnings('PMD.TooManyFields')
    //Data object which is a template for JSON event properties to CIO.
    public class EnrollmentData extends Data {
        private Boolean x90DaySemester;
        private String academicSuccessCoordinator;
        private String acceptedBySchoolOfRecord;
        private String acceptedToNonPartnerSchoolAlready;
        private Boolean acknowledgementOfRiskSigned;
        private Boolean begunPassportProcess;
        private String channelEnrollment;
        private String channelPartner;
        private String channelPartnerName;
        private Boolean codeOfConductSigned;
        private String collegeCounselor;
        private String collegePlanningFormLink;
        private Decimal courseScore;
        private Boolean covidSigned;
        private String createdBy;
        private Date dateActive;
        private Date dateCancel;
        private Date dateDismissed;
        private Date dateEnrolled;
        private DateTime dateEnrollmentFormSubmitted;
        private Date dateFinancialAppealFormSubmitted;
        private Date dateGraduated;
        private Date dateHealthHistoryFormSigned;
        private Date dateWithdrawalFormSubmitted;
        private Date dateWithdrew;
        private String e164Phone;
        private String email;
        private Boolean enrolledWithSoR;
        private Boolean enrollmentFormCompleted;
        private String enrollmentFormLink;
        private String enrollmentRecord;
        private String enrollmentStatus;
        private String fafsaCompleted;
        private Boolean financialAppealFormSubmitted;
        private String firstEnrollmentRecord;
        private String firstName;
        private Boolean flightsBooked;
        private Decimal flightsScore;
        private String generateSecondSemesterDepositCase;
        private Decimal gpa;
        private String haveEnoughInfoOnPartnerSchools;
        private Boolean hhfCompleted;
        private String housingPreference;
        private String insuranceApproved;
        private String interestLevel;
        private Boolean isMyStudent;
        private String lastModifiedBy;
        private String lastName;
        private String lastRetentionStatusUpdater;
        private Boolean matriculated;
        private String mobile;
        private String opportunity;
        private String owner;
        private Decimal passportScore;
        private String passportStatus;
        private String passportUploadFormLink;
        private Boolean paymentCancellationSigned;
        private Decimal paymentScore;
        private Boolean peaSigned;
        private String phone;
        private String planningOnUsingFafsa;
        private String program;
        private String programLocation;
        private String programSemester;
        private Date programStartDate;
        private String recordType;
        private String retentionChallenges;
        private String retentionChallengesNotes;
        private Decimal retentionScore;
        private String retentionStatus;
        private String roommateRequest;
        private String rqstInfoOnDeferralTransferCredit;
        private String schoolOfRecord;
        private String schoolOfRecordEmail;
        private String semesterWithdrawalFormLink;
        private Boolean semesterWithdrawalFormSubmitted;
        private String studentAccount;
        private String studentAccountPhone;
        private String studentIdNoSoR;
        private String studentLifeCoordinator;
        private Boolean vaccinationFormSubmitted;
        private Decimal vaccinationScore;
        private String validPassportConfirmed;
        private String validPassport;
        private Date visaAppointmentDateMailInDate;
        private String visaAppointmentNeeded;
        private String visaAppointmentType;
        private Date visaDocumentsSentDate;
        private Boolean visaReceived;
        private Decimal visaScore;
        private String visaStatus;
        private Date welcomeCallCompletedOn;
        private Boolean welcomePackageSent;
        private Date welcomePackageSentDate;
        private String withdrawalReason;
        private String withdrawalRequestLink;
        /* private */ 

        private override Data build(SObject record) {
            Enrollment_Record__c enrollment = (Enrollment_Record__c) record;
            this.x90DaySemester = enrollment.X90_Day_Semester__c;
            this.academicSuccessCoordinator = enrollment.Academic_Success_Coordinator__c;
            this.acceptedBySchoolOfRecord = enrollment.Accepted_By_School_Of_Record__c;
            this.acceptedToNonPartnerSchoolAlready = enrollment.Accepted_to_Non_Partner_School_Already__c;
            this.acknowledgementOfRiskSigned = enrollment.Acknowledgement_of_Risk_Signed__c;
            /* this.begunPassportProcess = enrollment.Began_Passport_Process__c; */
            this.channelEnrollment = enrollment.Channel_Enrollment__c;
            this.channelPartner = enrollment.Channel_Partner__r.Name;
            this.codeOfConductSigned = enrollment.Code_of_Conduct_Signed__c;
            this.collegeCounselor = enrollment.College_Counselor__c;
            this.collegePlanningFormLink = enrollment.College_Planning_Form_Link__c;
            this.courseScore = enrollment.Course_Score__c;
            this.covidSigned = enrollment.Covid_Signed__c;
            this.createdBy = enrollment.CreatedBy.Name;
            this.dateActive = enrollment.Date_Active__c;
            this.dateCancel = enrollment.Date_Cancel__c;
            this.dateDismissed = enrollment.Date_Dismissed__c;
            this.dateEnrolled = enrollment.Date_Enrolled__c;
            this.dateEnrollmentFormSubmitted = enrollment.Date_Enrollment_Form_Submitted__c;
            this.dateFinancialAppealFormSubmitted = enrollment.Date_Financial_Appeal_Form_Submitted__c;
            this.dateGraduated = enrollment.Date_Graduated__c;
            /* this.dateHealthHistoryFormSigned = enrollment.Date_Health_History_From_Signed__c; */
            this.dateWithdrawalFormSubmitted = enrollment.Date_Withdrawal_Form_Submitted__c;
            this.dateWithdrew = enrollment.Date_Withdrew__c;
            this.e164Phone = enrollment.E164_Phone__c;
            this.email = enrollment.Student_Account__r.Email__c;
            this.enrolledWithSoR = enrollment.Enrolled_With_SOR__c;
            this.enrollmentFormCompleted = enrollment.Enrollment_Form_Completed__c;
            this.enrollmentFormLink = enrollment.Enrollment_Form_Link__c;
            this.enrollmentRecord = enrollment.Name;
            this.enrollmentStatus = enrollment.Enrollment_Status__c;
            this.fafsaCompleted = enrollment.FAFSA_Completed__c;
            this.financialAppealFormSubmitted = enrollment.Financial_Appeal_Form_Submitted__c;
            this.firstEnrollmentRecord = enrollment.First_Enrollment_Record__c;
            this.firstName = enrollment.Student_Account__r.First_Name__c;
            this.flightsBooked = enrollment.Flights_Booked__c;
            this.flightsScore = enrollment.Flights_Score__c;
            this.generateSecondSemesterDepositCase = enrollment.Generate_Second_Semester_Deposit_Case__c;
            this.gpa = enrollment.GPA__c;
            this.haveEnoughInfoOnPartnerSchools = enrollment.Have_Enough_Info_On_Partner_Schools__c;
            this.hhfCompleted = enrollment.HHF_Completed__c;
            this.housingPreference = enrollment.Housing_Preference__c;
            this.insuranceApproved = enrollment.Insurance_Approved__c;
            this.interestLevel = enrollment.Interest_Level__c;
            this.isMyStudent = enrollment.isMyStudent__c;
            this.lastModifiedBy = enrollment.LastModifiedBy.Name;
            this.lastName = enrollment.Student_Account__r.Last_Name__c;
            this.lastRetentionStatusUpdater = enrollment.Last_Retention_Status_Updater__c;
            this.matriculated = enrollment.Matriculated__c;
            this.mobile = enrollment.Mobile__c;
            this.opportunity = enrollment.Opportunity__r.Name;
            this.owner = enrollment.Owner__r.Name;
            this.passportScore = enrollment.Passport_Score__c;
            this.passportStatus = enrollment.Passport_Status__c;
            this.passportUploadFormLink = enrollment.Passport_Upload_Form_Link__c;
            this.paymentCancellationSigned = enrollment.Payment_Cancellation_Signed__c;
            this.paymentScore = enrollment.Payment_Score__c;
            this.peaSigned = enrollment.PEA_Signed__c;
            this.phone = enrollment.Phone__c;
            this.planningOnUsingFafsa = enrollment.Planning_On_Using_FAFSA__c;
            this.program = enrollment.Program__r.Name;
            this.programLocation = enrollment.Program__r.Location__r.Name;
            this.programSemester = enrollment.Program__r.Semester__r.Name;
            this.programStartDate = enrollment.Program__r.Program_Start_Date__c;
            this.recordType = enrollment.RecordType.Name;
            this.retentionChallenges = enrollment.Retention_Challenges__c;
            this.retentionChallengesNotes = enrollment.Retention_Challenges_Notes__c;
            this.retentionScore = enrollment.Retention_Score__c;
            this.retentionStatus = enrollment.Retention_Status__c;
            this.rqstInfoOnDeferralTransferCredit = enrollment.Rqst_Info_On_Deferral_Transfer_Credit__c;
            this.schoolOfRecord = enrollment.School_Of_Record__c;
            this.schoolOfRecordEmail = enrollment.School_Of_Record_Email__c;
            this.semesterWithdrawalFormLink = enrollment.Semester_Withdrawal_Form_Link__c;
            this.semesterWithdrawalFormSubmitted = enrollment.Semester_Withdrawal_Form_Submitted__c;
            this.studentAccount = enrollment.Student_Account__r.Name;
            this.studentAccountPhone = enrollment.Student_Account__r.Phone;
            this.studentIdNoSoR = enrollment.Student_ID_SoR__c;
            this.studentLifeCoordinator = enrollment.Student_Life_Coordinator__c;
            this.vaccinationFormSubmitted = enrollment.Vaccination_Form_Submitted__c;
            this.vaccinationScore = enrollment.Vaccination_Score__c;
            this.validPassportConfirmed = enrollment.Valid_Passport_Confirmed__c;
            this.validPassport = enrollment.Valid_Passport__c;
            this.visaAppointmentDateMailInDate = enrollment.Visa_Appointment_Date_Mail_In_Date__c;
            this.visaAppointmentNeeded = enrollment.Visa_Appointment_Needed__c;
            this.visaAppointmentType = enrollment.Visa_Appointment_Type__c;
            this.visaDocumentsSentDate = enrollment.Visa_Documents_Sent_Date__c;
            this.visaReceived = enrollment.Visa_Recieved__c;
            this.visaScore = enrollment.Visa_Score__c;
            this.visaStatus = enrollment.Visa_Status__c;
            this.welcomeCallCompletedOn = enrollment.Welcome_Call_Completed_On__c;
            this.welcomePackageSent = enrollment.Welcome_Package_Sent__c;
            this.welcomePackageSentDate = enrollment.Welcome_Packet_Sent_Date__c;
            this.withdrawalReason = enrollment.Withdrawal_Reason__c;
            this.withdrawalRequestLink = enrollment.Withdrawal_Request_Link__c;
            return this;
        }
    }

    @SuppressWarnings('PMD.TooManyFields')
    //Data object which is a template for JSON event properties to CIO.
    private class InquiryData extends Data {
        //Include all properties of the data for the event
        private String country;
        private String email;
        private String firstName;
        private String highSchool;
        private String lastName;
        private String lead;
        private String optedIntoMarketing;
        private String parentEmail;
        private String parentFirstName;
        private String parentLastName;
        private String parentPhone;
        private String persona;
        private String phone;
        private String recordType;
        private String source;
        private String utmCampaignFirstTouch;
        private String utmContentFirstTouch;
        private String utmMediumFirstTouch;
        private String utmSourceFirstTouch;
        private String utmTermFirstTouch;
        private String yearOfGraduation;
        private String postalCode;

        private override Data build(SObject record) {
            Inquiry__c inquiry = (Inquiry__c) record;
            this.country = inquiry.Country__c;
            this.email = inquiry.Email__c;
            this.firstName = inquiry.First_Name__c;
            this.highSchool = inquiry.High_School__r.Name;
            this.lastName = inquiry.Last_Name__c;
            this.lead = inquiry.Lead__c;
            this.optedIntoMarketing = inquiry.Opted_Into_Marketing__c;
            this.parentEmail = inquiry.Parent_Email__c;
            this.parentFirstName = inquiry.Parent_First_Name__c;
            this.parentLastName = inquiry.Parent_Last_Name__c;
            this.parentPhone = inquiry.Parent_Phone_Number__c;
            this.persona = inquiry.Persona__c;
            this.phone = inquiry.Phone__c;
            this.recordType = inquiry.RecordType.Name;
            this.source = inquiry.Source__c;
            this.utmCampaignFirstTouch = inquiry.UTM_Campaign_First_Touch__c;
            this.utmContentFirstTouch = inquiry.UTM_Content_First_Touch__c;
            this.utmMediumFirstTouch = inquiry.UTM_Medium_First_Touch__c;
            this.utmSourceFirstTouch = inquiry.UTM_Source_First_Touch__c;
            this.utmTermFirstTouch = inquiry.UTM_Term_First_Touch__c;
            this.yearOfGraduation = inquiry.Year_Of_Graduation__c;
            this.postalCode = inquiry.Zip_Postal_Code__c;
            return this;
        }
    }

    @SuppressWarnings('PMD.TooManyFields')
    //Data object which is a template for JSON event properties to CIO.
    private class LeadData extends Data {
        private Address address;
        private String associatedApplication;
        private String country;
        private DateTime createdDate;
        private String email;
        private String firstName;
        private String lastName;
        private String leadOwnerCalendly;
        private String leadOwnerEmail;
        private String leadOwnerName;
        private String leadOwnerPhone;
        private String recordType;
        private String leadSource;
        private String leadStatus;
        private String parentGuardianEmail;
        private String parentGuardianFirstName;
        private String parentGuardianLastName;
        private String parentGuardian2Email;
        private String parentGuardian2FirstName;
        private String parentGuardian2LastName;
        private String persona;
        private String state;
        private String yearOfGraduation;

        private override Data build(SObject record){
            Lead lead = (Lead) record;
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
            this.recordType = lead.RecordType.Name;
            this.leadSource = lead.LeadSource;
            this.leadStatus = lead.Status;
            this.parentGuardianEmail = lead.Parent_email__c;
            this.parentGuardianFirstName = lead.Parent_First_Name__c;
            this.parentGuardianLastName = lead.Parent_Last_Name__c;
            this.parentGuardian2Email = lead.Parent_Guardian_2_Email__c;
            this.parentGuardian2FirstName = lead.Parent_Guardian_2_First_Name__c; 
            this.parentGuardian2LastName = lead.Parent_Guardian_2_Last_Name__c;
            this.persona = lead.Persona__c;
            this.state = lead.State;
            this.yearOfGraduation = lead.Year_of_Graduation__c;
            return this;
        }
    }

    @SuppressWarnings('PMD.TooManyFields')
    //Data object which is a template for JSON event properties to CIO.
    private class OpportunityData extends data {
        private String accountName;
        private String accountPhone;
        private String admissionDeniedReason;
        private Date applicationPacketSent;
        private Date approvalProcessCompletionDate;
        private String approvalStatus;
        private String associatedApplication;
        private String associatedApplicationSource;
        private String associatedApplicationUniversityName;
        private String associatedApplicationUtmSource;
        private Date bridgeCallCompletedDate;
        private Date closeDate;
        private String cohort;
        private String collegeCounselor;
        private Boolean commitmentFormComplete;
        private String commitmentFormLink;
        private String createdBy;
        private DateTime createdDate;
        private String currentProgram;
        private String depositPaylink;
        private Decimal earlyEnrollmentDiscountAmount;
        private String email;
        private String enrollmentAgreementLink;
        private DateTime enrollmentAgreementSignedDateTime;
        private String enrollmentRecord;
        private String enrollmentStatus;
        private Date familyAdmissionsCallBookedDate;
        private DateTime familyAdmissionsCallDateTime;
        private String familyAdmissionsCallStatus;
        private DateTime familyFinancialCallDateTime;
        private String firstName;
        private Date interviewStageDate;
        private DateTime lastActivity;
        private DateTime lastFamilyAdmissionsCallDateTime;
        private String lastmodifiedBy;
        private String lastName;
        private DateTime lastRequirementsGatheringDateTime;
        private String leadSource;
        private String lossReason;
        private Boolean matriculated;
        private DateTime mostRecentAdmittedDateTime;
        private Date mostRecentCallDate;
        private DateTime mostRecentConsiderationDateTime;
        private DateTime mostRecentDepositReceivedDateTime;
        private DateTime mostRecentQualificationDateTime;
        private DateTime mostRecentQualifiedDateTime;
        private Date newLeadDate;
        private String nextStep;
        private Integer numberOfCalls;
        private String opportunityName;
        private String opportunityOwner;
        private String opportunityOwnerCalendly;
        private String opportunityOwnerEmail;
        private String opportunityOwnerPhone;
        private String opportunityRecordType;
        private Integer opportunityScore;
        private String originalProgram;
        private String partnerAccount;
        private Date pendingEnrollmentStageDate;
        private String phone;
        private String postVertoPlans;
        private String source;
        private String stage;
        private String studentSuccessCoach;
        private String submitDocumentsForm;
        private String tier1Owner;
        private String type;

        private override Data build(SObject record) {
            Opportunity opportunity = (Opportunity) record;
            this.admissionDeniedReason = opportunity.Admission_Denied_Reason__c;
            this.applicationPacketSent = opportunity.Application_Packet_Sent__c;
            this.approvalProcessCompletionDate = opportunity.Approval_Process_Completion_Date__c;
            this.approvalStatus = opportunity.Approval_Status__c;
            this.associatedApplication = opportunity.Associated_Application__c;
            this.associatedApplicationSource = opportunity.Associated_Application_Source__c;
            this.associatedApplicationUniversityName = opportunity.Associated_Application_University_Name__c;
            this.associatedApplicationUtmSource = opportunity.Associated_Application_Utm_Source__c;
            this.bridgeCallCompletedDate = opportunity.Bridge_Call_Completed_Date__c;
            this.closeDate = opportunity.CloseDate;
            this.cohort = opportunity.Cohort__c;
            this.collegeCounselor = opportunity.College_Counselor__r.Name;
            this.commitmentFormComplete = opportunity.Commitment_Form_Complete__c;
            this.commitmentFormLink = 'https://vertoeducation.formstack.com/forms/commitment_form?accId=' + opportunity.AccountId;
            this.createdBy = opportunity.CreatedBy.Name;
            this.createdDate = opportunity.CreatedDate;
            this.currentProgram = opportunity.Current_Program__r.Name;
            this.depositPaylink = opportunity.Deposit_Paylink_Url__c;
            this.email = opportunity.Account.Email__c;
            this.earlyEnrollmentDiscountAmount = opportunity.Early_Enrollment_Discount_Amount__c;
            this.enrollmentAgreementLink = opportunity.Enrollment_Agreement_URL__c;
            this.enrollmentAgreementSignedDateTime = opportunity.Enrollment_Agreement_Signed_Date_Time__c;
            this.enrollmentRecord = opportunity.Enrollment_Record__c;
            this.enrollmentStatus = opportunity.Enrollment_Status__c;
            this.familyAdmissionsCallBookedDate = opportunity.Family_Interview_Booked_Date__c;
            this.familyAdmissionsCallDateTime = opportunity.Family_Admissions_Call_Date_Time__c;
            this.familyAdmissionsCallStatus = opportunity.Family_Admissions_Call_Status__c;
            this.familyFinancialCallDateTime = opportunity.Family_Financial_Call_Date_Time__c;
            this.firstName = opportunity.Account.First_Name__c;
            this.interviewStageDate = opportunity.Interview_Stage_Date__c;
            this.lastActivity = opportunity.Last_Activity__c;
            this.lastFamilyAdmissionsCallDateTime = opportunity.Last_Family_Admissions_Call_Date_Time__c;
            this.lastmodifiedBy = opportunity.LastModifiedBy.Name;
            this.lastName = opportunity.Account.Last_Name__c;
            this.lastRequirementsGatheringDateTime = opportunity.Last_Requirements_Gathering_Date_Time__c;
            this.leadSource = opportunity.LeadSource;
            this.lossReason = opportunity.Loss_Reason__c;
            this.matriculated = opportunity.Matriculated__c;
            this.mostRecentAdmittedDateTime = opportunity.Most_Recent_Admitted_Date_Time__c;
            this.mostRecentCallDate = opportunity.Most_Recent_Call_Date__c;
            this.mostRecentConsiderationDateTime = opportunity.Most_Recent_Consideration_Date_Time__c;
            this.mostRecentDepositReceivedDateTime = opportunity.Most_Recent_Deposit_Received_Date_Time__c;
            this.mostRecentQualificationDateTime = opportunity.Most_Recent_Qualification_Date_Time__c;
            this.mostRecentQualifiedDateTime = opportunity.Most_Recent_Qualified_Date_Time__c;
            this.newLeadDate = opportunity.New_Lead_Date__c;
            this.nextStep = opportunity.NextStep;
            this.numberOfCalls = (Integer) opportunity.Number_Of_Calls__c;
            this.opportunityName = opportunity.Name;
            this.opportunityOwner = opportunity.Owner.Name;
            this.opportunityOwnerCalendly = opportunity.Owner.Calendly_Link__c;
            this.opportunityOwnerEmail = opportunity.Owner.Email;
            this.opportunityOwnerPhone = opportunity.Owner.Phone;
            this.opportunityRecordType = opportunity.RecordType.Name;
            this.opportunityScore = opportunity.IqScore;
            this.originalProgram = opportunity.Original_Program__r.Name;
            this.partnerAccount = opportunity.PartnerAccountId;
            this.pendingEnrollmentStageDate = opportunity.Pending_Enrollment_Stage__c;
            this.phone = opportunity.Account.Phone;
            this.postVertoPlans = opportunity.Post_Verto_Plans__c;
            this.source = opportunity.Source__c;
            this.stage = opportunity.StageName;
            this.studentSuccessCoach = opportunity.Student_Success_Coach__c;
            this.submitDocumentsForm = opportunity.Submit_Documents_Form__c;
            this.tier1Owner = opportunity.Tier_1_Owner__r.Name;
            this.type = opportunity.Type;
            return this;
        }
    }

    public class CioEventException extends Exception {

    }
    //Add any additional derived classes for other types of events below
}