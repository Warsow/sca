namespace misc 
{
	String makeAlphaNum(String str)
	{
		String new_str;
		for ( uint i = 0; i < str.length(); i++ )
		{
			String char = str.substr(i,1);
			if ( char.isAlphaNumerical() || char == " " )
				new_str += char;
		}
		return new_str;
	}
}

