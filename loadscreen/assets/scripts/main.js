var runLoopTabs = true;

var server = LS_CONFIG.server_name;
var gamerTag = "Player";
var playerCount = 1;

var bgAudio;

function escapeHtml(value) {
	return String(value ?? "").replace(/[&<>'"]/g, character => ({
		'&': '&amp;',
		'<': '&lt;',
		'>': '&gt;',
		"'": '&#39;',
		'"': '&quot;'
	})[character]);
}

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
		string = string.replaceAll("%SERVER%", () => escapeHtml(server));
		string = string.replaceAll("%GAMERTAG%", () => escapeHtml(gamerTag));
		string = string.replaceAll("%PLAYERS_ONLINE%", () => escapeHtml(playerCount));
		string = string.replaceAll("%PLAYERS_MAX%", () => escapeHtml(LS_CONFIG.server_max_players));

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

function createTabs(configuredTabs) {
	const navigation = document.querySelector("nav");
	const contentArea = document.querySelector(".content");
	const ids = new Set();
	const tabs = [];

	if (!Array.isArray(configuredTabs)) return tabs;

	configuredTabs.forEach((tab) => {
		if (!tab || typeof tab.id !== "string" || !/^[A-Za-z0-9_-]+$/.test(tab.id) || ids.has(tab.id)) {
			console.warn("Skipping invalid or duplicate loading-screen tab", tab);
			return;
		}

		ids.add(tab.id);
		const link = document.createElement("a");
		link.href = `#${tab.id}`;
		link.className = "link";
		if (tab.pin_to_bottom === true) link.classList.add("bottom");
		link.title = typeof tab.title === "string" ? tab.title : tab.id;

		const image = document.createElement("img");
		image.src = typeof tab.nav_image === "string" ? tab.nav_image : "assets/nav/server.png";
		image.alt = link.title;
		link.appendChild(image);
		navigation.appendChild(link);

		const panel = document.createElement("div");
		panel.id = tab.id;
		panel.className = "item";
		panel.innerHTML = replacePlaceholders(tab.content);
		contentArea.appendChild(panel);

		tabs.push({link, excludeFromAutoScroll: tab.exclude_from_auto_scroll === true});
	});

	return tabs;
}

window.addEventListener('DOMContentLoaded', () => {
	if (typeof window.nuiHandoverData !== 'undefined' && window.nuiHandoverData !== null) {
		if (server == "" && typeof window.nuiHandoverData.serverAddress !== 'undefined') server = window.nuiHandoverData.serverAddress;
		if (typeof window.nuiHandoverData.name !== 'undefined') gamerTag = window.nuiHandoverData.name;
		if (typeof window.nuiHandoverData.player_count !== 'undefined') playerCount = window.nuiHandoverData.player_count;
	}
	document.querySelector('#connecting .serverAddress').innerText = server;
	document.querySelector('#header .player').innerText = gamerTag;

	document.querySelector('#socials').innerHTML = replacePlaceholders(LS_CONFIG.server_socials);
	const tabs = createTabs(LS_CONFIG.tabs);

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

	if (tabs.length > 0) {
		tabs[0].link.classList.add("selected");
		if (window.location.hash) tabs[0].link.click();
	}

	tabs.forEach(tab => {
		tab.link.addEventListener('click', function handleClick() {
			tabs.forEach(tabItem => tabItem.link.classList.remove("selected"));
			tab.link.classList.add("selected");
			runLoopTabs = false;
		});
	});

	runLoopTabs = LS_CONFIG.auto_scroll_tabs === true;
	const autoScrollTabs = tabs.filter(tab => !tab.excludeFromAutoScroll);
	let tabNum = 0;
	const loopTabs = window.setInterval(function(){
		if (runLoopTabs && autoScrollTabs.length > 1) {
			tabNum = (tabNum + 1) % autoScrollTabs.length;
			autoScrollTabs[tabNum].link.click();
			runLoopTabs = true;
		} else clearInterval(loopTabs);
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
		for(let i=0; i < string.length; i++) {
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
