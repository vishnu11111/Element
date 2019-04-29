//*******************************Scheduling class for batch class*****************//
public class scheduleClassForSendEmailBatch implements Schedulable
{
	public void execute(SchedulableContext scheduleContext)
	{
		SendEmailBatchClass BatchObj = new SendEmailBatchClass();
		Database.executeBatch(BatchObj,10);
        
        
	}
}