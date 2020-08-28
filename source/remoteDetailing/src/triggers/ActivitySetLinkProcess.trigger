/**
 * CT CLM Remote Detailing,
 * Copyright (C) 2007-2020 Customertimes Corp.
 * 3 Columbus Circle, 15th Floor, #1513
 * New York, NY 10019
 * mailto:support@customertimes.com
 *
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

trigger EventSetLinkProcess on Event (after insert, after update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        if (!System.isFuture() && !System.isBatch()) { 
                Setup setup = new Setup();
            
                // Type here API names of necessary record types
                setup.selfDetailingRecordTypes = new List<String>{'Timeoff'}; // <--- API name(s) of record types of an Activity object for Self Detailing flow
                setup.remoteDetailingRecordTypes = new List<String>{'Visit'}; // <--- API name(s) of record types of an Activity object for Remote Detailing flow
    
                String setupJSON = JSON.serialize(setup); 
                clm.ActivityProcessHandler ph = new clm.ActivityProcessHandler(setupJSON, Trigger.new);
        }
    }
    
    public class Setup {
        public List<String> selfDetailingRecordTypes = new List<String>();
        public List<String> remoteDetailingRecordTypes = new List<String>();
    }
    
}