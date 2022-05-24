import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import COURSE from '@salesforce/schema/Course__c';
import SUBJECT from '@salesforce/schema/Course__c.Subject__c';
import getEligibleCourses from '@salesforce/apex/CourseInterestController.getEligibleCourses';
import saveCourseSelection from '@salesforce/apex/CourseInterestController.saveCourseSelection';

const columns = [
    {
        label: 'Course',
        fieldName: 'name',
        type: 'string',
        hideDefaultActions: true
    },
    {
        label: 'Credits',
        fieldName: 'units',
        type: 'number',
        hideDefaultActions: true
    }
];

export default class CourseRegistration extends NavigationMixin(LightningElement) {
    columns = columns;
    eligibility = [];
    subjects = [];
    loading = true;
    _filterBy;
    @track showNotEligibleModal = false;
    @track showConfirmationModal = false;
    @track showModal = false;
    @track rtId;
    @track ineligibleCourses = [];
    @track eligibleCourses = [];
    @track filteredCourses = [];
    @track primary = [];
    @track alternative = [];
    @track creditHourTotal = 0;
    @wire(getObjectInfo, { objectApiName: COURSE })
    handleResult({ data, error }) {
        if (data) {
            this.rtId = data.defaultRecordTypeId;
        }
    }
    @wire(getPicklistValues, { recordTypeId: "$rtId", fieldApiName: SUBJECT })
    picklistValues({ data, error }) {
        if (data) {
            this.subjects = [{ label: '- None -', value: '' }, ...data.values];
        }
    }
    @wire(getEligibleCourses)
    courseEligibility({ data, error }) {
        if (data) {
            [...data].forEach((eligibliity) => {
                this.eligibility.push(
                    Object.assign({}, eligibliity, {primary: false, alternative: false})
                )
            })
            this.eligibleCourses = [...data].filter((eligibility) => eligibility.isEligible);
            this.ineligibleCourses = [...data].filter((eligibility) => !eligibility.isEligible);
            this.resetFilteredCourses();
            this.loading = false;
            this.specialActions();
        } else if (error) {
            //potentially do something with the error.body.message in future iterations to change output.
            this.redirectToErrorPage();
        }
    }

    handleCourseSelected(event) {
        if (event.detail.name === 'Social Problems') {
            const failedValidationToast = new ShowToastEvent({
                title: `Unable to remove ${event.detail.name}.`,
                variant: 'error',
                message:
                    'Social Problems is a compulsory course and may not be removed or altered.'
            });
            this.dispatchEvent(failedValidationToast);
            return;
        }
        try {
            const courses = [];
            const courseEligibility = this.eligibleCourses.filter((eligibility) => eligibility.course.name === event.detail.name)[0];
            const selectedCourse = courseEligibility.course;
            courses.push(selectedCourse);
            if (event.detail.operation === 'add') {
                if (!courseEligibility.requiresCorequisite) {
                    if (this.getIfCourseWithinAnyCart(selectedCourse)) {
                        //failed state as the course is already within a cart.
                        return;
                    }
                    if (!this.getIfCartHasRoomForCourses(courses.length, event.detail.destination)) {
                        //failed state as there isn't room within the cart identified.
                        return;
                    }
                    const cartItem = this.createCartItem(courses);
                    this.add(cartItem, event.detail.destination);
                    return;
                    //update status of course card
                }
                //check if corequisite in target cart before doing further logic
                const corequisite = this.eligibleCourses.filter((eligibility) => eligibility.course.name === courseEligibility.corequisiteCourseName)[0].course;
                const inDestinationCart = [...this.template.querySelectorAll('c-cart')]
                    .filter((cart) => cart.classList.contains(event.detail.destination))[0]
                    .getIsInCart(corequisite);
                if (!inDestinationCart) {
                    courses.push(corequisite);
                    if (this.getIfCourseWithinAnyCart(selectedCourse)) {
                        return;
                    }
                    if (!this.getIfCartHasRoomForCourses(courses.length, event.detail.destination)) {
                        return;
                    }
                    const cartItem = this.createCartItem(courses);
                    this.add(cartItem, event.detail.destination);
                }
            } else {
                if (!courseEligibility.requiresCorequisite) {
                    const cartItem = this.createCartItem(courses);
                    this.remove(cartItem, event.detail.destination);
                    return;
                }
                const cartItem = this.createCartItem(courses);
                this.remove(cartItem, event.detail.destination);
                return;
            }
        } catch (error) {
            console.log('Error:');
            console.log(error);
        }
    }

    getIfCourseWithinAnyCart(course) {
        let cartsWithCourse = [...this.template.querySelectorAll('c-cart')].filter((cart) => {
            return cart.getIsInCart(course);
        });
        return cartsWithCourse.length > 0;
    }

    getIfCartHasRoomForCourses(numberOfItems, destination) {
        return [...this.template.querySelectorAll('c-cart')]
            .filter((cart) => cart.classList.contains(destination))[0]
            .getIsRoomAvailable(numberOfItems);

    }

    validateSubmit() {
        const validateError = new ShowToastEvent({
            title: 'Error:',
            variant: 'error'
        });

        if (this.creditHourTotal < 12) {
            const validateError = new ShowToastEvent({
                title: 'Error:',
                variant: 'error',
                message: 
                    'A minimum of 12 credit hours is required.'
            });
            dispatchEvent(validateError);
            return;
        }
        if ([...this.primary].length < 2 || [...this.alternative].length < 2) {
            const validateError = new ShowToastEvent({
                title: 'Error:',
                variant: 'error',
                message: 
                    'At least two primary and two alternatives are required.'
            });
            dispatchEvent(validateError);
            return;
        }
        this.updateCarts();
        this.toggleShowConfirmationModal();
    }

    add(cartItem, destination) {
        let cart = [...this.template.querySelectorAll('c-cart')].filter((cart) => cart.classList.contains(destination))[0];
        this[destination] = cart.addItems(cartItem);
        cartItem.items.forEach((item) => {
            let course = this.eligibility.filter((eligibility) => eligibility.course.name === item.name)[0];
            course[destination] = true;
        });
        this.getCreditHourTotalForPrimary();
        this.resetFilteredCourses();
        return true;
    }

    remove(cartItem, destination) {
        let cart = [...this.template.querySelectorAll('c-cart')].filter(element => element.classList.contains(destination))[0];
        this[destination] = cart.removeItem(cartItem);
        cartItem.items.forEach((item) => {
            this.eligibility.filter((eligibility) => eligibility.course.name === item.name)[0][destination] = false;
        });
        this.getCreditHourTotalForPrimary();
        this.resetFilteredCourses();
        return true;
    }

    createCartItem(courses) {
        const items = [];
        courses.forEach((item) => {
            items.push({
                id: item.id,
                name: item.name,
                units: item.creditHours
            });
        })
        return {
            items: items,
            primaryItemId: items[0].id,
            primaryItemName: items[0].name,
            subItemId: items[1]?.id,
            subItemName: items[1]?.name
        }
    }

    save(event) {
        saveCourseSelection({
            primaryChoices: [...this.primary],
            altChoices: [...this.alternative]
        })
            .then(result => {
                this.toggleShowConfirmationModal();
                this.redirectToNextPage(event);
            })
            .catch(error => {
                const errorSavingToast = new ShowToastEvent({
                    title: 'Uh Oh.',
                    variant: 'error',
                    message:
                        'Something went wrong, however we were still able to save your selections.'
                });
                this.dispatchEvent(errorSavingToast);
            });
    }

    redirectToNextPage(event) {
        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Course_Confirmation__c' 
            }
        });
    }

    redirectToErrorPage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Course_Registration_Error__c'
            }
        });
    }

    getCorequisiteCourses(selectedCourse) {
        return [...this.eligibleCourses].filter((eligibility) => eligibility.course.name === selectedCourse.corequisiteCourseName || eligibility.corequisiteCourseName === selectedCourse.course.name);
    }


    getCreditHourTotalForPrimary() {
        if (this.primary.length > 0) {
            this.creditHourTotal = [...this.primary].reduce((total, item) => {
                return total + parseInt(item.units);
            }, 0);
        }
    }

    handleFilterChange(event) {
        this._filterBy = event.target.value;
        this.resetFilteredCourses();
    }

    resetFilteredCourses() {
        if (this._filterBy) {
            this.filteredCourses = this.eligibility.filter((eligibility) => eligibility.course.subject === this._filterBy && eligibility.isEligible);
        } else {
            this.filteredCourses = [
                this.eligibility.filter((eligibility) => eligibility.course.name === 'Social Problems')[0],
                ...this.eligibility.filter((eligibility) => eligibility.course.name !== 'Social Problems' && eligibility.isEligible)
            ];
        }
    }

    toggleShowNotEligibleModal() {
        this.showNotEligibleModal = !this.showNotEligibleModal;
        this.showModel = (this.showNotEligibleModal || this.showConfirmationModal);
    }

    toggleShowConfirmationModal() {
        this.showConfirmationModal = !this.showConfirmationModal;
        this.showModel = (this.showNotEligibleModal || this.showConfirmationModal);
    }

    updateCarts() {
        [...this.template.querySelectorAll('c-cart')].forEach((cart) => {
            this[cart.cartName] = cart.getItems();
        });
    }

    specialActions() {
        //add social problems to list of primary courses by default;
        try {
            const socialProblems = this.createCartItem(
                [this.eligibility.filter((eligibility) => eligibility.course.name === 'Social Problems')[0].course]
            );
            this.add(socialProblems, 'primary');
        } catch (error) {
            console.log(error);
        }
    }
}