const String statsFile = "sca/stats.txt";

class matchInfo
{
	String[] statsData;
	String statsString;
	int sFrags;
	int sGames;

	matchInfo()
	{

	}
		
	void loadStats()
	{
		this.statsString = G_LoadFile(statsFile);
		uint index = 0;
		while(true)
	{
		String token = this.statsString.getToken(index++);
		if(token == "")
			break;
		this.statsData.push_back(token);
	}

		this.sFrags = this.statsData[1];
		this.sGames = this.statsData[0];
	}

	void addGame()
	{
		this.sGames++;
	}

	void addFrag()
	{
		this.sFrags++;
	}

	void writeStats()
	{	
		String stats_string = "// Played Games\n" + "\""+ this.sGames + "\"\n" + "// Frags\n" + "\""+ this.sFrags + "\"";
		G_WriteFile(statsFile, stats_string);
	}

	void displayInfo()
	{
		String[] roundInfoText(3);
		roundInfoText[0] = "^7Total Games: ^1" + this.sGames;
		if(this.sFrags < 1000)
			roundInfoText[1] = "^7Total Frags: ^1" + this.sFrags + "";
		else
			roundInfoText[1] = "^7Total Frags: ^1" + (this.sFrags / 1000) + "K";
		roundInfoText[2] = "^7Next Map: ^1" + mapRotation.nextMap;

		uint infoMaxLength = 0;

		for(uint i = 0; i < roundInfoText.length(); i++)
		{
			if(infoMaxLength < roundInfoText[i].removeColorTokens().length())
				infoMaxLength = roundInfoText[i].removeColorTokens().length();
		}

		G_PrintMsg(null, roundInfoText[0] + "\n");
		G_PrintMsg(null, roundInfoText[1] + "\n");
		G_PrintMsg(null, roundInfoText[2] + "\n");
	}	
}