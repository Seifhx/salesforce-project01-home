import { LightningElement, wire, track } from 'lwc';
import getUserName from '@salesforce/apex/HomeWelcomeController.getUserName';

export default class HomeWelcomeBlock extends LightningElement {
    @track userName = 'usuário';

    @wire(getUserName)
    wiredUserName({ error, data }) {
        if (data) {
            this.userName = data;
        } else if (error) {
            this.userName = 'usuário';
        }
    }
}