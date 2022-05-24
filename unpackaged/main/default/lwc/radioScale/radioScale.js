import { LightningElement, api } from 'lwc';

export default class RadioScale extends LightningElement {
    @api
    value;

    @api
    label;

    @api
    scaleLimit;

    options = [];

    setValue(event) {
        this.value = event.target.value;
    }
    
    connectedCallback() {
        for(let i = 1; i <= this.scaleLimit; i++) {
            this.options.push({
                'Id' : i,
                'Label' : i,
                'Value' : i,
                'Checked' : i === this.value ? true : false
            });
        }
    }
}