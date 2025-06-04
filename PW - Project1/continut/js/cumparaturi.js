class Storage {
    get() {}
    add(prod) {}
    clear() {}
}

class LocalStorage extends Storage {
    constructor() {
        super();
        if (!localStorage.getItem("cumparaturi")) {
            localStorage.setItem("cumparaturi", "[]");
        }
    }

    get() {
        return JSON.parse(localStorage.getItem("cumparaturi") || "[]");
    }

    add(prod) {
        const data = this.get();
        data.push(prod);
        localStorage.setItem("cumparaturi", JSON.stringify(data));
    }

    clear() {
        localStorage.removeItem("cumparaturi");
    }
}

class IndexedDBStorage extends Storage {
    dbName = "CumparaturiDB";
    storeName = "produse";
    db = null;

    constructor() {
        super();
    }

    async init() {
        this.db = await new Promise((resolve, reject) => {
            const request = indexedDB.open(this.dbName, 1);

            request.onupgradeneeded = (e) => {
                const db = e.target.result;
                if (!db.objectStoreNames.contains(this.storeName)) {
                    db.createObjectStore(this.storeName, { keyPath: "id" });
                }
            };

            request.onsuccess = (e) => resolve(e.target.result);
            request.onerror = (e) => {
                console.error("IndexedDB error:", e);
                reject(e);
            };
        });
    }

    async get() {
        return new Promise((resolve, reject) => {
            const result = [];
            const tx = this.db.transaction([this.storeName], "readonly");
            const store = tx.objectStore(this.storeName);
            const req = store.openCursor();

            req.onsuccess = (e) => {
                const cursor = e.target.result;
                if (cursor) {
                    result.push(cursor.value);
                    cursor.continue();
                } else {
                    resolve(result);
                }
            };

            req.onerror = (e) => reject(e);
        });
    }

    add(prod) {
        const tx = this.db.transaction([this.storeName], "readwrite");
        const store = tx.objectStore(this.storeName);
        store.add(prod);
    }

    clear() {
        const tx = this.db.transaction([this.storeName], "readwrite");
        const store = tx.objectStore(this.storeName);
        store.clear();
    }
}

class Produs {
    constructor(nume, cantitate, id) {
        this.id = id;
        this.nume = nume;
        this.cantitate = cantitate;
    }
}

const Cumparaturi = {
    storage: null,
    worker: null,

    initTable: async () => {
        const data = Cumparaturi.storage instanceof IndexedDBStorage
            ? await Cumparaturi.storage.get()
            : Cumparaturi.storage.get();

        Cumparaturi.renderTable(data);
        document.querySelector("#buy-form .data .loading").classList.add("hid");
    },

    initStorage: async (type) => {
        document.querySelector("#buy-form .data table tbody").innerHTML = "";

        if (type === "localStorage") {
            Cumparaturi.storage = new LocalStorage();
        } else if (type === "indexedDB") {
            document.querySelector("#buy-form .data .loading").classList.remove("hid");
            Cumparaturi.storage = new IndexedDBStorage();
            await Cumparaturi.storage.init();
        }

        Cumparaturi.initTable();
    },

    getNextAvailableID: async () => {
        const data = Cumparaturi.storage instanceof IndexedDBStorage
            ? await Cumparaturi.storage.get()
            : Cumparaturi.storage.get();

        return data.length + 1;
    },

    renderTable: (data) => {
        const table = document.querySelector("#buy-form .data table tbody");
        data.forEach(prod => {
            table.insertAdjacentHTML("beforeend", `
                <tr><td>${prod.id}</td><td>${prod.nume}</td><td>${prod.cantitate}</td></tr>
            `);
        });
    },

    submit: async () => {
        const nume = document.getElementById("name").value;
        const cantitate = parseInt(document.getElementById("cantitate").value || "1");
        const id = await Cumparaturi.getNextAvailableID();
        const prod = new Produs(nume, cantitate, id);
        Cumparaturi.worker.postMessage(prod);
    },

    makeWorker: () => {
        Cumparaturi.worker = new Worker("js/worker.js");
        Cumparaturi.worker.onmessage = (e) => {
            const prod = e.data;
            console.log("[main] received from worker:", prod);
            Cumparaturi.storage.add(prod);

            const table = document.querySelector("#buy-form .data table tbody");
            table.insertAdjacentHTML("beforeend", `
                <tr><td>${prod.id}</td><td>${prod.nume}</td><td>${prod.cantitate}</td></tr>
            `);
        };
    },

    reset: () => {
        Cumparaturi.storage.clear();
        document.querySelector("#buy-form .data table tbody").innerHTML = "";
    }
};

Cumparaturi.makeWorker();
Cumparaturi.initStorage("localStorage");
