import { LightningElement, wire, track } from 'lwc';
import getRecordCountBySubJornada from '@salesforce/apex/BigNumberController.getRecordCountBySubJornada';

export default class BigNumber extends LightningElement {
    @track total = 0;
    @track breakdown = [];
    @track showBreakdown = false;

    @wire(getRecordCountBySubJornada)
    wiredCounts({ error, data }) {
        if (data) {
            this.breakdown = data.map(row => ({
                label: row.subJornada, // alias definido no Apex
                count: row.total       // alias definido no Apex
            }));

            this.total = this.breakdown.reduce((acc, r) => acc + r.count, 0);
        } else if (error) {
            console.error(error);
        }
    }

    handleMouseEnter() {
        this.showBreakdown = true;
    }

    handleMouseLeave() {
        this.showBreakdown = false;
    }
}
