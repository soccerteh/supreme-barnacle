import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import CONTENTVERSION_OBJECT from '@salesforce/schema/ContentVersion';
import VERSIONDATA_FIELD from '@salesforce/schema/ContentVersion.VersionData';
import TITLE_FIELD from '@salesforce/schema/ContentVersion.Title';
import GUESTSITE_FIELD from '@salesforce/schema/ContentVersion.Guest_Site_fileupload__c';
import PATHONCLIENT_FIELD from '@salesforce/schema/ContentVersion.PathOnClient';

export default class FlowFileUpload extends LightningElement {

    @api fileUploadLabel = 'File Upload';
    @api accept;
    @api disabled = false;
    @api fileFieldName;
    @api fileFieldValue;
    @api label;
    @api multiple = false;
    @api name;
    @api recordId;
    @api hoverText;
    @api autoNavigateToNextStep = false;

    @api contentDocumentIds = [];
    @api fileNames = [];

    createContentVersion(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log('No. of files uploaded : ' + uploadedFiles.length);
                /*
        const uploadedFiles = event.detail.files;
        const recordInput = {
            apiName: CONTENTVERSION_OBJECT.objectApiName,
            fields: {
                [VERSIONDATA_FIELD .fieldApiName] : uploadedFiles,
                [TITLE_FIELD.fieldApiName] : "Test",
                [GUESTSITE_FIELD.fieldApiName] : this.recordId,
                [PATHONCLIENT_FIELD.fieldApiName] : "/Users/tom/Desktop"
            }
        };
        createRecord(recordInput)
            .then(account => {
                this.accountId = account.id;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'ContentVersion created',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });*/
    }


}