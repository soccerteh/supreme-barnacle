import { LightningElement, api } from 'lwc';

export default class Mock extends LightningElement {
    @api name = 'Social Problems';
    @api subject = 'Sociology';
    @api creditHours = 3;
    @api description = 'This compulsory course examines a range of problematic issues facing society. Conflicting perspectives, research findings, theoretical explanations and societal responses will be discussed regarding such issues as: distribution of resources, national security, the environment, race, gender, family, the medical industry and the justice process.';
    @api prerequisiteDescription;
    @api corequisiteDescription;
    selections = {
        primary: false,
        alternative: false
    };

    addPrimary() {

    }

    addAlternative() {

    }
}