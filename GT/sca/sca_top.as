class scaTop
{
	Table top25("r l l l");

	void getData()
	{
		Curl@ req = Curl("http://localhost/sca/toplist.php");
		req.getJSON(CurlJSONDone(this.TopCallback));
	}

	void TopCallback(Curl@ req, JSON json)
	{
		int rank = 1;

		top25.addCell("^9Rank");
		top25.addCell("^9Player");
		top25.addCell("^9Damage given");
		top25.addCell("^9Damage received");
		

		for(uint i = 0; i < json.length(); i++)
		{
			top25.addCell("^9" + rank + ".");
			rank++;
			if(json[i]["account"].valuestring != "")
			 	top25.addCell(json[i]["player"].valuestring + "^2 (" + json[i]["account"].valuestring + "^2)^7");
			else
				top25.addCell(json[i]["player"].valuestring);
			top25.addCell(json[i]["d_given"].valueint + "");
			top25.addCell(json[i]["d_received"].valueint + "");	
		}	
	}

	void showTop(Client @client)
	{
		if(top25.getRow(0) == "")
		{
			G_PrintMsg(client.getEnt(), "^1Curl communication error, continuing without stats...\n");
			return;
		}
		G_PrintMsg(client.getEnt(), "^2Top 10 players\n\n");
		for(uint i = 0; i < 11; i++)
			G_PrintMsg(client.getEnt(), top25.getRow(i) + "\n");
	}

	void showTop25(Client @client)
	{
		G_PrintMsg(client.getEnt(), "^2Top 25 players\n\n");
		for(uint i = 0; i < top25.numRows(); i++)
			G_PrintMsg(client.getEnt(), top25.getRow(i) + "\n");
	}	
}