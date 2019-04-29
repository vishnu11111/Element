//Test class for fSendSurveyEmailBatchClass 
@isTest (seeAllData=False)
public class Test_CaseComponentController
{
  	public static List<String> caseIds = new List<String>();
    @testsetup 
    public static void createData(){
        
   			Contact con = new Contact();
            con.LastName = 'LastName';
            con.FirstName = 'FirstName';
            con.Email = 'test@example.com';
            con.survey_date__c = Date.newInstance(2019, 02, 9);
            con.language__c = 'en';
        
        if(con != null){ 
        	insert con;
        }
        Case c = new Case();
        c.ContactId = con.Id;
        c.Origin = 'Email';
        c.Status = 'Approved';
        c.Updated_From_External_System__c = false;
        if(c != null){
            insert c;
        }
        caseIds.add(c.Id);
    }
    
    public static testmethod void testMethod1() 
    {
        List<Case> caseList = [Select Id from Case];
        for(Case c:caseList){
			caseIds.add(c.Id);            
        }

    	  Test.startTest();

            CaseRecordPageComponentController.getDataForCaseRecordPage(caseIds);
        	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
			CaseRecordPageComponentController.makeCallout(caseIds);

        
        
      
        Test.stopTest();
    }
}