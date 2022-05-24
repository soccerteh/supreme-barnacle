import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Cart extends LightningElement {
    _items = [];
    _totalUnits;
    @api cartName = 'cart'; //default name for the cart
    @api limit = 100; //default maximum limit of items;
    @track cart = []; //default empty cart

    @api
    addItems(item) {
        if(this.validateAdd(item)) {
            this.cart = [...this.cart, item];
            this.calculuateTotalUnits();
        }
        this.updateItems();
        return this.getItems();
    }

    @api
    removeItem(item) {
        this.cart = [...this.cart].filter(cartItem => cartItem.primaryItemId !== item.primaryItemId);
        this.calculuateTotalUnits();
        this.updateItems();
        return this.getItems();
    }

    @api 
    getItems() {
        this.updateItems();
        return this._items;
    }

    @api
    getTotalUnits() {
        if (!this._totalUnits) {
            this.calculuateTotalUnits();
        }
        return this._totalUnits;
    }
    
    @api
    getIsInCart(item) {
        const itemInCart = [...this.cart].filter((cartItem) => {
            return (cartItem.primaryItemId === item.id || cartItem.subItemId === item.id)
        });
        if (itemInCart.length > 0) {
            this.showAlreadyInCartWarning();
            return true;
        }
        return false;
    }

    @api
    getIsRoomAvailable(numberOfItems) {
        if (Number.isNaN(numberOfItems)) {
            throw 'Expecting the number of items to be added.';
        }
        if (this._items.length + numberOfItems > this.limit) {
            this.showMaximumCoursesAddedWarning();
        }
        return (this._items.length + numberOfItems <= this.limit);
    }
    
    validateAdd(...items) {
        const itemsNotInCart = [...items].filter((item) => {
            return !this.getIsInCart(item.items[0]);
        });
        return (this.getIsRoomAvailable(items.length) || itemsNotInCart.length === items.length);
    }

    updateItems() {
        //iterate over array of cart.items 
        const items = [];
        this.cart.forEach(item => {
            items.push(...item.items)
        });
        this._items = items;
    }

    getIsLimitReached() {
        let limitReached = this.limit <= this.cart.length;
        if (limitReached) {
            this.showMaximumCoursesAddedWarning();
        }
        return limitReached;
    }
    //example:
    

    handleOnIncrement(event) {
        let index = [...this.cart].findIndex((item) => {
            return item.primaryItemName === event.detail
        });
        let items = [...this.cart];
        if (index !== items.length - 1) {
            let temp = items[index + 1];
            items[index + 1] = items[index];
            items[index] = temp;
            this.cart = items;
        }
    }

    handleOnDecrement(event) {
        let index = [...this.cart].findIndex((item) => {
            return item.primaryItemName === event.detail
        });
        if (index !== 0) {
            let items = [...this.cart];
            let temp = items[index - 1];
            items[index - 1] = items[index];
            items[index] = temp;
            this.cart = items;
        }
    }

    calculuateTotalUnits() {
        this._totalUnits = [...this._items].reduce((total, item) => {
            return total + parseInt(item.units);
        }, 0);
    }

    showMaximumCoursesAddedWarning() {
        const event = new ShowToastEvent({
            title : 'Maximum Courses Added.',
            variant : 'warning',
            message : 
                `Up to ${this.limit} ${this.cartName} courses may be selected. Please remove a course before attempting to add more.`
        });
        this.dispatchEvent(event);
    }

    showAlreadyInCartWarning(itemName) {
        const event = new ShowToastEvent({
            title: `${itemName} Not Added`,
            variant: 'error',
            message: 
                'This course is already selected.'
        });
        this.dispatchEvent(event);
    }
}