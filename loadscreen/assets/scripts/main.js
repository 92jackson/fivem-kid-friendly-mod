var runLoopTabs = true;
var maxTabs = 5;
var excludeTabs = [];

var server = LS_CONFIG.server_name;
var gamerTag = "Player";
var playerCount = 1;

var bgAudio;
function toggleMusic() {
	bgAudio.paused ? bgAudio.play() : bgAudio.pause();
	
	var indicatorOn = document.querySelector('#volumeIndicator a i.on');
	var indicatorOff = document.querySelector('#volumeIndicator a i.off');
	if (bgAudio.paused) {
		indicatorOn.classList.remove('active');
		indicatorOff.classList.add('active');
	} else {
		indicatorOff.classList.remove('active');
		indicatorOn.classList.add('active')
	}
}

function replacePlaceholders(string) {
	if (string != null) {
		string = string.replaceAll("%SERVER%", server);
		string = string.replaceAll("%GAMERTAG%", gamerTag);
		string = string.replaceAll("%PLAYERS_ONLINE%", playerCount);
		string = string.replaceAll("%PLAYERS_MAX%", LS_CONFIG.server_max_players);
		
		const urlRegex = /%URL\(([^|]+)\|([^)]+)\)%/g;
		string = string.replace(urlRegex, (match, stringA, stringB) => {
			let innerHTML;
			let aClass;
			if (stringA.startsWith("fa-")) {
				const iconTypeRegex = /fa-(brands|regular|solid)/;
				if (!iconTypeRegex.test(stringA)) stringA =  stringA + " fa-solid";
				
				innerHTML = `<i class="${stringA} fa-fw"></i>`;
				aClass = stringA.replace(iconTypeRegex, "").replace(/^fa-/, "");
			} else innerHTML = stringA;
			
			return `<a onClick="openUrl('${stringB}')" title="Open in Browser" class="${aClass}">${innerHTML}</a>`;
		});
		
		return string;
	}
	return "";
}

window.addEventListener('DOMContentLoaded', () => {
	if (typeof window.nuiHandoverData !== 'undefined' && window.nuiHandoverData !== null) {
		if (server == "" && typeof window.nuiHandoverData.serverAddress !== undefined) server = window.nuiHandoverData.serverAddress;
		if (typeof window.nuiHandoverData.name !== undefined) gamerTag = window.nuiHandoverData.name;
		if (typeof window.nuiHandoverData.player_count !== 'undefined') playerCount = window.nuiHandoverData.player_count;
	}
	document.querySelector('#connecting .serverAddress').innerText = server;
	document.querySelector('#header .player').innerText = gamerTag;
	
	document.querySelector('#server').innerHTML = replacePlaceholders(LS_CONFIG.server_description);
	document.querySelector('#features').innerHTML = replacePlaceholders(LS_CONFIG.server_features);
	document.querySelector('#rules').innerHTML = replacePlaceholders(LS_CONFIG.server_rules);
	document.querySelector('#team').innerHTML = replacePlaceholders(LS_CONFIG.server_team);
	document.querySelector('#socials').innerHTML = replacePlaceholders(LS_CONFIG.server_socials);
	
	if (!LS_CONFIG.show_header) document.querySelector('#header').style.display = 'none';
	
	const emojiArr = ["&#128512;", "&#128513;", "&#128514;", "&#129315;", "&#128515;", "&#128516;", "&#128517;", "&#128518;", "&#128522;", "&#128523;", "&#128526;", "&#128541;"];
	let emojiArea = document.querySelector('#header > span.emoji');
	if (!LS_CONFIG.show_header_emoji) emojiArea.style.display = 'none';
	else emojiArea.innerHTML = emojiArr[Math.floor(Math.random()*emojiArr.length)];
	
	bgAudio = document.querySelector('#fullScreenBg > .music');
	if (LS_CONFIG.play_background_music) {
		bgAudio.play();
		bgAudio.volume = 0.1;
		
		document.body.onkeyup = function(e) {
			if (e.key == " " || e.code == "Space" || e.keyCode == 32) {
				toggleMusic();
			}
		}
		
		let volumeIndicator = document.querySelector('#volumeIndicator a');
		let volumeLabelContainer = document.querySelector('#volumeIndicator .control');
		let volumeLabel = document.querySelector('#volumeIndicator .control b');
		volumeIndicator.style.display = "inline-block";
		setTimeout(() => {
			volumeLabelContainer.style.maxWidth = "0";
			volumeLabelContainer.style.opacity = "0";
			volumeLabelContainer.style.marginLeft = "-0.4vw";
			setTimeout(() => {
				volumeLabel.innerText = "MUSIC"
			}, 500);
		}, 5000);
		volumeIndicator.addEventListener("click", function(){toggleMusic();});
	} else document.querySelector('#volumeIndicator').style.display = "none";
	
	if (!LS_CONFIG.show_video_background) document.querySelector('#fullScreenBg > .fullscreenVideo').style.display = 'none';
	else {
		const iframe = document.createElement("iframe");
		iframe.src = `https://www.youtube.com/embed/${LS_CONFIG.yt_video_background_link}?&autoplay=1&mute=1&playsinline=1&controls=0&loop=1`;
		document.querySelector('#fullScreenBg > .fullscreenVideo').appendChild(iframe);
	}
	
	if (!LS_CONFIG.show_static_colour_background) document.querySelector('#fullScreenBg > .static').style.display = 'none';
	else if (LS_CONFIG.static_background_colour) {
		document.querySelector('#fullScreenBg > .static').style.backgroundColor = LS_CONFIG.static_background_colour;
	}
	
	if (!LS_CONFIG.show_animated_gradient_background) document.querySelector('#fullScreenBg > .animatedWrapper').style.display = 'none';
	else if (LS_CONFIG.animated_background_colour_1 && LS_CONFIG.animated_background_colour_2) {
		let multiBg = document.querySelectorAll('#fullScreenBg .animatedWrapper .animated');
		multiBg.forEach((bg) => {
			bg.style.backgroundImage = "linear-gradient(-45deg, " + LS_CONFIG.animated_background_colour_2 + " 50%, " + LS_CONFIG.animated_background_colour_1 + " 50%)";
		});
	}
	
	let socials = document.querySelector('#socials');
	if (LS_CONFIG.social_links_position == -1) {
		socials.style.display = 'none';
	} else if (LS_CONFIG.social_links_position == 0) {
		socials.classList.add("middle");
		socials.classList.add("left");
	} else if (LS_CONFIG.social_links_position == 1) {
		socials.classList.add("bottom");
	} else if (LS_CONFIG.social_links_position == 2) {
		socials.classList.add("middle");
		socials.classList.add("right");
	} else if (LS_CONFIG.social_links_position == 3) {
		socials.classList.add("bottom");
		socials.classList.add("left");
	} else if (LS_CONFIG.social_links_position == 4) {
		socials.classList.add("bottom");
		socials.classList.add("right");
	} else if (LS_CONFIG.social_links_position == 5) {
		socials.classList.add("top");
		socials.classList.add("right");
	}
	
	let wrapper = document.querySelector('#wrapper');
	if (LS_CONFIG.horizontal_content_align == 0) {
		wrapper.classList.add("right");
	} else if (LS_CONFIG.horizontal_content_align == 2) {
		wrapper.classList.add("left");
	}
	
	var defaultTab = 1;
	if (!LS_CONFIG.show_tab_server) {
		document.querySelector('.tab1').style.display = 'none';
		document.querySelector('#server').style.display = 'none';
		excludeTabs.push(1);
		if (defaultTab == 1) defaultTab = 2;
	}
	if (!LS_CONFIG.show_tab_features) {
		document.querySelector('.tab2').style.display = 'none';
		document.querySelector('#features').style.display = 'none';
		excludeTabs.push(2);
		if (defaultTab == 2) defaultTab = 3;
	}
	if (!LS_CONFIG.show_tab_rules) {
		document.querySelector('.tab3').style.display = 'none';
		document.querySelector('#rules').style.display = 'none';
		excludeTabs.push(3);
		if (defaultTab == 3) defaultTab = 4;
	}
	if (!LS_CONFIG.show_tab_team) {
		document.querySelector('.tab4').style.display = 'none';
		document.querySelector('#team').style.display = 'none';
		excludeTabs.push(4);
		if (defaultTab == 4) defaultTab = 5;
	}
	
	const tabs = document.querySelectorAll("nav > .link");
	const tabOne = document.querySelector("nav .tab" + defaultTab);
	tabOne.classList.add("selected");
	if (window.location.hash) tabOne.click();
	
	tabs.forEach(tab => {
		tab.addEventListener('click', function handleClick(event) {
			tabs.forEach(tab => {
				tab.classList.remove("selected");
			});
			
			tab.classList.add("selected");
			runLoopTabs = false;
		});
	});
	
	runLoopTabs = LS_CONFIG.auto_scroll_tabs
	if (LS_CONFIG.scroll_exclude_mod_tab) maxTabs = 4;
	
	var tabNum = 1;
	var loopTabs = window.setInterval(function(){
		if (runLoopTabs == true && maxTabs > excludeTabs.length + 1) {
			tabNum = tabNum + 1
			if (tabNum > maxTabs) tabNum = 1;
			
			if (excludeTabs.includes(tabNum) && excludeTabs.length < maxTabs) {
				while (true) {
					tabNum = tabNum + 1;
					if (tabNum > maxTabs) tabNum = 1;
					if (!excludeTabs.includes(tabNum)) break;
				}
			}
			
			document.querySelector(".tab" + tabNum).click();
			runLoopTabs = true;
		} else clearInterval(loopTabs)
	}, 5000);
	
	
	setInterval(UpdateTotalProgress, 250);
	document.querySelector("#wrapper").classList.add('fadeIn');
});

var types = [
	//"INIT_CORE",
	"INIT_BEFORE_MAP_LOADED",
	"MAP",
	"INIT_AFTER_MAP_LOADED",
	"INIT_SESSION"
];

var states = {};
const handlers = {
	startInitFunction(data) {
		if (states[data.type] == null) {
			states[data.type] = {};
			states[data.type].count = 0;
			states[data.type].done = 0;
		}
	},
	startInitFunctionOrder(data) {
		if (states[data.type] !== null && typeof states[data.type] !== "undefined") {
			states[data.type].count += data.count;
		}
	},
	initFunctionInvoked(data) {
		if (states[data.type] !== null && typeof states[data.type] !== "undefined") {
			states[data.type].done++;
		}
	},
	startDataFileEntries(data) {
		states["MAP"] = {};
		states["MAP"].count = data.count;
		states["MAP"].done = 0;
	},
	performMapLoadFunction(data) {
		states["MAP"].done++;
	}
};

/*window.addEventListener('message', function(e) {
	(handlers[e.data.eventName] || function() {})(e.data);
});*/

function GetTypeProgress(type) {
	if (states[type] != null) {
		var progress = states[type].done / states[type].count;
		return Math.round(progress * 100);
	}
	return 0;
}

function GetTotalProgress() {
	var totalProgress = 0;
	var totalStates = 0;
	
	for (var i = 0; i < types.length; i++) {
		var key = types[i];
		totalProgress += GetTypeProgress(key);
		totalStates++;
	}
	
	if (totalProgress == 0) return 0;
	return totalProgress / totalStates;
}

var progressOutput;
function UpdateTotalProgress() {
	var total = GetTotalProgress();
	if (progressOutput != null) total = Math.max(total, progressOutput);
	
	progressOutput = total;
	
	var progressBar = document.querySelector('#connecting progress');
	progressBar.value = progressOutput;
}

function openUrl(url) {
	runLoopTabs = false;
	window.invokeNative ? window.invokeNative('openUrl', url) : window.open(url);
}

window.addEventListener("message", function(event) {
	if (event.data.type == "loadingScreenMessage") {
		// Not currently implimented - v0.2
		var commandsTable = JSON.parse(event.data.message);
		for (var i = 0; i < commandsTable.length; i++) {
			commandsTable[i].kb = HashCommand("+" + commandsTable[i].kb);
			commandsTable[i].cntrl_1 = HashCommand("+" + commandsTable[i].cntrl_1);
			commandsTable[i].cntrl_2 = HashCommand("+" + commandsTable[i].cntrl_2);
		}
		
		var serializedTable = JSON.stringify(commandsTable);
		emit("HashedSetCommands", serializedTable);
	} else (handlers[event.data.eventName] || function() {})(event.data);
});

function HashCommand(command) {
	if (command !== null) {
		let hash = 0;
		let string = command.toLowerCase();
		for(i=0; i < string.length; i++) {
			let letter = string[i].charCodeAt();
			hash = hash + letter;
			hash += (hash << 10 >>> 0);
			hash ^= (hash >>> 6);
			hash = hash >>> 0
		}

		hash += (hash << 3);
		if (hash < 0) {
			hash = hash >>> 0
		}
		hash ^= (hash >>> 11);
		hash += (hash << 15);
		if (hash < 0) {
			hash = hash >>> 0
		}
		
		return "0x" + hash.toString(16).toUpperCase();
	}
	
	return null;
}