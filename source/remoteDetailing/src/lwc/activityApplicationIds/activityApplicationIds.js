/**
 * Created by sohatto on 21/04/2020.
 */

import getCurrentApplications from '@salesforce/apex/ActivityApplications.getCurrentApplications';
import updateApplicationIds from '@salesforce/apex/ActivityApplications.updateApplicationIds';
import getIsRDEnabled from '@salesforce/apex/ActivityApplications.getIsRDEnabled';
import {LightningElement, track, api, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';


export default class ActivityApplicationIds extends NavigationMixin(LightningElement) {
    @track dataArray = [];
    @track allOptions = [];
    @track defaultOptions = [];
    @track isEnabledRD = true;
    @api recId;

    @wire(getIsRDEnabled, {activityId: '$recId'})
    wiredM({error, data}) {
        if (data) {
            this.isEnabledRD = data;
        } else if (data === false) {
            this.isEnabledRD = data;
        }
        else if (error) {
            this.error = error;
        }
    }

    @wire(getCurrentApplications, {activityId: '$recId'})
    wiredMethod({error, data}) {
        if (data) {
            this.dataArray = data[0];
            let tempArray = [];

            this.dataArray.forEach(function (element) {
                let option =
                    {
                        label: element.Name,
                        value: element.Id
                    };
                tempArray.push(option);
            });

            this.allOptions = tempArray;
            this.defaultOptions = data[1];
        } else if (error) {
            this.error = error;
        }
    }

    get options() {
        return this.allOptions;
    }

    handleChange(e) {
        this.defaultOptions = e.detail.value;
    }

    handleClick() {
        updateApplicationIds({
            activityId: this.recId,
            applicationsIds: String(this.defaultOptions)
        })
            .then(result => {
            })
            .catch(error => {
                this.error = error;
            });

        const event = new ShowToastEvent({
            "title": "Success!",
            "message": "New applications have been updated",
        });
        this.dispatchEvent(event);

        setTimeout(() => {
            window.location.reload();
        }, 1500);
    }
}