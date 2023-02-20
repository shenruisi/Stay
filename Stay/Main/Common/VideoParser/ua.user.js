(function(){
	const customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1";
	Object.defineProperty(navigator, "userAgent", {
		value: customUserAgent,
		writable: false,
		configurable: true,
		enumerable: true
	});
})();