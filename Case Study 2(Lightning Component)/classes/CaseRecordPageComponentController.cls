public with sharing class CaseRecordPageComponentController {
    
    @auraEnabled
    public static ReturnWrapper getDataForCaseRecordPage( List<String> caseId ) {
        ReturnWrapper returnWrapperInstance = new ReturnWrapper();
        List<Case_Policy__c> casePolicyList = [Select Id,Name,Policy__r.Name,Policy__r.Description__c from Case_Policy__c where Case__c=: caseId[0]];
        returnWrapperInstance.casePolicies = casePolicyList;
        makeCallout(caseId);
        Case c = [Select Id,Payment_Amount__c,Payment_Date__c,Last_Sync_Date__c,Updated_From_External_System__c,Customer_Account_Number__c from Case where Id=: caseId];
        returnWrapperInstance.caseDetails = c;
        return returnWrapperInstance;
    }    
    
    public static void makeCallout( List<String> caseId ) {
        
        // Map to hold all the Callouts that will be done.
        Map<HttpRequest, Id> requests = new Map<HttpRequest, Id>();
        
        HttpRequest request;
        HTTPResponse response;
        
        if(caseID != null){
            
            //do the callout
            request = new HttpRequest();
            request.setEndpoint( 'callout:PaymentInformation'  );
            request.setMethod( 'GET' );
            request.setHeader( 'Content-Type', 'application/json' );
            requests.put( request, caseID[0] );
        }
        
        Http http = new Http();
        response = new HTTPResponse();
        
        List<Case> casesToUpdateList = new List<Case>();
        //for all the requests made for CaseIds
        for( HttpRequest req : requests.keySet() ){
            
            try{
                
                //do the callout
                response = http.send( req );
                
                //Get the Case for which callout was made
                Case caseToUpdate = new Case(Id = requests.get( req ));
                
                //check the response and update the Case likewise
                if ( response.getStatusCode() == 200 ) {
                    caseToUpdate.Updated_From_External_System__c = true;
                    caseToUpdate.Last_Sync_Date__c = Datetime.now();
                    
                    List<CasePaymentsWrapper> casePayment = (List<CasePaymentsWrapper>)JSON.deserialize(response.getBody(), List<CasePaymentsWrapper>.class);
                    caseToUpdate.Payment_Amount__c = Integer.valueOf(casePayment[0].amount);
                    
                    caseToUpdate.Payment_Date__c = Date.valueOf(casePayment[0].paymentDate);
                    caseToUpdate.Customer_Account_Number__c = String.valueOf(casePayment[0].accountNumber); 
                      
                } else {
                    caseToUpdate.Updated_From_External_System__c = false;
                    //Do the Error logging here with the Failure Response
                }
                casesToUpdateList.add( caseToUpdate ); 
                
            }catch(Exception ex){
                //Do the Error logging here too
                System.debug('Exception occured:: ' +ex);
            }
        }
        
        //If list exists
        if(casesToUpdateList.size() > 0 ){
            update casesToUpdateList;
        }
        
        //DO the API Logging: get the details of how many API calls were made today using this service
        
        //Do the logging using a custom object(say API_Logging__c) 
        Date tdy = Date.today();
        String query = 'select Id, EventType, LogDate, LogFileLength from EventLogFile where (EventType = \'API\' OR EventType = \'ApexCallout\' ) and LogDate = :tdy';
        System.debug('event log results:: ' +Database.query(query));
        
        
    }
    public class CasePaymentsWrapper
    {
        public String paymentDate;
        public Integer amount;
        public Integer accountNumber;
        public String body;
    }
    
     public class ReturnWrapper
    {
        @auraEnabled
        public List<Case_Policy__c> casePolicies;
        @auraEnabled
        public Case caseDetails;
        
    }
    
    
}
