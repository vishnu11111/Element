({
	doInit : function(component, event, helper) {
		var getData = component.get("c.getDataForCaseRecordPage");
            getData.setParams({
                "caseId" : component.get("v.recordId")
            })
          //  getData.setStorable();
            getData.setCallback(this,function(response){
                
                if (response.getState() === "SUCCESS") {
                    
                    var response = response.getReturnValue();
                    component.set("v.caseDetails",response.caseDetails);
                  

                    component.set("v.casePolicyList",response.casePolicies);
                    
                    component.set("v.casePoliciesCount",response.casePolicies.length);
                    
                }else if (response.getState() === "ERROR") {
                    helper.showToast(component, event, helper) ;
                }else if (response.getState() === "INCOMPLETE") {
                    helper.showToast(component, event, helper) ;
                }   
            });
      	$A.enqueueAction(getData);
	},
    
    showToast : function(component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Error",
        "message": "Please contact system administrator"
    });
    toastEvent.fire();
}
})