class scaVotes
{
	int randmap_time = 0;
	String randmap = "";

	void scaRandmap(bool passed = false)
	{
		if(passed)
		{
			mapRotation.nextMap = this.randmap;
			return;
		}

		if(levelTime - randmap_time > 1100)
		{
			this.randmap = "";

			while(true)
			{
				int randNum = rand() % mapRotation.maps.length();

				if(mapRotation.maps[randNum] != mapRotation.map)
				{
					this.randmap = mapRotation.maps[randNum];
					break;
				}
			}			
		}

		if (levelTime - randmap_time < 80)
			G_PrintMsg(null, "^7Chosen map: ^1" + randmap + " ^7(" + mapRotation.maps.length() + " ^7maps)\n");

		randmap_time = levelTime;
	}
}