<?php 
	if(isset($_POST))
	{
		include "config.php";
		$mysqli = new mysqli($server, $db_user, $db_pw, $db);

		// Check if the IP exists
		$json = json_decode($_POST["json"]);
		$ip = $json->ip;

		$sql = "SELECT * FROM sessions WHERE IP = ?";
		$statement = $mysqli->prepare($sql);
		$statement->bind_param("s", $ip);
		$statement->execute();

		$result = $statement->get_result();

		if($result->num_rows == 0)
		{
			echo json_encode(["status"=>"no_session"]);
		}
		else
		{
			$row = $result->fetch_assoc();

			// Check if the session is still valid
			$systemTime = time();
			$sessionTime = $row['timestamp'];
			
			if(($sessionTime + SESSION_TIME) > $systemTime)
			{
				echo json_encode(["status"=>"active_session", "account"=> $row['account']]);
				// We also renew the session
				$sql = "UPDATE sessions SET timestamp = ? WHERE IP = ?";
				$statement = $mysqli->prepare($sql);
				$statement->bind_param("is", $systemTime, $ip);
				$statement->execute();
			}
			else
			{
				echo json_encode(["status"=>"no_session"]);
			}
		}
		$mysqli->close();
	}	
?>