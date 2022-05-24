import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CourseCard extends LightningElement {
    @api name;
    @api course;
    @api showAddButton = false;
    @api primary;
    @api alternative;

    connectedCallback() {
        if (this.name === 'Social Problems') {
            this.primary = true;
        }
    }
    
    addPrimary() {
        this.handleClick('primary');
    }

    addAlternative() {
        this.handleClick('alternative');
    }

    handleClick(target) {
        if (this.name === 'Social Problems') {
            this.primary = true;
            this.sendSelectionUpdateEvent(target);
            return;
        }
        this.sendSelectionUpdateEvent(target);
    }

    sendSelectionUpdateEvent(updateProperty) {
        const updateEvent = new CustomEvent('selection', { detail: {
            name: this.course.name,
            destination: updateProperty,
            operation: this[updateProperty] ? 'remove' : 'add'
        }});
        this.dispatchEvent(updateEvent);
    }
}