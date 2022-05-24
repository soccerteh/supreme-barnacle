/*
  @description       : Prospective students use this form to enter basic contact information. 
  This is saved as an Inquiry__c object in SFA that is hooked to the related event
  @author            : Thomas E. Hamilton
  @group             : 
  @last modified on  : 11-19-2021
  @last modified by  : Thomas E. Hamilton
*/
//Imports necessary JS and Inquiry fields
import { LightningElement, api } from 'lwc';
import INQUIRY_OBJECT from '@salesforce/schema/Inquiry__c';
import FIRST_NAME from '@salesforce/schema/Inquiry__c.First_Name__c';
import LAST_NAME from '@salesforce/schema/Inquiry__c.Last_Name__c';
import EMAIL from '@salesforce/schema/Inquiry__c.Email__c';
import PHONE from '@salesforce/schema/Inquiry__c.Phone__c';
import COUNTRY from '@salesforce/schema/Inquiry__c.Country__c';
import ZIP from '@salesforce/schema/Inquiry__c.Zip_Postal_Code__c';
//import HIGHSCHOOL from '@salesforce/schema/Inquiry__c.Account__c';
import GRADYEAR from '@salesforce/schema/Inquiry__c.Year_of_Graduation__c';
import EVENT from '@salesforce/schema/Inquiry__c.Event__c';
import COUNSELOR from '@salesforce/schema/Inquiry__c.Counselor__c';
import { createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";

export default class HighSchoolEvent extends NavigationMixin(LightningElement) {
    //Set lightning spinner
    @api isLoaded = false;

    // Set imported fields to vars so they can display fields in lightning-record-edit-form
    inquiryObject = INQUIRY_OBJECT;
    firstNameField = FIRST_NAME;
    lastNameField = LAST_NAME;
    email = EMAIL;
    phone = PHONE;
    country = COUNTRY;
    zip = ZIP;
    gradYear = GRADYEAR;

    // The following funcitons handle onchange events for each input field
    enterFirstName(event) {
       this.firstNameField = event.target.value;
    }

    enterLastName(event){
        this.lastNameField = event.target.value;
    }

    enterEmail(event){
        this.email = event.target.value;
    }

    enterPhone(event){
        this.phone = event.target.value;
    }

    enterCountry(event){
        this.country = event.target.value;
    }

    enterZip(event){
        this.zip = event.target.value;
    }

    enterGradYear(event){
        this.gradYear = event.target.value;
    }

    // Handles onchange for checkbox. This determines if the Submit Button is disabled or not
    termsAndConditions(){
        const checkBox = this.template.querySelector('.termsAndConds');
        const button = this.template.querySelector('.slds-button');
        console.log(checkBox.checked);
        if(checkBox.checked === true){
            button.disabled = false;
            console.log(button.disabled);
        } else if (checkBox.checked === false){
            console.log("Checkbox is unchecked, do not enable Submit button");
            button.disabled = true;
        }
    }

    // Checks if all fields are valid, if not, it displays the errors next to the fields - called from submit button (saveInquiry())
    inquiry = {};
    isGradYear = false;
    isCountry = false;
    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            } else if(this.gradYear === GRADYEAR) {
                isValid = false;
                this.isGradYear = true;
            } else if(this.country === COUNTRY){
                isValid = false;
                this.isCountry = true;
            }
            this.inquiry[inputField.name] = inputField.value;
        });
        console.log('isValid is: '+ isValid);
        return isValid;
    }

    // Handles Submit Button
    saveInquiry() {
        // Confirms fields are valid before attempting to submit data
        if(this.isInputValid()) {
            console.log(this.inquiry);

            // Get Event & Counselor Id's from URL
            let testURL = window.location.href;
            console.log(testURL);
            let newURL = new URL(testURL).searchParams;
            let eventId = newURL.get('eid');
            let counselorId = newURL.get('cid');
            console.log(eventId);
            console.log(counselorId);

            //Disable Submit & Checkbox after clicking submit - prevents multiple submits && allows the user to make a mistake and have to use the checkbox to submit again
            this.template.querySelector('.slds-button').disabled = true
            this.template.querySelector('.termsAndConds').checked = false

            const recordInput = {
                apiName: INQUIRY_OBJECT.objectApiName,
                fields: {
                    [FIRST_NAME.fieldApiName] : this.firstNameField,
                    [LAST_NAME.fieldApiName] : this.lastNameField,
                    [EMAIL.fieldApiName] : this.email,
                    [PHONE.fieldApiName] : this.phone,
                    [COUNTRY.fieldApiName] : this.country,
                    [ZIP.fieldApiName] : this.zip,
                    [GRADYEAR.fieldApiName] : this.gradYear,
                    [EVENT.fieldApiName] : eventId,
                    [COUNSELOR.fieldApiName] : counselorId
                }
            };
            console.log(recordInput);

            //Starts lightning spinner
            this.isLoaded = !this.isLoaded;
            // Sends recordInput to SFA to create the Inquiry record
            createRecord(recordInput)
                .then(inquiry => {
                    // code to execute if create operation is successful
                    console.log('Inquiry Created: ' + inquiry.id);
                    //Trigger event to pass up to VF container - handles redirect to vertoeducation.org/apply
                    const searchinfo = { 
                        test: this.test
                    };
                    this.dispatchEvent(new CustomEvent(
                        'dosearch', 
                        {
                            detail: { data:  searchinfo},
                            bubbles: true,
                            composed: true,
                        }
                    ));
                })
                .catch(error => {
                    // code to execute if create operation is not successful
                    console.log('Error, please refresh the page and try again: ' + JSON.stringify(error));
                    console.log(error.body.message + ' ' + error.body.output.enhancedErrorType);
                    alert('Please confirm all fields are valid and the Terms of Service checkbox has been marked before pressing Submit Form');
                })
                .finally(() => {
                    //Turns off spinner
                    this.isLoaded = !this.isLoaded; 
                })
        } else if(this.isGradYear){
            alert('Please select a Year of High School Graduation.');
        } else if(this.isCountry){
            alert('Please select a Country.');
        }
    }
}