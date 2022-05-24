function validateConsent(element, buttonId, formType) {
    let consent = element.checked;
    let submitButton = document.getElementById(buttonId);
    let validInputs = validateInputs(formType);

    if(consent && validInputs) {
        submitButton.classList.remove('avoid-clicks');
    } else {
        element.checked = false;
        submitButton.classList.add('avoid-clicks');
    }
}

function handleHighSchoolChange() {
    let highSchool = document.getElementById('page:student-information:form-block:high-school').options[document.getElementById('page:student-information:form-block:high-school').selectedIndex].label;
    if(highSchool == 'Other') {
        document.querySelector('#other-high-school').style.display = 'block';
    } else {
        document.querySelector('#other-high-school').style.display = 'none';
    }
}

function handleProgramChange() {
    let program = document.getElementById('page:student-information:form-block:program').options[document.getElementById('page:student-information:form-block:program').selectedIndex].label;
    let acknowledgement = document.querySelector('#acknowledgement');
    let travelOptions = document.querySelector('#international-travel-options');
    let submit = document.querySelector('#submit-form');
    let acknowledgementText = document.querySelector('#acknowledgement-inner-text');
    
    if(program) {
        if(program == 'Hawaii') {
            acknowledgementText.innerHTML = 'Please confirm that you understand it is your responsibility to have a valid travel document to travel by air to Hawaii.';
            acknowledgement.style.display = 'block';
            submit.style.display = 'block';
            travelOptions.style.display = 'none';
        } else {
            //acknowledgementText.innerHTML = 'Please acknowledge uh uh uh';
            acknowledgement.style.display = 'none';
            submit.style.display = 'none';
            travelOptions.style.display = 'block';
        }
    } else {
        acknowledgement.style.display = 'none';
        submit.style.display = 'none';
        travelOptions.style.display = 'none';
    }
}

function handleValidPassportChange() {
    let answer = document.getElementById('page:student-information:form-block:valid-passport').options[document.getElementById('page:student-information:form-block:valid-passport').selectedIndex].label;
    let validPassport = document.querySelector('#valid-passport-questions');
    let invalidPassport = document.querySelector('#invalid-passport-questions');
    let submit = document.querySelector('#submit-form');
    let fileUpload = document.querySelector('#form-upload');
    let fileText = document.querySelector('#file-inner-text');
    let acknowledgement = document.querySelector('#acknowledgement');
    let acknowledgementText = document.querySelector('#acknowledgement-inner-text');

    if(answer == 'Yes') {
        validPassport.style.display = 'block';
        invalidPassport.style.display = 'none';
        submit.style.display = 'block';
        fileUpload.style.display = 'block';
        fileText.innerHTML = 'Please upload a copy of your valid Passport.';
        acknowledgement.style.display = 'block';
        acknowledgementText.innerHTML = 'Please confirm that you understand it is your responsibility to obtain legal documentation required for travel, such as a passport for international programs.';
    } else if(answer == 'No') {
        validPassport.style.display = 'none';
        invalidPassport.style.display = 'block';
        submit.style.display = 'none';
        fileUpload.style.display = 'none';
        acknowledgement.style.display = 'none';
        
        let passportSubmissionStatus = document.getElementById('page:student-information:form-block:passport-application-submitted').options[document.getElementById('page:student-information:form-block:passport-application-submitted').selectedIndex].label;
        let applicationQuestions = document.querySelector('#passport-application-submission-questions');
        let contactSSC = document.querySelector('#contact-student-success-coach');
        if(passportSubmissionStatus == 'Yes') {
            applicationQuestions.style.display = 'block';
            contactSSC.style.display = 'none';
            fileUpload.style.display = 'block';
            fileText.innerHTML = 'Please upload proof of your application submission.';
            submit.style.display = 'block';
            acknowledgement.style.display = 'block';
            acknowledgementText.innerHTML = 'Please confirm that you understand it is your responsibility to obtain legal documentation required for travel, such as a passport for international programs.';
        } else if (passportSubmissionStatus == 'No') {
            applicationQuestions.style.display = 'none';
            contactSSC.style.display = 'block';
        } else {
            applicationQuestions.style.display = 'none';
            contactSSC.style.display = 'none';
        }
    } else {
        validPassport.style.display = 'none';
        invalidPassport.style.display = 'none';
        submit.style.display = 'none';
        fileUpload.style.display = 'none';
    }
}

function validateInput(element) {
    if (!element.value) {
        element.classList.add('required-submission');
    } else {
        element.classList.remove('required-submission');
    }
}


function validateInputs(formType) {
    let validInputs = true;
    switch(formType) {
        case 'Passport':
            let program = document.getElementById('page:student-information:form-block:program').options[document.getElementById('page:student-information:form-block:program').selectedIndex].label;
            if(program == 'Hawaii') {
            } else {
                let validPassportAnswer = document.getElementById('page:student-information:form-block:valid-passport').options[document.getElementById('page:student-information:form-block:valid-passport').selectedIndex].label;
                if(validPassportAnswer == 'Yes') {
                    let legalNameInput = document.getElementById('page:student-information:form-block:legal-name');
                    let passportNumberInput = document.getElementById('page:student-information:form-block:passport-number');
                    let issuingCountryInput = document.getElementById('page:student-information:form-block:issuing-country');
                    let passportSexInput = document.getElementById('page:student-information:form-block:passport-sex');
                    let issueDateInput = document.getElementById('page:student-information:form-block:issue-date');
                    let expirationDateInput = document.getElementById('page:student-information:form-block:expiration-date');

                    if(!legalNameInput.value) {
                        legalNameInput.classList.add('required-submission');
                        validInputs = false;
                    } else {
                        legalNameInput.classList.remove('required-submission');
                    }
                    if(!passportNumberInput.value) {
                        passportNumberInput.classList.add('required-submission');
                        validInputs = false;
                    } else {
                        passportNumberInput.classList.remove('required-submission');
                    }
                    if(!issuingCountryInput.value) {
                        issuingCountryInput.classList.add('required-submission');
                        validInputs = false;
                    } else {
                        issuingCountryInput.classList.remove('required-submission');
                    }
                    if(!passportSexInput.value) {
                        passportSexInput.classList.add('required-submission');
                        validInputs = false;
                    } else {
                        passportSexInput.classList.remove('required-submission');
                    }
                    if(!issueDateInput.value) {
                        issueDateInput.classList.add('required-submission');
                        validInputs = false;
                    } else {
                        issueDateInput.classList.remove('required-submission');
                    }
                    if(!expirationDateInput.value) {
                        expirationDateInput.classList.add('required-submission');
                        validInputs = false;
                    } else {
                        expirationDateInput.classList.remove('required-submission');
                    }
                } else {
                    let passportSubmissionStatus = document.getElementById('page:student-information:form-block:passport-application-submitted').options[document.getElementById('page:student-information:form-block:passport-application-submitted').selectedIndex].label;
                    if(passportSubmissionStatus == 'Yes') {
                        console.log('Within proper scope');
                        let newOrRenewInput = document.getElementById('page:student-information:form-block:new-or-renewing');
                        let expeditedInput = document.getElementById('page:student-information:form-block:expedited');
                        let submittedDateInput = document.getElementById('page:student-information:form-block:submitted-date');
                        if(!newOrRenewInput.value) {
                            newOrRenewInput.classList.add('required-submission');
                            validInputs = false;
                        } else {
                            newOrRenewInput.classList.remove('required-submission');
                        }
                        if(!expeditedInput.value) {
                            expeditedInput.classList.add('required-submission');
                            validInputs = false;
                        } else {
                            expeditedInput.classList.remove('required-submission');
                        }
                        if(!submittedDateInput.value) {
                            submittedDateInput.classList.add('required-submission');
                            validInputs = false;
                        } else {
                            submittedDateInput.classList.remove('required-submission');
                        }
                    } 
                }
            }
            break;
    }
    return validInputs;
}

const validateEmail = (email) => {
    return String(email)
        .toLowerCase()
        .match(
            /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        );
};

function validateBasicInfo() {
    let firstName = document.getElementById('page:student-information:form-block:first-name');
    let lastName = document.getElementById('page:student-information:form-block:last-name');
    let email = document.getElementById('page:student-information:form-block:email');

    if(firstName.value && lastName.value && email.value) {
        if (validateEmail(email.value)) {
            document.querySelector('#basic-information').style.display = 'none';
            document.querySelector('#program-info').style.display = 'block';
        } else {
            email.classList.add('required-submission');
        }
    } else {
        if(!firstName.value) {
            firstName.classList.add('required-submission');
        }
        if(!lastName.value) {
            lastName.classList.add('required-submission');
        }
        if(!email.value) {
            email.classList.add('required-submission');
        }
    }
}

function lockSubmit(element) {
    element.value = 'Uploading Files...';
    element.classList.add('avoid-clicks');
}