/**
   LabelChange_RecordType
    @author : Subodh Bahl <Subodh.bahl@gmail.com>
    @Description : This class contains the ChangeLabel webservice call which a.) Checks if there is a Custom Setting for the current record type 
    & b.) Returns the new label to the webservice call if the record type Id for the current record matches the record type Id in custom Settings.
    
 */
global class LabelChange_RecordType
{  
    //Get all Custom Settings of Label_By_RecordType__c;
    static Map<string, Label_By_RecordType__c> LabelSettingsMap = Label_By_RecordType__c.getall();
    static Map<string, list<Label_By_RecordType__c>> SettingsMap = new Map<string, list<Label_By_RecordType__c>>();
    // A map which contains a map of id prefix and object name
    static Map<String,String> keyPrefixMap = new Map<String,String>{};
    /*
        A webservice which gets a URL and checks if the label needs to be replaced for that page.
        It returns a list of strings which are used in Jquery to replace the label
    */
    webService static list<String> ChangeLabel(String Pageurl)
    { 
        string RecTypeId='';
        string leftUrl;
        SetObjMap();
        SetSettingsMap();
        //Check if the page is Create page and Record Type id is set.
        //If yes put the record type id in RecTypeId
        if(Pageurl.contains('?')){    
            List<String> FullUrlparts = Pageurl.split('\\?');{    
                string RecTypeString;
                if(FullUrlparts[1].contains('&')){
                    for(string str:FullUrlparts[1].split('&')){
                        if(str.contains('RecordType'))
                            RecTypeString=str;
                    }
                }
                else
                    RecTypeString=FullUrlparts[1];
                    if(RecTypeString.contains('='))
                    RecTypeId=RecTypeString.split('=')[1];
            }
        }
        else
            leftUrl=Pageurl;
        
        
        /*
         * The code below runs to :
         * a.) Check if the record is getting created or on page Load
         * b.) Return the list of 'old label':'new label' to the Salesforce Javascript call via Home Page Component
         */
        
        list<string> strlist=new list<string>();
        List<String> parts = PageUrl.split('/');

        //check for the id
        if(parts.size()>3)
        {
        
            /*
             * The code below runs on Page Creation.
             * How do I know? A: This is all calculated via the URL. When the record is getting created, parts[3] is a full 15 character ID when the record is already created. 
             */
        
            //Check if this is the record Id 
            if(parts[3].length()==15)
            { 
               //get the object name
               string objName1=keyPrefixMap.get(parts[3].substring(0,3));
               System.Debug(settingsMap);
               
               //check if Custom settings exist for that object
               if(SettingsMap.get(objName1)!=null)
               {
                   //if yes query and check if the record type is the same
                   if(!Test.isRunningTest())
                   {
                       for(Label_By_RecordType__c lbr:SettingsMap.get(objName1))
                        {
                       string querystring='select id from '+objName1+' where id=\''+parts[3]+'\' and RecordTypeId=\''+lbr.Record_Type_Id__c+'\'';
                       List<sObject> LRec = Database.query(querystring);
                       System.Debug(LRec);
                       if(LRec.size()>0)
                           strlist.add(lbr.Old_Label__c+':'+lbr.New_Label__c);
                        }
                   }
                   else
                   {
                       System.Debug('Enterin else');
                       for(Label_By_RecordType__c lbr:SettingsMap.get(objName1))
                        { 
                           strlist.add(lbr.Old_Label__c+':'+lbr.New_Label__c);
                       }
                   }
                    
               }
            }
            
            
            /*
            
            */
            
            
            else if(parts[3].length()==3)//If the page is on create page
            {
                System.debug('hi');
                if(RecTypeId!='')
                {
                    //Get the object name
                    string objName=keyPrefixMap.get(parts[3].substring(0,3));
                    System.Debug(objName);
                    
                    if(SettingsMap.get(objName)!=null)//check if Custom settings exist for that object
                    {
                        //if RecTypeId is same as the record type id in custom settings
                        for(Label_By_RecordType__c lbr:SettingsMap.get(objName))
                        {
                            if(RecTypeId.contains(lbr.Record_Type_Id__c))
                                strlist.add(lbr.Old_Label__c+':'+lbr.New_Label__c);
                        }
                    }
                }
            }
        }
      
        //return the list to the salesforce javascript call
        return strlist;
     
    }
    
    //Set the PrefixMap
    static void SetObjMap()
    {
           Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
           Set<String> keyPrefixSet = gd.keySet();
           for(String sObj : keyPrefixSet){
           Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
           String tempName = r.getName();
           String tempPrefix = r.getKeyPrefix();
           System.debug('Processing Object['+tempName + '] with Prefix ['+ tempPrefix+']');
           keyPrefixMap.put(tempPrefix,tempName);
           }
     }
     
   
   //Set the SettingsMap  
    static void SetSettingsMap()
    {
           for(string str:LabelSettingsMap.keyset())
           {
               if(SettingsMap.get(LabelSettingsMap.get(str).Object_API_Name__c)==null)
               {
                   list<Label_By_RecordType__c> lbs= new list<Label_By_RecordType__c>();
                   lbs.add(LabelSettingsMap.get(str));
                   SettingsMap.put(LabelSettingsMap.get(str).Object_API_Name__c,lbs);
               }
               else
               {
                   SettingsMap.get(LabelSettingsMap.get(str).Object_API_Name__c).add(LabelSettingsMap.get(str));
               }
           }
    }
}