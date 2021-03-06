// Copyright 2019 University of St. Thomas - Minnesota. All rights reserved.
// Use of this source code is governed by a BSD Revised
// license that can be found in the LICENSE file.
// Created by Thaddaeus Dahlberg on 11/12/2018.
public with sharing class SummitEventsAddToCalendarController{
	public Summit_Events_Instance__c evtInfo{ get; set; }

	public SummitEventsShared SEShared = new SummitEventsShared();

	public String DTSTART{ get; set; }

	public String TIMEZONE{ get; set; }

	public String DTEND{ get; set; }

	public String DTSTAMP{ get; set; }

	public String SUMMARY{ get; set; }

	public String LOCATION{ get; set; }

	public String DESCRIPTION{ get; set; }

	public String UUID{ get; set; }

	public SummitEventsAddToCalendarController(){
		DTSTART = '';
		DTEND = '';
		DTSTAMP = '';
		SUMMARY = '';
		LOCATION = '';
		DESCRIPTION = '';
		TIMEZONE = '';
		UUID = NewGuid();
		String URLinstanceID = ApexPages.currentPage().getParameters().get('instanceID');
		if (!String.isBlank(URLinstanceID)){

			List<Summit_Events_Instance__c> eventInstanceList = [SELECT Id, Event_Name__c, Instance_Title__c, Instance_Start_Date__c, Instance_End_Date__c, Instance_Start_Time__c, Instance_End_Time__c, Instance_Time_Zone__c, Instance_Short_Description__c, Event__r.Event_Short_Listing_Description__c, Virtual_Meeting_Link__c, Event__r.Location_Title__c, Event__r.Location_Address__c, Event__r.Location_Map_Link__c, Location_Title_Override__c, Location_Address_Override__c, Location_Map_Link_Override__c
			                                                     FROM Summit_Events_Instance__c
			                                                     WHERE Id = :URLinstanceID];

			if (eventInstanceList.size() > 0){
				evtInfo = eventInstanceList[0];
			}

			if (evtInfo != null){
				DTSTART = SEShared.convertDateToDatetime(evtInfo.Instance_Start_Date__c, evtInfo.Instance_Start_Time__c, '').format('yyyyMMdd\'T\'HHmmss\'Z\'');
				DTEND = SEShared.convertDateToDatetime(evtInfo.Instance_End_Date__c, evtInfo.Instance_End_Time__c, '').format('yyyyMMdd\'T\'HHmmss\'Z\'');
				DTSTAMP = Datetime.now().format('yyyyMMdd\'T\'HHmmss\'Z\'');
				TIMEZONE = SEShared.getTimeZonePick(evtInfo.Instance_Time_Zone__c);

				SUMMARY = evtInfo.Event_Name__c;
				if (!String.isnotBlank(evtInfo.Instance_Title__c)){
					SUMMARY += evtInfo.Event_Name__c + ' - ' + evtInfo.Instance_Title__c;
				}

				LOCATION = evtInfo.Event__r.Location_Title__c;
				if (!String.isBlank(evtInfo.Location_Title_Override__c)){
					LOCATION = evtInfo.Location_Title_Override__c;
				}

				DESCRIPTION = evtInfo.Event__r.Event_Short_Listing_Description__c;
				if (!String.isBlank(evtInfo.Instance_Short_Description__c)){
					DESCRIPTION += '\\n' + '\\n' + evtInfo.Instance_Short_Description__c + '\\n';
				}
				if (!String.isBlank(evtInfo.Virtual_Meeting_Link__c)){
					DESCRIPTION += '\\n' + 'Meeting Link - ' + evtInfo.Virtual_Meeting_Link__c + '\\n';
				}
				if (!String.isBlank(evtInfo.Event__r.Location_Address__c)){
					DESCRIPTION += '\\n' + 'Location Information:' + '\\n' + evtInfo.Event__r.Location_Address__c + '\\n' + evtInfo.Event__r.Location_Map_Link__c + '\\n';
				}
				if (!String.isBlank(evtInfo.Location_Title_Override__c)){
					DESCRIPTION += '\\n' + 'Location Information:' + '\\n' + evtInfo.Location_Title_Override__c + '\\n' + evtInfo.Location_Map_Link_Override__c + '\\n';

				}
			}
		}
	}

	private static String kHexChars = '0123456789abcdef';
	public static String NewGuid(){

		String returnValue = '';
		Integer nextByte = 0;

		for (Integer i = 0; i < 16; i++){

			if (i == 4 || i == 6 || i == 8 || i == 10)
				returnValue += '-';
			nextByte = (Math.round(Math.random() * 255)-128) & 255;

			if (i == 6){
				nextByte = nextByte & 15;
				nextByte = nextByte | (4 << 4);
			}

			if (i == 8){
				nextByte = nextByte & 63;
				nextByte = nextByte | 128;
			}

			returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
			returnValue += getCharAtIndex(kHexChars, nextByte & 15);
		}

		return returnValue;
	}

	public static String getCharAtIndex(String str, Integer index){
		if (str == null)
			return null;
		if (str.length() <= 0)
			return str;
		if (index == str.length())
			return null;
		return str.substring(index, index + 1);
	}
}

//http://dev-stthomas.cs65.force.comusteventaddtocalendar?instanceID=a320m0000001I34