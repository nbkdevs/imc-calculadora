/* Local history via chrome.storage.local (works in Firefox & Edge MV3) */
(function (global) {
  const KEY = "imc_history_v1";
  const MAX = 50;

  function getStorage() {
    return (typeof browser !== "undefined" && browser.storage) || chrome.storage;
  }

  async function load() {
    const storage = getStorage();
    const data = await storage.local.get(KEY);
    return Array.isArray(data[KEY]) ? data[KEY] : [];
  }

  async function save(entries) {
    const storage = getStorage();
    await storage.local.set({ [KEY]: entries.slice(0, MAX) });
  }

  async function add(entry) {
    const list = await load();
    list.unshift({
      id: `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
      at: new Date().toISOString(),
      ...entry,
    });
    await save(list);
    return list;
  }

  async function clear() {
    await save([]);
  }

  global.ImcHistory = { load, add, clear };
})(typeof globalThis !== "undefined" ? globalThis : window);
