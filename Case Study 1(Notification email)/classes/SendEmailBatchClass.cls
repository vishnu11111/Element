/********************************Batch for sending N26 Customers survey email*****************************/

public class SendEmailBatchClass implements Database.Batchable<sObject>, Database.Stateful{
        
      /*Variable to store the number of Contacts processed in each batch will be used to set the Email Sending limit 
   	this variable will retain values are Database.stateful is being used 
    */
    	Integer emailSendLimit = 0;
    	

    	
    	// Start method retrieving Contacts
    	public Database.QueryLocator start(Database.BatchableContext bc) {
            Date d = date.today();            // Retrieving today's date.
            return Database.getQueryLocator(
            'SELECT ID,Status,ContactId,Contact.Name,Claim_Approval_Date__c from Case where Status = \'Approved\' AND Claim_Approval_Date__c=:d');
            // Claim approval date in last line gets filled through workflow on case approval.
    	}
        
    
    	// Execute method validating Contact to be sent email and creating EmailMessage instance.
    	public void execute(Database.BatchableContext bc, List<Case> scope){
            
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();
        	for (Case iteratedCase : scope) {
            		emailSendLimit++;
                	if(emailSendLimit > 1000){
                    	break;
                	}
                	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
					message.targetObjectId = iteratedCase.ContactId;
					message.subject = 'Claim approved';
                    message.plainTextBody = 'Dear '+iteratedCase.Contact.Name+ ', Your claim is approved. You will receive the approved amount in 3-5 days.';
        			messages.add(message);
            }
            if(messages.size() > 0){
            	Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }    
                      
    }    
     
    public void finish(Database.BatchableContext bc){
        // No Action required in finish

    }    

}