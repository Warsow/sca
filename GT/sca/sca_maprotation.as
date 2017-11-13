const String mapFile = "sca/maps.txt";
const String playedMapsFile = "sca/played.txt";


class scaMapRotation
{
	Cvar mapname("mapname", "", 0);
	String map = mapname.get_string();
	String mapList;
	String playedMapsList;
	String[] maps;
	String[] notPlayedMaps;
	String[] playedMaps;
	String nextMap;
	int randNum;

	void getMapsFromFile()
	{
		if(!G_FileExists(mapFile))
			G_WriteFile(mapFile, "wca1 wca3");

		this.mapList = G_LoadFile(mapFile);
		uint index = 0;
		while(true)
		{
			String token = this.mapList.getToken(index++);
			if(token == "")
				break;
			this.maps.push_back(token);
		}
	}

	void getPlayedMapsFromFile()
	{
		if(!G_FileExists(playedMapsFile))
			G_WriteFile(playedMapsFile, "");

		this.playedMapsList = G_LoadFile(playedMapsFile);
		uint index = 0;
		while(true)
		{
			String token = this.playedMapsList.getToken(index++);
			if(token == "")
				break;
			this.playedMaps.push_back(token);
		}
	}

	void writePlayedMap()
	{
		G_AppendToFile(playedMapsFile, this.map + " ");
	}

	void chooseNextMap() 
	{
		// If the played maps array is empty, fill it with all maps
		if(this.playedMaps.length() == 0)
		{
			for(uint i = 0; i < this.maps.length(); i++)
				this.notPlayedMaps.insertAt(i, this.maps[i]);
		}
		else
		{
			for(uint i = 0; i < this.maps.length(); i++)
			{
				if(this.playedMaps.find(this.maps[i]) < 0)
				{
					this.notPlayedMaps.push_back(this.maps[i]);
				}
			}		
		}

		// If the notPlayedMaps array is still empty, clear the played maps
		if(this.notPlayedMaps.length() == 0)
		{
			G_WriteFile(playedMapsFile, "");
			for(uint i = 0; i < this.maps.length(); i++)
			{
				this.notPlayedMaps.push_back(this.maps[i]);
			}
			this.notPlayedMaps.removeAt(this.notPlayedMaps.find(this.map));
			writePlayedMap();
		}

		// choose random map
		this.randNum = rand() % this.notPlayedMaps.length();		
		this.nextMap = this.notPlayedMaps[this.randNum];
	}	
}