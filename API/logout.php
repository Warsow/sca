<?php
	if(isset($_POST))
	{
		include "config.php";
		$mysqli = new mysqli($server, $db_user, $db_pw, $db);

		// Check if the IP exists
		$json = json_decode($_POST["json"]);

		$sql = "DELETE FROM sessions WHERE account = ?";
		$statement = $mysqli->prepare($sql);

		$account = $json->account;
		$statement->bind_param("s", $account);
		$statement->execute();
		$mysqli->close();

		echo json_encode(["status"=>"success"]);
		$mysqli->close();
	}
	else
	{
		echo json_encode(["status"=>"fail"]);
	}
?>