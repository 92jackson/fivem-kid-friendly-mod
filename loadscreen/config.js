const LS_CONFIG = {
	server_name: "LOCAL_HOST", // Leave blank to display the server IP address instead, for display purposes only
	server_max_players: 4, // Enter your server's max slots, for display purposes only

	play_background_music: true, // Music can be stopped by pressing the SPACEBAR. Place your MP3 in /loadscreen/assets/bg_music.mp3

	show_video_background: false, // Show a YouTube video as the background
	yt_video_background_link: "", // Any YouTube video (click share on the YouTube video you'd like to use and copy everything after "https://youtu.be/")
	show_static_colour_background: false, // Show a static colour background, set below, this will overlay the video background (if enabled)
	static_background_colour: "#0000FF50", // (BLUE 50% TRANSPARENT) -- #RRGGBBAA format (Red Green Blue Alpha). For colour codes, check https://fffuel.co/cccolor
	show_animated_gradient_background: true, // Show an animated gradient background, this will overlay the static background (if enabled)
	animated_background_colour_1: "#0000FF50", // (BLUE 50% TRANSPARENT) -- #RRGGBBAA format
	animated_background_colour_2: "#FFB6C150", // (PINK 50% TRANSPARENT)

	horizontal_content_align: 2, // 0 = Left, 1 = Middle, 2 = Right
	social_links_position: 0, // -1 = None/hidden, 0 = Middle Left, 1 = Bottom Center, 2 = Middle Right, 3 = Bottom Left, 4 = Bottom Right, 5 = Top Right. Shows the links defined in LS_CONFIG.server_socials

	show_header: true, // Shows a short welcome message at the top of the screen
		show_header_emoji: true, // 🙂 Displays one of a several friendly emojis next to the welcome message
	auto_scroll_tabs: true, // The loading screen will auto show each tab one by one


	// For greater customisation, the following configs allow the use of HTML as well as plain text
	// Want to use icons in your HTML? Font Awesome is included; see https://fontawesome.com/search

	// Placeholders:
	// %SERVER%			= Replaced with server_name, or server IP address if server_name is left blank
	// %GAMERTAG%		= Prints the connecting player's name
	// %PLAYERS_ONLINE%	= Prints the number of players currently online
	// %PLAYERS_MAX%	= Prints the value set in server_max_players
	// %URL(text|url)%	= Clickable link, e.g: %URL(Google|http://google.com)% will be turned into a text link "Google" which when clicked, opens google.com in the user's browser. "text" can also be a FontAwsome reference, e.g: %URL(fa-youtube|http://youtube.com)% will show as a clickable icon

	// Tabs appear in this order. Remove an entry to hide it, or add an object to create a tab.
	// Each id must be unique and contain only letters, numbers, underscores or hyphens.
	// nav_image paths are relative to the /loadscreen directory.
	// pin_to_bottom fixes a navigation icon to the bottom of the screen.
	// exclude_from_auto_scroll keeps a tab clickable while excluding it from rotation.
	tabs: [
		{
			id: "server",
			title: "Server information",
			nav_image: "assets/nav/server.png",
			content: `
		<h2>Welcome!</h2>
		<p>Hello and welcome to our server, <b>%GAMERTAG%!</b> We offer a safe place for everyone to join and have fun, free from violence and adult themes.</p>
		<p>We currently have <b>%PLAYERS_ONLINE%</b> player(s) out of %PLAYERS_MAX% connected.</p>
			`
		},
		{
			id: "features",
			title: "Features",
			nav_image: "assets/nav/features.png",
			content: `
		<h2>Features</h2>
		<small>These are just some of our main features:</small>
		<ul class="alternate">
			<li>Everyone's invincible</li>
			<li>No ragdoll animations</li>
			<li>Friendly vehicle taking</li>
			<li>All weapons removed</li>
			<li>Easy vehicle spawning</li>
		</ul>
			`
		},
		/*{
			id: "rules",
			title: "Rules",
			nav_image: "assets/nav/rules.png",
			content: `
		<h2>Rules</h2>
		<small>Please stick to our rules to help keep this a safe place <i class="fa-regular fa-heart"></i></small>
		<ul class="alternate">
			<li>Be kind</li>
			<li>No bullying</li>
			<li>No hacking</li>
			<li>No exploiting</li>
		</ul>
			`
		},
	    {
			id: "team",
			title: "Our team",
			nav_image: "assets/nav/team.png",
			content: `
		<h2>Our team</h2>
		<table class="fixed">
			<tr class="fixedImage">
				<td><img class="round" src="https://img.icons8.com/ios-filled/512/user-male-circle.png" /></td>
				<td><img class="round" src="https://img.icons8.com/ios-filled/512/user-female-circle.png" /></td>
				<td><img class="round" src="https://img.icons8.com/ios-filled/512/cat-profile.png" /></td>
			</tr>
			<tr class="bold">
				<td>Person 1</td>
				<td>Person 2</td>
				<td>Person 3</td>
			</tr>
			<tr class="small">
				<td>Owner</td>
				<td>Admin</td>
				<td>Moderator</td>
			</tr>
			<tr class="small">
				<td><i class="fa-brands fa-discord"></i> Discord_username</td>
				<td></td>
				<td></td>
			</tr>
		</table>
			`
		},*/
		{
			id: "fkfm",
			title: "About this mod",
			nav_image: "assets/nav/fkfm.png",
			pin_to_bottom: true,
			exclude_from_auto_scroll: true,
			content: `
		<h2><small>This server is running the</small><br/>FiveM <b class="multicolour">Kid Friendly Mod</b></h2>
		<p>The mod aims to assist server owners in providing a safe place for their players to freeroam and have fun with friends, restricting, managing and removing content which may be inappropriate to their target audience.</p>
		<p>For support and requests, join the Discord: %URL(discord.gg/e3eXGTJbjx|https://discord.gg/e3eXGTJbjx)%</p>
		<p><i><small class="warn">Results depend largely on the configuration implemented by the server.<br/><u>Parents</u> of young children seeking to play are advised to test beforehand and monitor throughout, to ensure suitability. This mod will unlikely ever remove 100% of all adult content.</small></i></p>
			`
		}
	],

	server_socials: `
		%URL(fa-facebook-f fa-brands|http://facebook.com)%
		%URL(fa-twitch fa-brands|http://twitch.com)%
		%URL(fa-twitter fa-brands|http://twitter.com)%
		%URL(fa-youtube fa-brands|http://youtube.com)%
		%URL(fa-discord fa-brands|http://discord.com)%
		%URL(fa-instagram fa-brands|http://instagram.com)%
	`
};
