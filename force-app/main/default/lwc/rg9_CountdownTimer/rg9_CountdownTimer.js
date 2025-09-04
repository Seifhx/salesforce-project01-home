import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class Rg9_CountdownTimer extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api fieldApiName;

    @track timeLeft;
    intervalId;

    // Monta os campos dinamicamente
    get fields() {
        if (this.objectApiName && this.fieldApiName) {
            return [`${this.objectApiName}.${this.fieldApiName}`];
        }
        return [];
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    wiredRecord({ error, data }) {
        if (data && this.fieldApiName) {
            // pega o valor de forma dinâmica
            const dueDateValue = data.fields[this.fieldApiName]?.value;

            if (dueDateValue) {
                this.startCountdown(new Date(dueDateValue));
            }
        } else if (error) {
            console.error('Erro ao buscar registro:', error);
        }
    }


    startCountdown(dueDate) {
        clearInterval(this.intervalId);

        const updateTime = () => {
            const now = new Date();
            const diff = dueDate.getTime() - now.getTime();

            if (diff <= 0) {
                this.timeLeft = { days: 0, hours: 0, minutes: 0, seconds: 0, expired: true };
                clearInterval(this.intervalId);
                return;
            }

            const days = Math.floor(diff / (1000 * 60 * 60 * 24));
            const hours = Math.floor((diff / (1000 * 60 * 60)) % 24);
            const minutes = Math.floor((diff / (1000 * 60)) % 60);
            const seconds = Math.floor((diff / 1000) % 60);

            this.timeLeft = { days, hours, minutes, seconds, expired: false };
        };

        updateTime();
        this.intervalId = setInterval(updateTime, 1000); // atualiza a cada segundo
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
    }
    
}