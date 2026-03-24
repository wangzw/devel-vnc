chrome.tabs.onRemoved.addListener(async () => {
  const tabs = await chrome.tabs.query({ currentWindow: true });
  if (tabs.length === 0) {
    chrome.tabs.create({ url: "about:blank" });
  }
});
