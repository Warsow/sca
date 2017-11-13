<?php
	if(isset($_POST))
	{
		include "config.php";

		$mysqli = new mysqli($server, $db_user, $db_pw, $db);
		$mysqli->options(MYSQLI_OPT_INT_AND_FLOAT_NATIVE, true);

		$account = json_decode($_POST["json"]);

		$result = $mysqli->query("SELECT * FROM stats WHERE account= '" . $mysqli->real_escape_string($account->account) . "'");
		echo json_encode($result->fetch_object(), JSON_PRETTY_PRINT);

		$mysqli->close();
	}
?>