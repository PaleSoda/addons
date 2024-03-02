<?php
	if (!isset($_POST["log_type"], $_POST["url"])) {
			return;
	}

	$webhookurl = $_POST["url"];

	$timestamp = date("c", strtotime("now"));
	$json_data = "";
	
	if( $_POST["log_type"] == "warning" ){
	
		$json_data = json_encode([
				"content" => "",
				"username" => "AWarn3 Logs",
				"avatar_url" => "https://g4p.org/awarn2/awarn3_chatlogo.png",
				"embeds" => [
						[
							"title" => $_POST["title"],
							"type" => "rich",
							"timestamp" => $timestamp,
							"color" => hexdec($_POST["bar_color"]),
							"footer" => [
									"text" => "AWarn3 Discord Relay",
									"icon_url" => "https://g4p.org/awarn2/awarn3_chatlogo.png"
							],
							"fields" => [
									// Warned Player
									[
											"name" => "Warned Player",
											"value" => $_POST["warned_player"],
											"inline" => true
									],
									// Warning Admin
									[
											"name" => "Warning Admin",
											"value" => $_POST["warning_admin"],
											"inline" => true
									],
									// Warning Reason
									[
											"name" => "Warning Reason",
											"value" => $_POST["warning_reason"],
											"inline" => false
									]
							]
						]
				]

		], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE );
		
	} else {
	
		$json_data = json_encode([
				"content" => "",
				"username" => "AWarn3 Logs",
				"avatar_url" => "https://g4p.org/awarn2/awarn3_chatlogo.png",
				"embeds" => [
						[
							"title" => $_POST["title"],
							"type" => "rich",
							"timestamp" => $timestamp,
							"color" => hexdec($_POST["bar_color"]),
							"footer" => [
									"text" => "AWarn3 Discord Relay",
									"icon_url" => "https://g4p.org/awarn2/awarn3_chatlogo.png"
							],
							"fields" => [
									// Warned Player
									[
											"name" => "Punished Player",
											"value" => $_POST["punished_player"],
											"inline" => true
									],
									// Warning Admin
									[
											"name" => "Player Warnings",
											"value" => $_POST["player_warnings"],
											"inline" => true
									],
									// Warning Reason
									[
											"name" => "Punishment",
											"value" => $_POST["punishment"],
											"inline" => false
									]
							]
						]
				]

		], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE );
		
	}


	$ch = curl_init( $webhookurl );
	curl_setopt( $ch, CURLOPT_HTTPHEADER, array('Content-type: application/json'));
	curl_setopt( $ch, CURLOPT_POST, 1);
	curl_setopt( $ch, CURLOPT_POSTFIELDS, $json_data);
	curl_setopt( $ch, CURLOPT_FOLLOWLOCATION, 1);
	curl_setopt( $ch, CURLOPT_HEADER, 0);
	curl_setopt( $ch, CURLOPT_RETURNTRANSFER, 1);

	curl_exec( $ch );
	curl_close( $ch );