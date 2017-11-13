<?php 
	if(isset($_POST))
	{
		include "config.php";
		$mysqli = new mysqli($server, $db_user, $db_pw, $db);
		$mysqli->options(MYSQLI_OPT_INT_AND_FLOAT_NATIVE, true);

		$login = json_decode($_POST["json"]);
		$ip = $mysqli->real_escape_string($login->ip);
		$user = $mysqli->real_escape_string($login->user);
		$pw = $mysqli->real_escape_string($login->pw);

		$result = $mysqli->query("SELECT * FROM stats WHERE account='$user'");

		if($result->num_rows == 0)
		{
			$result->free_result();
			echo json_encode(["status"=>"no_account"]);
			$mysqli->close();
			die();
		}

		// Time to check the password
		$result = $mysqli->query("SELECT * FROM stats WHERE account='$user' AND password=SHA2('$pw', 256)");
		if($result->num_rows > 0)
		{
			echo json_encode(["status"=>"success", "account"=> $user]);

			$systemTime = time();

			$sql = "SELECT * FROM sessions WHERE IP = ?";
			$statement = $mysqli->prepare($sql);
			$statement->bind_param("s", $ip);
			$statement->execute();

			$result = $statement->get_result();

			if($result->num_rows == 0)
			{
				$sql = "INSERT INTO sessions (timestamp, account, IP) VALUES (?, ?, ?)";
			}
			else
			{
				$sql = "UPDATE sessions SET timestamp = ?, account = ? WHERE IP = ?";
			}

            $statement = $mysqli->prepare($sql);
            $statement->bind_param("iss", $systemTime, $user, $ip);
            $statement->execute();
			
			$mysqli->query("DELETE FROM sessions WHERE account='$user' AND IP != '$ip'"); 		
		}
		else
		{
			echo json_encode(["status"=>"wrong_password"]);
		}
		
		$mysqli->close();
	}
?>