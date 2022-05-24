import { LightningElement, api } from 'lwc';

export default class CartItem extends LightningElement {
    //change to item object with properties
    @api itemName;
    @api subItemName;
    @api first;
    @api last;

    handleOnClick(event) {
        const moveEvent = new CustomEvent(event.target.name, { detail: this.itemName });
        this.dispatchEvent(moveEvent);
    }
}